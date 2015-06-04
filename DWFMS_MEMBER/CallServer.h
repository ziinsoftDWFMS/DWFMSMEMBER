//
//  CallServer.h
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 16..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CallServer : NSObject

- (void) test:(NSString*)url  ;
- (NSString *)stringWithUrl:(NSString *)url VAL:(NSMutableDictionary*)value;


@end
