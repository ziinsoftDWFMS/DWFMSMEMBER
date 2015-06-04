//
//  GlobalDataManager.m
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 18..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import "GlobalDataManager.h"
#import <UIKit/UIKit.h>

@implementation GlobalDataManager

+ (GlobalData*) getgData {
    
    NSLog(@"dddd?? %@",gData);
    
    if(gData == nil)
    {
     
        gData = [GlobalData alloc];
        
        NSLog(@"make??/?? %@",gData);
         return gData;
    }
    return gData;
}
+ (void) initgData:(NSDictionary *)data {
    NSLog(@" ?? initgData %@",self.getgData);
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    
    [self.getgData setCompCd:[data valueForKey:@"COMP_CD"]];
    [self.getgData setHpTel:idForVendor];
    [self.getgData setAuthInd:[data valueForKey:@"AUTH_IND"]];
    [self.getgData setEmpNm:[data valueForKey:@"EMPNO_NM"] ];
    [self.getgData setEmpNo:[data valueForKey:@"EMPNO"]];
    [self.getgData setDeptCd:[data valueForKey:@"DEPT_CD"]];

}
+ (void) initAuth:(NSArray *)data {
    NSMutableArray *tempAuth = [[NSMutableArray alloc] init];
    for(int i=0;i<[data count];i++){
        
        [tempAuth addObject:[[data objectAtIndex:i] valueForKey:@"WIN_CE"]];
        NSLog(@"??auth %d:%@",i,[[data objectAtIndex:i] valueForKey:@"WIN_CE"]);
        
    }
    [[self getgData] setAuth:tempAuth];
}
+ (void) setTime:(NSDictionary *)data {
    
    NSArray *keys = [data allKeys];
    GlobalData *global =[self getgData];
    if([keys containsObject:@"tdayout"]){
        [global setOutTime:[data valueForKey:@"tdayout"]];
    }else{
         [global setOutTime:@"-"];
    }
    
    if([keys containsObject:@"tdayin"]){
        
        [global setInTime:[data valueForKey:@"tdayin"]];
    }else{
        
        if(![keys containsObject:@"ydayout"] && [keys containsObject:@"ydayin"]){
            [global setInTime:[data valueForKey:@"ydayin"]];
        }else{
             [global setInTime:@"-"];
        }
    }
    
}
+ (NSMutableDictionary *) getAllData{
    GlobalData *global =[self getgData];
//    returnData.put("session_COMP_CD", data.getCompCd());
//    returnData.put("session_EMPNO", data.getEmpNo());
//    returnData.put("session_EMPNO_NM", data.getEmpNm());
//    returnData.put("session_AUTH_IND", data.getAuthInd());
//    returnData.put("session_DEPT_CD", data.getDeptCd());
//    returnData.put("session_HP_TEL", data.getHpTel());
//    returnData.put("APPTYPE", "DWFMS");
    
    
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    
    NSMutableDictionary * tempData = [[NSMutableDictionary alloc] init];
    
    [tempData setValue:[global compCd] forKey:@"session_COMP_CD"];
    [tempData setValue:[global empNo] forKey:@"session_EMPNO"];
    [tempData setValue:[global empNm] forKey:@"session_EMPNO_NM"];
    [tempData setValue:[global authInd] forKey:@"session_AUTH_IND"];
    [tempData setValue:[global deptCd] forKey:@"session_DEPT_CD"];
    [tempData setValue:idForVendor forKey:@"session_HP_TEL"];
    [tempData setValue:@"DWFMS" forKey:@"APPTYPE"];
    
    NSLog(@"ddd");
    NSLog(@"ddd %d",[[tempData allKeys] count]);
    
    return tempData;
}

+ (NSString * ) getAuth{
    NSArray *authlist = [[self getgData] auth];
    NSString *retauth=@"";
    for(int i = 0 ; i<[authlist count];i++){
     
        if(i==0){
            retauth = [authlist objectAtIndex:i];
        }else{
            retauth = [NSString stringWithFormat:@"%@,%@",retauth,[authlist objectAtIndex:i]];
        }
    }
    return retauth;
}
@end
