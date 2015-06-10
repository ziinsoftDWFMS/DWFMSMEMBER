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
    
   // returnData.put("session_COMP_CD", data.getCompCd().trim());
   // returnData.put("session_ID", data.getId());
   // returnData.put("session_ID_NM", data.getId_nm());
   // returnData.put("session_HP_TEL", data.getHpTel());
  //  {"result":"Y","data":{"LAST_DATE":"2015-06-10 22:09:44.207","CMT":"투너넌","CHG_SYSDT":"2015-06-05 03:04:04.31","INFO_YN":"Y","HP":"010-3219-8418","LAST_TEL":"0BF1E705-893E-4692-B1D9-8FCF63DB5114","INPUT_SYSDT":"2015-06-05 01:06:49.863","COMP_CD":"DW000","AL_YN":"Y","PW":"0JSYJ9uEcpQeeTaks/vMOw==","ID_NM":"김영석","COMPANY_NM":"","ID":"mogwa","CP":"--","ADDR":"   ","CODE":"01"},"rv":"s"}
    
    
    [self.getgData setCompCd:[data valueForKey:@"COMP_CD"]];
    [self.getgData setHpTel:idForVendor];
    [self.getgData setEmpNm:[data valueForKey:@"ID_NM"] ];
    [self.getgData setEmpNo:[data valueForKey:@"ID"]];
   

}
+ (void) initAuth:(NSArray *)data {
    NSMutableArray *tempAuth = [[NSMutableArray alloc] init];
    for(int i=0;i<[data count];i++){
        
        [tempAuth addObject:[[data objectAtIndex:i] valueForKey:@"WIN_CE"]];
        NSLog(@"??auth %d:%@",i,[[data objectAtIndex:i] valueForKey:@"WIN_CE"]);
        
    }
    [[self getgData] setAuth:tempAuth];
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
    [tempData setValue:[global empNo] forKey:@"session_ID"];
    [tempData setValue:[global empNm] forKey:@"session_ID_NM"];
    [tempData setValue:idForVendor forKey:@"session_HP_TEL"];
    [tempData setValue:@"DWFMS_MEMBER" forKey:@"APPTYPE"];
    
    NSLog(@"ddd");
    NSLog(@"ddd %d",[[tempData allKeys] count]);
    
    return tempData;
}


@end
