//
//  GlobalDataManager.h
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 18..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalData.h"

static GlobalData *gData;

@interface GlobalDataManager : NSObject




+ (GlobalData*) getgData ;
+ (void) initgData:(NSDictionary *)data ;
+ (void) initAuth:(NSArray *)data ;
+ (void) setTime:(NSDictionary *)data ;
+ (NSMutableDictionary *) getAllData;
+ (NSString * ) getAuth;
@end
