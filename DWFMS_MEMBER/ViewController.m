//
//  ViewController.m
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 15..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import "ViewController.h"
#import "CallServer.h"
#import "GlobalData.h"
#import "GlobalDataManager.h"
#import "Commonutil.h"
#import "ZIINQRCodeReaderView.h"
#import "AppDelegate.h"
#import "ToastAlertView.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()

@end

@implementation ViewController{
    NSArray *_uuidList;
    //NSArray *_stateCategory;
}
NSString *beaconYN = @"Y";
NSString *bluetoothYN = @"N";
NSString *senderinfo = @"";
NSString *titleinfo = @"";
NSString *EmcCode = @"";
NSString *beaconKey = @"";

NSString *viewType =@"LOGOUT";
NSMutableArray *beaconDistanceList;//Using the Beacon Value set set set~~~
NSMutableArray *beaconList;
NSMutableArray *beaconBatteryLevelList;
int seqBeacon = 0;
int beaconSkeepCount = 0;
int beaconSkeepMaxCount = 1;

CLBeaconRegion *beaconRegion;


//재난정보를 전송하기 위한 기본정보
NSString *strUSER_ID = @"";
NSString *strCOMP_CD = @"";
NSString *strCOMP_NM = @"";
NSString *strHP = @"";
NSString *strID_NM = @"";
NSString *strCOMPANY_NM = @"";




BOOL navigateYN;
NSString* idForVendor;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [GlobalData setbeacon:@"F"];
    
    AppDelegate * ad =  [[UIApplication sharedApplication] delegate] ;
    [ad setMain:self];
    
    NSLog(@" appdeligate %@",ad);
    [self.webView setDelegate:self];
    
    CallServer *res = [CallServer alloc];
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    
    
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    NSLog(@" appdeligate push device tok :: %@",ad.DEVICE_TOK);
    [param setValue:idForVendor forKey:@"HP_TEL"];
    [param setValue:ad.DEVICE_TOK forKey:@"GCM_ID"];
    [param setObject:@"I" forKey:@"DEVICE_FLAG"];
    
    //deviceId
    
    //R 수신
    
    NSString* str = [res stringWithUrl:@"memLoginByPhon.do" VAL:param];
    
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    NSLog(str);
    
    NSString *urlParam=@"";
    NSString *server = [GlobalData getServerIp];
    NSString *pageUrl = @"/requester.do";
    NSString *callUrl = @"";
    /*
     자동로그인 부분
     */
    if(     [@"s"isEqual:[jsonInfo valueForKey:@"rv"] ] )
    {
        if(     [@"Y"isEqual:[jsonInfo valueForKey:@"result"] ] )
        {
            
            NSDictionary *data = [jsonInfo valueForKey:(@"data")];
            [GlobalDataManager initgData:(data)];
            
            strUSER_ID = [data valueForKey:@"ID"];
            strCOMP_CD = [data valueForKey:@"COMP_CD"];
            strCOMP_NM = [data valueForKey:@"COMP_NM"];
            strHP = [data valueForKey:@"HP"];
            strID_NM = [data valueForKey:@"ID_NM"];
            strCOMPANY_NM = [data valueForKey:@"COMPANY_NM"];
            
            beaconYN = [data valueForKey:@"BEACON_YN"];
            
            NSMutableDictionary * session =[GlobalDataManager getAllData];
            
            urlParam = [Commonutil serializeJson:session];
            
            NSString * text =@"본 어플리케이션은 원할한 서비스를\n제공하기 위해 휴대전화번호등의 개인정보를 사용합니다.\n[개인정보보호법]에 의거해 개인정보 사용에 대한 \n사용자의 동의를 필요로 합니다.\n개인정보 사용에 동의하시겠습니까?\n";
            NSLog(@"urlParam %@",urlParam);
            callUrl = [NSString stringWithFormat:@"%@%@#home",server,pageUrl];
            
            NSLog(@"callUrl %@",callUrl);
            if(![@"Y" isEqualToString:[data valueForKey:@"INFO_YN"]])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                      message:text delegate:self
                                                      cancelButtonTitle:@"취소"
                                                      otherButtonTitles:@"동의", nil];
                [alert show];
            }
            
            viewType = @"LOGIN";
            
            //_uuidList = [GlobalData sharedDefaults].supportedUUIDs;
            _uuidList = @[
                          [[NSUUID alloc] initWithUUIDString:[data valueForKey:@"BEACON_UUID"]]
                          //24DDF411-8CF1-440C-87CD-E368DAF9C93E
                          // you can add other NSUUID instance here.
                          ];
            //_stateCategory = @[@(RECOProximityUnknown),
            //                   @(RECOProximityImmediate),
            //                   @(RECOProximityNear),
            //                   @(RECOProximityFar)];
            
            [_uuidList enumerateObjectsUsingBlock:^(NSUUID *uuid, NSUInteger idx, BOOL *stop) {
                NSString *identifier = @"us.iBeaconModules";
                
                [self registerBeaconRegionWithUUID:uuid andIdentifier:identifier];
            }];
            //NSLog(@"@@@@!!!!!!!!!!!!!!!!!!!!!!!!!@@@@@@@");
            //[self startRanging];
            
            
            
            
            
            
            
            //Beacon set-------------------------------------------------------------------
            
            
            
            //NSUUID *uuid = [_uuidList objectAtIndex:0];
            
            //NSUUID *beaconUUID = [[NSUUID alloc] initWithUUIDString:uuid];
            ////NSString *regionIdentifier = @"us.iBeaconModules";
            //CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beaconUUID identifier:regionIdentifier];
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
            self.locationManager.pausesLocationUpdatesAutomatically = YES;//pause상태에서의 스캔여부
            [self.locationManager startMonitoringForRegion:beaconRegion];
            [self.locationManager startRangingBeaconsInRegion:beaconRegion];
            [self.locationManager startUpdatingLocation];
            
            
            
            
            
            //------------------------------------------------------------------------------
            
        }else{
            
            urlParam = [NSString stringWithFormat:@"HP_TEL=%@&GCM_ID=%@&DEVICE_FLAG=I",idForVendor,ad.DEVICE_TOK];
            callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
            
        }
        
    }
    
    NSLog(@"??callurl:%@",callUrl);
    
    NSURL *url=[NSURL URLWithString:callUrl];
    NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
    [requestURL setHTTPMethod:@"POST"];
    [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
    [self.webView loadRequest:requestURL];
    NSLog(@"??????? urlParam %@",urlParam);
    NSLog(@"??????? requestURL %@",requestURL);
  
}

- (BOOL)detectBluetooth
{
    if ([@"N"isEqual:beaconYN]) {
        return FALSE;
    }
    if(!self.blueToothManager)
    {
        // Put on main queue so we can call UIAlertView from delegate callbacks.
        self.blueToothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    [self centralManagerDidUpdateState:self.blueToothManager]; // Show initial state
    
    switch(self.blueToothManager.state)
    {
        case CBCentralManagerStateResetting: return FALSE; break;
        case CBCentralManagerStateUnsupported: return FALSE; break;
        case CBCentralManagerStateUnauthorized: return FALSE; break;
        case CBCentralManagerStatePoweredOff: return FALSE; break;
        case CBCentralManagerStatePoweredOn: return TRUE; break;
        default: return FALSE; break;
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *stateString = nil;
    switch(self.blueToothManager.state)
    {
        case CBCentralManagerStateResetting: stateString = @"The connection with the system service was momentarily lost, update imminent."; break;
        case CBCentralManagerStateUnsupported: stateString = @"The platform doesn't support Bluetooth Low Energy."; break;
        case CBCentralManagerStateUnauthorized: stateString = @"The app is not authorized to use Bluetooth Low Energy."; break;
        case CBCentralManagerStatePoweredOff: stateString = @"Bluetooth is currently powered off."; break;
        case CBCentralManagerStatePoweredOn: stateString = @"Bluetooth is currently powered on and available to use."; break;
        default: stateString = @"State unknown, update imminent."; break;
    }
    NSLog(@"bluetoothstate :: %@", stateString);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}



-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //javascript => document.location = "somelink://yourApp/form_Submitted:param1:param2:param3";
    //scheme : somelink
    //absoluteString : somelink://yourApp/form_Submitted:param1:param2:param3
    NSLog(@"?? %@",@"in.................");
    NSString *requesturl1 = [[request URL] scheme];
    if([@"toapp" isEqual:requesturl1])
    {
        NSString *requesturl2 = [[request URL] absoluteString];
        NSString *decoded = [requesturl2 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSArray* list = [decoded componentsSeparatedByString:@":"];
        NSString *type  = [list objectAtIndex:1];
        NSLog(@"?? %@",type);
        
        //Webview : web call case
        
        if([@"login" isEqual:type])
        {
            
            [self login:[decoded substringFromIndex:([type length]+7)]];
            
        } else if ([@"QRun" isEqual:type]) {
            NSLog(@"QR START");
            
            
            _qrView.hidden = NO;
            _qrView.isHiddenCam;
            NSLog(@"QR end");
            //[self performSegueWithIdentifier:@"callQRScan" sender:self];
        } else if([@"callImge" isEqual:type]){
            [self callImge:[decoded substringFromIndex:([type length]+7)]];
        } else if([@"logout" isEqual:type]){
            [self logout];
        } else if ([@"setSession" isEqual:type]) {
            NSString *scriptParameter = [NSString stringWithFormat:@"setsession('%@&reCall=%@');", [decoded substringFromIndex:([type length]+7)],[decoded substringFromIndex:([type length]+7)]];
            NSLog(@"setSession : call Script value : %@", scriptParameter);
            //json data return
            
            
            
            [webView stringByEvaluatingJavaScriptFromString:scriptParameter];
        } else if ([@"reCall" isEqual:type]) {
            NSString *scriptString = [NSString stringWithFormat:@"%@;", [decoded substringFromIndex:([type length]+7)]];
            NSLog(@"reCall : call Script value : %@", scriptString);
            
            [webView stringByEvaluatingJavaScriptFromString:scriptString];
        }else if([@"callbackwelcome"isEqual:type]) {
            
            [self callbackwelcome];
        }else if([@"setJobMode" isEqual:type]) {
            NSLog(@"############### ~~~ %@", [decoded substringFromIndex:([type length]+7)]);
            viewType = [decoded substringFromIndex:([type length]+7)];
            
        } else if ([@"getPageInfo" isEqual:type]) {
            NSString *scriptString = [NSString stringWithFormat:@"%@;", [decoded substringFromIndex:([type length]+7)]];
            NSLog(@"getPageInfo : call Script value : %@", scriptString);
            
            [self senderInfoText:[decoded substringFromIndex:([type length]+7)]];
            
            NSString *returnString = [NSString stringWithFormat:@"setSenderInfo('%@','%@');",titleinfo,senderinfo];
            NSLog(@"scriptString => %@", returnString);
            [webView stringByEvaluatingJavaScriptFromString:returnString];
            
            NSString *arg = [decoded substringFromIndex:([type length]+7)];
            if ([@"7" isEqual:arg]) {
                returnString = [NSString stringWithFormat:@"setLocationTitle('내용 : ');"];
            } else {
                returnString = [NSString stringWithFormat:@"setLocationTitle('장소 : ');"];
            }
            viewType = @"EMC";
            [webView stringByEvaluatingJavaScriptFromString:returnString];
        } else if ([@"sendEmc" isEqual:type]) {
            [self sendEmc:[decoded substringFromIndex:([type length]+7)]];
        
        }else if([@"CancelAlert"isEqual:type]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithFrame:CGRectMake(0, 0, 300, 550)];
            
            alert.title = @"알림";
            alert.message = @"취소 하시겠습니까?";
            alert.delegate = self;
            
            [alert addButtonWithTitle:@"아니오"];
            [alert addButtonWithTitle:@"예"];
            alert.tag=102;
            //[alert addSubview:txtView];
            [alert show] ;

            [self callbackwelcome];
        }
//        CancelAlert
    }
    
    
    return YES;
}

-(void) senderInfoText:(NSString*) arg{
    if ([@"1" isEqual:arg]) {
        senderinfo = @"[화재]";
        EmcCode = @"FR01";
    } else if ([@"2" isEqual:arg]) {
        senderinfo = @"[누수/동파]";
        EmcCode = @"WT01";
    } else if ([@"3" isEqual:arg]) {
        senderinfo = @"[정전/누전]";
        EmcCode = @"KW01";
    } else if ([@"4" isEqual:arg]) {
        senderinfo = @"[안전사고]";
        EmcCode = @"HA01";
    } else if ([@"5" isEqual:arg]) {
        senderinfo = @"[가스]";
        EmcCode = @"GS01";
    } else if ([@"6" isEqual:arg]) {
        senderinfo = @"[승강기고장]";
        EmcCode = @"EV01";
    } else if ([@"7" isEqual:arg]) {
        senderinfo = @"[긴급공지]";
        EmcCode = @"EM01";
    }
    titleinfo = [NSString stringWithFormat:@"%@%@", senderinfo, @"발신"];
    senderinfo = [NSString stringWithFormat:@"%@%@", senderinfo, [[GlobalDataManager getgData] empNo]];
    NSLog(@"~~~~~~~~~~~~~~~ titleinfo : %@", titleinfo);
    NSLog(@"~~~~~~~~~~~~~~~ senderinfo : %@", senderinfo);
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
    }else if(alertView.tag==102)     // check alert by tag
    {
        if(buttonIndex ==1)
        {
            //mWebView.loadUrl("javascript:accept()");
            NSString *scriptParameter = [NSString stringWithFormat:@"accept();"];
            NSLog(@"setSession : call Script value : %@", scriptParameter);
            //json data return
            [_webView stringByEvaluatingJavaScriptFromString:scriptParameter];
        }else{//취소
            //mWebView.loadUrl("javascript:cancel()");
            NSString *scriptParameter = [NSString stringWithFormat:@"cancel();"];
            NSLog(@"setSession : call Script value : %@", scriptParameter);
            //json data return
            [_webView stringByEvaluatingJavaScriptFromString:scriptParameter];
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
//Error시 실행
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"IDI FAIL");
}

//WebView 시작시 실행
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"START LOAD");
    
    
}

//WebView 종료 시행
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"FNISH LOAD");
    if([FLAG isEqual:@"LOAD"]){
        NSData *jsonData = [JSONPARAM dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        
        NSString *scriptString = [NSString stringWithFormat:@"callIosASDetail('%@','%@');",[jsonInfo valueForKey:@"JOB_CD"], [jsonInfo valueForKey:@"COMP_CD"]];
        NSLog(@"scriptString => %@", scriptString);
        [self.webView stringByEvaluatingJavaScriptFromString:scriptString];
        FLAG = @"END";
    }
    
}

//script => app funtion
-(void) login:(NSString*) data{
    NSError *error;
    
    NSLog(@"?logindata %@",data);
    NSData *sessionjsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *sessionjsonInfo = [NSJSONSerialization JSONObjectWithData:sessionjsonData options:kNilOptions error:&error];
    
    if(     [@"s"isEqual:[sessionjsonInfo valueForKey:@"rv"] ] )
    {
        if(     [@"Y"isEqual:[sessionjsonInfo valueForKey:@"result"] ] )
        {
            viewType = @"LOGIN";
            NSDictionary *sessiondata = [sessionjsonInfo valueForKey:(@"data")];
            [GlobalDataManager initgData:(sessiondata)];
            
            [GlobalDataManager initgData:(data)];
            
            strUSER_ID = [data valueForKey:@"ID"];
            strCOMP_CD = [data valueForKey:@"COMP_CD"];
            strCOMP_NM = [data valueForKey:@"COMP_NM"];
            strHP = [data valueForKey:@"HP"];
            strID_NM = [data valueForKey:@"ID_NM"];
            strCOMPANY_NM = [data valueForKey:@"COMPANY_NM"];
            
            beaconYN = [data valueForKey:@"BEACON_YN"];
            
            
            NSString * text =@"본 어플리케이션은 원할한 서비스를\n제공하기 위해 휴대전화번호등의 개인정보를 사용합니다.\n[개인정보보호법]에 의거해 개인정보 사용에 대한 \n사용자의 동의를 필요로 합니다.\n개인정보 사용에 동의하시겠습니까?\n";
            if(![@"Y" isEqualToString:[sessiondata valueForKey:@"INFO_YN"]])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:text delegate:self
                                                      cancelButtonTitle:@"취소"
                                                      otherButtonTitles:@"동의", nil];
                [alert show];
            }
            
            NSLog(@"gcmid = %@",[[GlobalDataManager getgData] gcmId]);
            
            CallServer *res = [CallServer alloc];
            UIDevice *device = [UIDevice currentDevice];
            NSString* idForVendor = [device.identifierForVendor UUIDString];
            
            
            NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
            
            [param setValue:idForVendor forKey:@"HP_TEL"];
            [param setValue:[[GlobalDataManager getgData] gcmId] forKey:@"GCM_ID"];
            [param setObject:@"I" forKey:@"DEVICE_FLAG"];
            [param setObject:@"TEST" forKey:@"TEST"];
            
            //deviceId
            
            //R 수신
            
            NSString* str = [res stringWithUrl:@"registMemGCM.do" VAL:param];
            
            NSString *server = [GlobalData getServerIp];
            NSString *pageUrl = @"/requester.do";
            NSString *callUrl = @"";
            
            
            
            callUrl = [NSString stringWithFormat:@"%@%@#home",server,pageUrl];
            
            NSLog(@"pageUrl = %@",pageUrl);
            
            NSURL *url=[NSURL URLWithString:callUrl];
            NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
            [self.webView loadRequest:requestURL];
            
            //_uuidList = [GlobalData sharedDefaults].supportedUUIDs;
            _uuidList = @[
                          [[NSUUID alloc] initWithUUIDString:[sessiondata valueForKey:@"BEACON_UUID"]]
                          //24DDF411-8CF1-440C-87CD-E368DAF9C93E
                          // you can add other NSUUID instance here.
                          ];
            //_stateCategory = @[@(RECOProximityUnknown),
            //                   @(RECOProximityImmediate),
            //                   @(RECOProximityNear),
            //                   @(RECOProximityFar)];
            
            [_uuidList enumerateObjectsUsingBlock:^(NSUUID *uuid, NSUInteger idx, BOOL *stop) {
                NSString *identifier = @"us.iBeaconModules";
                
                [self registerBeaconRegionWithUUID:uuid andIdentifier:identifier];
            }];
            
            //    [self registerBeaconRegionWithUUID:uuid andIdentifier:identifier];
            //}];
            //NSLog(@"@@@@!!!!!!!!!!!!!!!!!!!!!!!!!@@@@@@@");
            //[self startRanging];
            //Beacon set-------------------------------------------------------------------
            
            
            
            //NSUUID *uuid = [_uuidList objectAtIndex:0];
            
            //NSUUID *beaconUUID = [[NSUUID alloc] initWithUUIDString:uuid];
            //NSString *regionIdentifier = @"us.iBeaconModules";
            //CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beaconUUID identifier:regionIdentifier];
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
            self.locationManager.pausesLocationUpdatesAutomatically = YES;//pause상태에서의 스캔여부
            [self.locationManager startMonitoringForRegion:beaconRegion];
            [self.locationManager startRangingBeaconsInRegion:beaconRegion];
            [self.locationManager startUpdatingLocation];
            
            
            
            
            
            //------------------------------------------------------------------------------
            
            
        }else{
            [ToastAlertView showToastInParentView:self.view withText:@"아이디와 패스워드를 확인해주세요." withDuaration:5.0];
        }
    }else{
        
    }
    
    
    
}

//script => app funtion
-(void) sendEmc:(NSString*) data{
    NSLog(@"????? sendEmc data: %@",data);
    NSArray *locationImages = [data componentsSeparatedByString:@"//"];
    NSString *argLocation = [locationImages objectAtIndex:0];
    NSString *argImages = [locationImages objectAtIndex:1];
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    
    [param setValue:argLocation forKey:@"location"];
    [param setValue:argImages forKey:@"save_IMGS"];
    [param setValue:EmcCode forKey:@"code"];
    [param setValue:@"S" forKey:@"gubun"];
    [param setObject:idForVendor forKey:@"deviceId"];
    
    [param setValue:strUSER_ID forKey:@"empno"];
    [param setValue:strCOMP_CD forKey:@"comp_cd"];
    [param setValue:strCOMP_NM forKey:@"comp_nm"];
    [param setValue:strHP forKey:@"hp"];
    [param setValue:strID_NM forKey:@"empno_nm"];
    [param setValue:strCOMPANY_NM forKey:@"company_nm"];
    [param setValue:@"ipjusa" forKey:@"dept_cd"];
    [param setValue:strCOMPANY_NM forKey:@"dept_nm"];
    [param setValue:beaconKey forKey:@"beacon_key"];
    
    
    //deviceId
    
    //R 수신
    CallServer *res = [CallServer alloc];
    NSString* str = [res stringWithUrl:@"emcInfoPush_member.do" VAL:param];
    
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    NSLog(@"?? %@",str);
    
    if(     [@"SUCCESS"isEqual:[jsonInfo valueForKey:@"RESULT"] ] )
    {
        //전송완료 되었음.....
        [ToastAlertView showToastInParentView:self.view withText:@"전송이 완료되었습니다." withDuaration:3.0];
        
        
        NSString* callActionGuide = @"reqeuster.do#home";
        
        if (![@"EM01" isEqual:EmcCode]) {
            NSMutableDictionary *sessiondata =[GlobalDataManager getAllData];
            
            callActionGuide = [NSString stringWithFormat:@"%@/emcActionGuide_member.do?COMP_CD=%@&CODE=%@&BEACON_KEY=%@&REDIRECT_URL=requester.do#home", [GlobalData getServerIp], [sessiondata valueForKey:@"session_COMP_CD"], EmcCode, beaconKey];
        }
        
        NSString *urlParam=@"";
        NSURL *url=[NSURL URLWithString:callActionGuide];
        NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
        [requestURL setHTTPMethod:@"POST"];
        [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
        [self.webView loadRequest:requestURL];
        
        NSLog(@"??????? urlParam %@",callActionGuide);
        
    }
    
    
    
}


-(void) callImge:(NSString*) data{
    NSLog(@"callimge??");
    NSArray* list = [data componentsSeparatedByString:@"&"];
    
    
    NSMutableDictionary * temp =[[NSMutableDictionary alloc] init];
    
    for(int i =0;i<[list count];i++){
        NSArray* listTemp =   [[list objectAtIndex:i] componentsSeparatedByString:@"="];
        [temp setValue:[listTemp objectAtIndex:1] forKey:[listTemp objectAtIndex:0]];
        
        NSLog(@" key %@  value %@ ",[listTemp objectAtIndex:0],[listTemp objectAtIndex:1]);
    }
    [[GlobalDataManager getgData]setCameraData:temp];
    
    [self performSegueWithIdentifier:@"CameraCall" sender:self];
}



- (void) setimage:(NSString*) path num:(NSString*)num{
    //       NSString * searchWord = @"/";
    //    NSString * replaceWord = @"\\\\";
    //    path =  [path stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];
    NSLog(@"ddd path %@ num %@",path,num);
    
    NSString *scriptString = [NSString stringWithFormat:@"setimge('%@','%@');",path,num];
    NSLog(@"scriptString => %@", scriptString);
    [self.webView stringByEvaluatingJavaScriptFromString:scriptString];
}


-(void) callWelcome{
    NSError *error;
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    if([@"" isEqualToString:[[GlobalDataManager getgData] inTime]])
    {
        [param setObject:@"-" forKey:@"INTIME"];
    }else{
        
        [param setObject:[[GlobalDataManager getgData] inTime]  forKey:@"INTIME"];
    }
    
    if([@"" isEqualToString:[[GlobalDataManager getgData] outTime]])
    {
        [param setObject:@"-" forKey:@"OUTTIME"];
    }else{
        [param setObject:[[GlobalDataManager getgData] outTime]  forKey:@"OUTTIME"];
        
    }
    
    
    [param setObject:[[GlobalDataManager getgData] empNm] forKey:@"EMPNM"];
    
    
    //     NSString *jsonInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"saltfactory",@"name",@"saltfactory@gmail.com",@"e-mail", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    if (error) {
        NSLog(@"error : %@", error.localizedDescription);
        return;
    }
    
    NSString* searchWord = @"\"";
    NSString* replaceWord = @"";
    //   jsonString =  [jsonString stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];
    
    
    
    jsonString =  [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSLog(@"jsonString => %@", jsonString);
    
    NSString *escaped = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"escaped string :\n%@", escaped);
    
    searchWord = @"%20";
    replaceWord = @"";
    escaped =  [escaped stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];
    searchWord = @"%0A";
    replaceWord = @"";
    escaped =  [escaped stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];
    
    
    NSString *decoded = [escaped stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"decoded string :\n%@", decoded);
    
    NSString *scriptString = [NSString stringWithFormat:@"welcome(%@);",decoded];
    NSLog(@"scriptString => %@", scriptString);
    [self.webView stringByEvaluatingJavaScriptFromString:scriptString];
}

-(void) logout{
    viewType = @"LOGOUT";
    viewType = @"LOGOUT";
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    NSString *server = [GlobalData getServerIp];
    NSString *pageUrl = @"/requester.do";
    NSString *callUrl = @"";
    NSString * urlParam = [NSString stringWithFormat:@"HP_TEL=%@&GCM_ID=%@&DEVICE_FLAG=I",idForVendor,@"22222222"];
    
    
    
    
    callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
    
    NSURL *url=[NSURL URLWithString:callUrl];
    NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
    [requestURL setHTTPMethod:@"POST"];
    [requestURL setHTTPBody:[urlParam dataUsingEncoding:NSUTF8StringEncoding]];
    [self.webView loadRequest:requestURL];
}
-(void)callbackwelcome{
    if([viewType isEqualToString:@"LOGOUT"]){
        return;
    }
    
    CallServer *res = [CallServer alloc];
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    
    
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    
    [param setValue:idForVendor forKey:@"HP_TEL"];
    [param setValue:[[GlobalDataManager getgData] gcmId] forKey:@"GCM_ID"];
    [param setObject:@"I" forKey:@"DEVICE_FLAG"];
    
    //deviceId
    
    //R 수신
    
    NSString* str = [res stringWithUrl:@"memLoginByPhon.do" VAL:param];
    
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    NSLog(str);
    
    if(     [@"s"isEqual:[jsonInfo valueForKey:@"rv"] ] )
    {
        if(     [@"Y"isEqual:[jsonInfo valueForKey:@"result"] ] )
        {
            
            NSString * oldempon = [[GlobalDataManager getgData]empNo];
            NSDictionary *data = [jsonInfo valueForKey:(@"data")];
            [GlobalDataManager initgData:(data)];
            NSArray * timelist = [jsonInfo objectForKey:@"inout"];
            [GlobalDataManager setTime:[timelist objectAtIndex:0]];
            NSArray * authlist = [jsonInfo objectForKey:@"auth"];
            [GlobalDataManager initAuth:authlist];
            
            
            if(![oldempon isEqualToString:[[GlobalDataManager getgData] empNo] ]){
                [self logout];
            }
            else{
                [self callWelcome];
            }
            
        }
        else{
            NSLog(@"다른폰에서 로그인");
        }
    }
}



- (void)registerBeaconRegionWithUUID:(NSUUID *)proximityUUID andIdentifier:(NSString*)identifier {
    beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:identifier];
    
    //_rangedRegions[_Region] = [NSArray array];
}
//- (void) startRanging {
//    NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~StartRanging~~~~~");
//    if (![RECOBeaconManager isRangingAvailable]) {
//        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~return : not not not not isRangingAvailable");
//        return;
//    }
//    NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!~~~~~");
//    [_rangedRegions enumerateKeysAndObjectsUsingBlock:^(RECOBeaconRegion *recoRegion, NSArray *beacons, BOOL *stop) {
//        [_recoManager startRangingBeaconsInRegion:recoRegion];
//    }];
//}

//- (void) stopRanging; {
//    [_rangedRegions enumerateKeysAndObjectsUsingBlock:^(RECOBeaconRegion *recoRegion, NSArray *beacons, BOOL *stop) {
//        [_recoManager stopRangingBeaconsInRegion:recoRegion];
//    }];
//}

#pragma mark - RECOBeaconManager delegate methods

//- (void)recoManager:(RECOBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(RECOBeaconRegion *)region {
//    NSLog(@"didRangeBeaconsInRegion: %@, ranged %lu beacons", region.identifier, (unsigned long)[beacons count]);

//    if((unsigned long)[beacons count] > 0){
//        [GlobalData setbeacon:@"T"];
//    }

//    _rangedRegions[region] = beacons;
//    [_rangedBeacon removeAllObjects];

//    NSMutableArray *allBeacons = [NSMutableArray array];

//    NSArray *arrayOfBeaconsInRange = [_rangedRegions allValues];
//    [arrayOfBeaconsInRange enumerateObjectsUsingBlock:^(NSArray *beaconsInRange, NSUInteger idx, BOOL *stop){
//        [allBeacons addObjectsFromArray:beaconsInRange];
//    }];

//    [_stateCategory enumerateObjectsUsingBlock:^(NSNumber *range, NSUInteger idx, BOOL *stop){
//        NSArray *beaconsInRange = [allBeacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", [range intValue]]];

//        if ([beaconsInRange count]) {
//            _rangedBeacon[range] = beaconsInRange;
//        }
//    }];
//[self.tableView reloadData];
//}

//- (void)locationManager:(CLLocationManager *)manager rangingDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
//    NSLog(@"rangingDidFailForRegion: %@ error: %@", region.identifier, [error localizedDescription]);
//    [GlobalData setbeacon:@"F"];
//}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [manager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    [self.locationManager startUpdatingLocation];
    
    NSLog(@"You entered the region.");
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [manager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
    [self.locationManager stopUpdatingLocation];
    
    NSLog(@"You exited the region.");
}

- (void)locationManager:(CLLocationManager *)manager rangingDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"rangingDidFailForRegion: %@ error: %@", region.identifier, [error localizedDescription]);
    [GlobalData setbeacon:@"F"];
}
-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSString *message = @"";
    
    self.beacons = beacons;
    [self beaconSet];
    
    
    
    if(beacons.count > 0) {
        [GlobalData setbeacon:@"T"];
        message = @"~~~~~~Yes beacons are nearby";
    } else {
        [GlobalData setbeacon:@"F"];
        message = @"~~~~~~No beacons are nearby";
    }
    
    NSLog(@"%@", message);
}


- (void) beaconSet {
    
    if (beaconSkeepCount < beaconSkeepMaxCount) {
        
        beaconSkeepCount = beaconSkeepCount + 1;
        NSLog(@"Beacon Access Skeep ~~~~~~~~~~~~~~~~~~~~ [%d]", beaconSkeepCount);
        return;
    }
    beaconSkeepCount = 0;
    
    NSLog(@"beacon set ~!~~~~~~~~~");
    beaconDistanceList = [NSMutableArray array];
    beaconList = [NSMutableArray array];
    beaconBatteryLevelList = [NSMutableArray array];
    
    for (int i = 0 ; i < self.beacons.count ; i++) {
        CLBeacon *beacon = (CLBeacon*)[self.beacons  objectAtIndex:i];
        //CLBeacon *beacon = self.beacons.firstObject;
        NSString *proximityLabel = @"";
        
        switch (beacon.proximity) {
            case CLProximityFar:
                proximityLabel = @"Far";
                break;
            case CLProximityNear:
                proximityLabel = @"Near";
                break;
            case CLProximityImmediate:
                proximityLabel = @"Immediate";
                break;
            case CLProximityUnknown:
                proximityLabel = @"Unknown";
                break;
        }
        
        //NSLog(@"proximityLabel[%lu] : %@", (unsigned long)i, proximityLabel);
        
        //NSString *detailLabel = [NSString stringWithFormat:@"Major: %d, Minor: %d, RSSI: %d, UUID: %@, ACC: %2fm",
        //                         beacon.major.intValue, beacon.minor.intValue, (int)beacon.rssi, beacon.proximityUUID.UUIDString, beacon.accuracy];
        
        NSString *detailLabel = [NSString stringWithFormat:@"Major: %d, Minor: %d, RSSI: %d, ACC: %2fm",
                                 beacon.major.intValue, beacon.minor.intValue, (int)beacon.rssi, beacon.accuracy];
        
        //NSLog(@"beacon detail contents[%lu] : %@", (unsigned long)i, detailLabel);
        
        [beaconDistanceList insertObject:[NSString stringWithFormat:@"%2fm", beacon.accuracy] atIndex:i];
        [beaconList insertObject:[NSString stringWithFormat:@"%@%d%d", beacon.proximityUUID.UUIDString, beacon.major.intValue, beacon.minor.intValue] atIndex:i];
        
        
        
        
    }
    NSLog(@"!!!!! ~~~ %@", viewType);
    if([@"EMC" isEqual:viewType]) {
        [self getNearBeaconLocation];
    }
    
    //초기화
    beaconDistanceList = [NSMutableArray array];
    beaconList = [NSMutableArray array];
    beaconBatteryLevelList = [NSMutableArray array];
    
    self.beacons = nil;
    //NSLog(@"Beacon count [%lu]", (unsigned long)self.beacons.count);
}


- (void) getNearBeaconLocation {
    NSLog(@"!!!!! getNearBeaconLocation Exec~~~");
    NSString *nearBeacon = [self getNearBeacon];
    
    if (![@"" isEqual:nearBeacon]) {
        beaconKey = [NSString stringWithFormat:@"%@", nearBeacon];;
        
        NSMutableDictionary *sessiondata =[GlobalDataManager getAllData];
        
        NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
        
        [param setValue:nearBeacon forKey:@"BEACON_KEY"];
        [param setValue:[sessiondata valueForKey:@"session_COMP_CD"] forKey:@"COMP_CD"];
        //R 수신
        CallServer *res = [CallServer alloc];
        NSString* str = [res stringWithUrl:@"getLocationName.do" VAL:param];
        
        NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        NSLog(@"?? %@",str);
        
        if (![@"EM01" isEqual:EmcCode]) {
            
            NSString *locationName = [NSString stringWithFormat:@"%@",[jsonInfo valueForKey:@"LOCATION_NAME"]];
            if(![@""isEqual:locationName ])
            {
                NSString *scriptString = [NSString stringWithFormat:@"setLocationName('%@');",locationName];
                NSLog(@"scriptString => %@", scriptString);
                [self.webView stringByEvaluatingJavaScriptFromString:scriptString];
            }
        }
    } else {
        return;
    }
    
    
    
}

- (NSString *) getNearBeacon {
    int nearBeaconSeq = 0;
    NSString *nearBeaconValue = @"";
    if(beaconDistanceList.count > 0) {
        for (int i = 1 ; i < beaconDistanceList.count ; i++) {
            if ([beaconDistanceList objectAtIndex:nearBeaconSeq] > [beaconDistanceList objectAtIndex:i]) {
                nearBeaconSeq = i;
            }
        }
        nearBeaconValue = [beaconList objectAtIndex:nearBeaconSeq];
    }
    //초기화
    beaconDistanceList = [NSMutableArray array];
    beaconList = [NSMutableArray array];
    beaconBatteryLevelList = [NSMutableArray array];
    return nearBeaconValue;
}

- (void) rcvAspn:(NSString*) jsonstring {
    NSLog(@"nslog");
    NSData *jsonData = [jsonstring dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    
   //if(     [@"AS_RES_FOR_REQ"isEqual:[jsonInfo valueForKey:@"TASK_CD"] ] )
   // {
        //mWebView.loadUrl(GlobalData.getServerIp()+"/DWFMSASDetail.do?JOB_CD="+gcmIntent.getStringExtra("JOB_CD")+"&GYULJAE_YN=N&sh_DEPT_CD="+ gcmIntent.getStringExtra("DEPT_CD")+"&sh_JOB_JISI_DT="+ gcmIntent.getStringExtra("JOB_JISI_DT"));
        
        NSString *server = [GlobalData getServerIp];
        NSString *pageUrl = @"/searchas.do";
        NSString *callUrl = @"";
        callUrl = [NSString stringWithFormat:@"%@%@",server,pageUrl];
        FLAG = @"LOAD";
        JSONPARAM = jsonstring;
        NSURL *url=[NSURL URLWithString:callUrl];
        NSMutableURLRequest *requestURL=[[NSMutableURLRequest alloc]initWithURL:url];
        
        [self.webView loadRequest:requestURL];
    
    
    
    
    
   // }
   
}

@end
@implementation UIWebView (JavaScriptAlert)
- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
    [alert show];
}



static BOOL diagStat = NO;
static NSInteger bIdx = -1;
- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame {
    UIAlertView *confirmDiag = [[UIAlertView alloc] initWithTitle:nil
                                                          message:message
                                                         delegate:self
                                                cancelButtonTitle:@"취소"
                                                otherButtonTitles:@"확인", nil];
    
    [confirmDiag show];
    bIdx = -1;
    
    while (bIdx==-1) {
        //[NSThread sleepForTimeInterval:0.2];
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
    }
    if (bIdx == 0){
        diagStat = NO;
    }
    else if (bIdx == 1) {
        diagStat = YES;
    }
    return diagStat;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    bIdx = buttonIndex;
}
@end

