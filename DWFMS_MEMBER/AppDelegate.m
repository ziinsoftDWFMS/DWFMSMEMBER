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
#import "Commonutil.h"
#import <CoreLocation/CoreLocation.h>
#import "ToastAlertView.h"
@interface AppDelegate ()

@end

@implementation AppDelegate{
    NSArray *_uuidList;
    BOOL isInside;
}


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
        CallServer *res = [CallServer alloc];
        UIDevice *device = [UIDevice currentDevice];
        NSString* idForVendor = [device.identifierForVendor UUIDString];
        
        
        NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
        
        [param setValue:idForVendor forKey:@"HP_TEL"];
        [param setValue:@"ffffffff" forKey:@"GCM_ID"];
        [param setObject:@"I" forKey:@"DEVICE_FLAG"];
        //R 수신
        
        NSString* str = [res stringWithUrl:@"memLoginByPhon.do" VAL:param];
        
        NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        NSLog(str);
        /*
         자동로그인 부분
         */
        if(     [@"s"isEqual:[jsonInfo valueForKey:@"rv"] ] )
        {
            if(     [@"Y"isEqual:[jsonInfo valueForKey:@"result"] ] )
            {
                NSDictionary *data = [jsonInfo valueForKey:(@"data")];
                [GlobalDataManager initgData:(data)];
            
                _uuidList = @[
                              [[NSUUID alloc] initWithUUIDString:[data valueForKey:@"BEACON_UUID"]]
                              //24DDF411-8CF1-440C-87CD-E368DAF9C93E
                              // you can add other NSUUID instance here.
                              ];
                
                
                for (int i = 0; i < [_uuidList count]; i++) {
                    NSLog(@"_uuidList  ");
                    
                    
                    /*********
                     NSUUID *uuid = [_uuidList objectAtIndex:i];
                     
                     NSUUID *beaconUUID = [[NSUUID alloc] initWithUUIDString:@"24DDF411-8CF1-440C-87CD-E368DAF9C93E"];
                     NSString *regionIdentifier = @"us.iBeaconModules";
                     CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beaconUUID identifier:regionIdentifier];
                     switch ([CLLocationManager authorizationStatus]) {
                     case kCLAuthorizationStatusAuthorizedAlways:
                     NSLog(@"Authorized Always");
                     break;
                     case kCLAuthorizationStatusAuthorizedWhenInUse:
                     NSLog(@"Authorized when in use");
                     break;
                     case kCLAuthorizationStatusDenied:
                     NSLog(@"Denied");
                     break;
                     case kCLAuthorizationStatusNotDetermined:
                     NSLog(@"Not determined");
                     break;
                     case kCLAuthorizationStatusRestricted:
                     NSLog(@"Restricted");
                     break;
                     
                     default:
                     break;
                     }
                     self.locationManager = [[CLLocationManager alloc] init];
                     if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                     [self.locationManager requestAlwaysAuthorization];
                     }
                     self.locationManager.distanceFilter = YES;
                     
                     self.locationManager.delegate = self;
                     self.locationManager.pausesLocationUpdatesAutomatically = NO;//pause상태에서의 스캔여부
                     [self.locationManager startMonitoringForRegion:beaconRegion];
                     [self.locationManager startRangingBeaconsInRegion:beaconRegion];
                     [self.locationManager startUpdatingLocation];
                     *******/
                }
                
            }
        }
        
        param = [[NSMutableDictionary alloc] init];
        
        [param setValue:idForVendor forKey:@"hp_tel"];
        
        //deviceIdb
        
        //R 수신
        
        str = [res stringWithUrl:@"searchPushMsg.do" VAL:param];
        
        
        NSLog(@"gcmmessage %@ ",str);
        
        [self  rcvAspnA:str];

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
    
    NSString* str = [res stringWithUrl:@"registMemGCM.do" VAL:param];
    
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
    
    //application.applicationIconBadgeNumber = 0;
    CallServer *res = [CallServer alloc];
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    
    
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    
    [param setValue:idForVendor forKey:@"hp_tel"];
    
    //deviceId
    
    //R 수신
    
    NSString* str = [res stringWithUrl:@"searchPushMsg.do" VAL:param];
    
    NSLog(@"gcmmessage %@ ",str);
   
    [[self main] rcvAspn:str];
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
}

//개인정보동의 alert 창 callback
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSLog(@";alert ?? %d",buttonIndex);
    if(alertView.tag==101)     // check alert by tag
    {
        if(buttonIndex ==1)
        {
            CallServer *res = [CallServer alloc];
            UIDevice *device = [UIDevice currentDevice];
            NSString* idForVendor = [device.identifierForVendor UUIDString];
            
            
            NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
            
            [param setValue:idForVendor forKey:@"hp_tel"];
            
            //deviceId
            
            //R 수신
            
            NSString* str = [res stringWithUrl:@"searchPushMsg.do" VAL:param];
            
            NSLog(@"gcmmessage %@ ",str);
            [[self main] rcvAspn:str];
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

- (void) rcvAspnA:(NSString*) jsonstring {
    NSLog(@"nslog");
    NSData *jsonData = [jsonstring dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
   
        
        UIAlertView *alert = [[UIAlertView alloc] initWithFrame:CGRectMake(0, 0, 300, 550)];
        
        alert.title = @"A/S작업결과";
        alert.message = [jsonInfo valueForKey:@"TITLE"];
        alert.delegate = self;
        
        [alert addButtonWithTitle:@"취소"];
        [alert addButtonWithTitle:@"확인"];
        alert.tag=101;
        //[alert addSubview:txtView];
        [alert show] ;
        
    
   
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    exit(0);
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
