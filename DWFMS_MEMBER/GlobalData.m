//
//  GlobalData.m
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 17..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import "GlobalData.h"

@implementation GlobalData

//@synthesize compCd;
+(NSString*) getServerIp{
    return ServerIp;
}

+(NSString*) getHomedir{
    return homedir;
}
@end
