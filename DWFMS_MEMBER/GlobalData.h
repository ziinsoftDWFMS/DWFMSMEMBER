//
//  GlobalData.h
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 17..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import <Foundation/Foundation.h>

 static NSString *homedir= @"E:/applcation";
 static NSString *ServerIp=@"http://211.253.9.3:8080";
@interface GlobalData : NSObject{
    
    //    private String compCd;
    //    private String empNo;
    //    private String empNm;
    //    private String authInd;
    //    private String deptCd;
    //    private String hpTel;
    //    private ArrayList<String> auth;
    //    private static String ServerIp = "http://175.114.60.91:8081";// 개발
    //    //	private static String ServerIp = "http://61.102.223.71:8090"; // 인천공항운영
    //    //	private static String ServerIp = "http://61.102.223.80:8089"; //우운영
    //    private String inTime;
    //    private String outTime;
    //    private static String homedir = "D:/AIRapplication/";// 개발
    
//    NSString *compCd;
//    NSString *empNo;
//    NSString *empNm;
//    NSString *authInd;
//    NSString *deptCd;
//    NSString *hpTel;
//    NSString *ServerIp;
//    NSString *inTime;
//    NSString *outTime;
   
//    NSArray *auth;
}
+(NSString*) getServerIp;
+(NSString*) getHomedir;
@property(strong,nonatomic) NSString *compCd;
@property(strong,nonatomic) NSString *empNo;
@property(strong,nonatomic) NSString *empNm;
@property(strong,nonatomic) NSString *authInd;
@property(strong,nonatomic) NSString *deptCd;
@property(strong,nonatomic) NSString *hpTel;
@property(strong,nonatomic) NSString *inTime;
@property(strong,nonatomic) NSString *outTime;
@property(strong,nonatomic) NSArray *auth;
@property(strong,nonatomic) NSArray *gcmId;


@property(strong,nonatomic) NSMutableDictionary * cameraData;
@end
