//
//  AppDelegate.m
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 15..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import "AppDelegate.h"
#import "CallServer.h"
#import "GlobalData.h"
#import "GlobalDataManager.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        NSLog(@"%@",@"등록완료");
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        NSLog(@"%@",@"등록완료");
    }
    
    if(launchOptions){
        UITextView *txtView = nil ;
        //
        txtView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 250.0)];
        [txtView setBackgroundColor:[UIColor clearColor]];
        [txtView setTextAlignment:NSTextAlignmentLeft] ;
        [txtView setEditable:NO];
        [txtView setFont:[UIFont fontWithName:@"Avenir-Black" size:13]];
        [txtView setText:@"테스트합니다. \n어떻게 나오는지 확인하겠습니다.\n 이렇게 나오면 될까요?\n 확인부탁드립니다.\n 하지만 알러트창 제목부분을 어떻게 해야할지요. \n 흠 잘모르겠습니다."];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithFrame:CGRectMake(0, 0, 300, 550)];
        
        alert.title = @"Textview";
        alert.message = @"";
        alert.delegate = self;
        
        [alert addButtonWithTitle:@"Cancel"];
        [alert addButtonWithTitle:@"OK"];
        alert.tag=101;
        [alert setValue:txtView forKey:@"accessoryView"];
        //[alert addSubview:txtView];
        [alert show] ;
    }
    
    
    return YES;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    NSLog(@"My token is: %@", deviceToken);
    
    //    obj.put("GCM_ID", gcmId);
    //    obj.put("HP_TEL", mobileNo);
    //    obj.put("DEVICE_FLAG", "A");
    //    obj.put("TEST", "이인재입니다.");
    //    JSONObject resObj = new ServletRequester("registGCM.do").execute(obj).get();
    
    
    
    NSMutableString *deviceId = [NSMutableString string];
    const unsigned char* ptr = (const unsigned char*) [deviceToken bytes];
    
    for(int i = 0 ; i < 32 ; i++)
    {
        [deviceId appendFormat:@"%02x", ptr[i]];
    }
    
    NSLog(@"APNS Device Token: %@", deviceId);
    // deviceTok = deviceId;
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.DEVICE_TOK = deviceId;
    
    [[GlobalDataManager getgData] setGcmId:app.DEVICE_TOK];
    
    CallServer *res = [CallServer alloc];
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    
    
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    
    [param setValue:idForVendor forKey:@"HP_TEL"];
    [param setValue:app.DEVICE_TOK forKey:@"GCM_ID"];
    [param setObject:@"I" forKey:@"DEVICE_FLAG"];
    [param setObject:@"TEST" forKey:@"TEST"];
    
    //deviceId
    
    //R 수신
    
    NSString* str = [res stringWithUrl:@"registGCM.do" VAL:param];
    
    NSLog(@"APNS Device Tok: %@", app.DEVICE_TOK);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    if(application.applicationState == UIApplicationStateActive){
        NSString *sndPath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"wav" inDirectory:@"/"];
        CFURLRef sndURL = (CFURLRef)CFBridgingRetain([[NSURL alloc] initFileURLWithPath:sndPath]);
        AudioServicesCreateSystemSoundID(sndURL, &ssid);
        
        AudioServicesPlaySystemSound(ssid);
        
    }
    
    
    application.applicationIconBadgeNumber = 0;
    //NSDictionary *apsDictionary = [userInfo valueForKey:@"aps"];
    //NSString *grpCd            = [userInfo valueForKey:@"GRP_CD"];
    NSString *emcId            = [userInfo valueForKey:@"EMC_ID"];
    NSString *emcMsg           = [userInfo valueForKey:@"EMC_MSG"];
    NSString *code              = [userInfo valueForKey:@"CODE"];
    //NSString *message           = (NSString *)[apsDictionary valueForKey:(id)@"alert"];
    //NSLog(@"GRP_CD: %@",    grpCd);
    NSLog(@"EMC_ID: %@",    emcId);
    NSLog(@"EMC_MSG: %@",   emcMsg);
    NSLog(@"CODE: %@",      code);
    
    //GRP_CD  = grpCd;
    EMC_ID  = emcId;
    EMC_MSG = emcMsg;
    CODE    = code;
    
    //메세지 왼쪽 정렬을 위한 코드 삽입
    
    
    /*
     UITextView *txtView = nil ;
     //
     txtView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 80.0)];
     [txtView setBackgroundColor:[UIColor clearColor]];
     [txtView setTextAlignment:NSTextAlignmentLeft] ;
     [txtView setEditable:NO];
     [txtView setFont:[UIFont fontWithName:@"Avenir-Black" size:15]];
     [txtView setText:emcMsg];
     
     
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"[재난상황발생]"
     message:@"" delegate:self
     cancelButtonTitle:@"확인"
     otherButtonTitles:@"전화걸기", nil];
     
     [alert setValue:txtView forKey:@"accessoryView"];
     //[alert addSubview:txtView];
     [alert show] ;
     */
    
    //./UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 24.0, 250.0, 80.0)];
    //label.numberOfLines = 0;
    //label.textAlignment = NSTextAlignmentLeft;
    //label.backgroundColor = [UIColor clearColor];
    //label.textColor = [UIColor whiteColor];
    //label.text = emcMsg;
    // [alert addSubview:label];
    
    
    
    //UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"title" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    //----------------------------------------------------------------------------------
    
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
    //                                                message:emcMsg delegate:self
    //                                      cancelButtonTitle:@"확인"
    //                                      otherButtonTitles:@"전화걸기", nil];
    
    
    
    UITextView *txtView = nil ;
    //
    txtView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 250.0)];
    [txtView setBackgroundColor:[UIColor clearColor]];
    [txtView setTextAlignment:NSTextAlignmentLeft] ;
    [txtView setEditable:NO];
    [txtView setFont:[UIFont fontWithName:@"Avenir-Black" size:13]];
    [txtView setText:@"테스트합니다. \n어떻게 나오는지 확인하겠습니다.\n 이렇게 나오면 될까요?\n 확인부탁드립니다.\n 하지만 알러트창 제목부분을 어떻게 해야할지요. \n 흠 잘모르겠습니다."];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithFrame:CGRectMake(0, 0, 300, 550)];
    
    alert.title = @"Textview";
    alert.message = @"";
    alert.delegate = self;
    
    [alert addButtonWithTitle:@"Cancel"];
    [alert addButtonWithTitle:@"OK"];
    alert.tag=101;
    [alert setValue:txtView forKey:@"accessoryView"];
    //[alert addSubview:txtView];
    [alert show] ;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

//개인정보동의 alert 창 callback
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSLog(@";alert ?? %d",buttonIndex);
    if(alertView.tag==101)     // check alert by tag
    {
        if(buttonIndex ==1)
        {
            
        }else{
            
        }
    }else{
        if(buttonIndex ==1)
        {
            //
            CallServer *res = [CallServer alloc];
            
            
            NSMutableDictionary* param = [GlobalDataManager getAllData];
            
            
            
            NSString* str = [res stringWithUrl:@"invInfo.do" VAL:param];
        }else{
            exit(0);
        }
    }
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
