//
//  Commonutil.m
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 20..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import "Commonutil.h"

@implementation Commonutil

+(NSString *) serializeJson:(NSDictionary*) jsondata{
    
    NSArray* keys = jsondata.allKeys;
    
    NSLog(@"keys cont %d",keys.count);
    
    NSString * urlParam =@"";
    for (int i=0; i<keys.count; i++) {
        
        if(i==0){
             urlParam = [NSString stringWithFormat:@"%@=%@",[keys objectAtIndex:i],[jsondata objectForKey:[keys objectAtIndex:i]]];
        }else{
             urlParam = [NSString stringWithFormat:@"%@&%@=%@",urlParam,[keys objectAtIndex:i],[jsondata objectForKey:[keys objectAtIndex:i]]];
        }
       
        NSLog(@"key %@  value %@",[keys objectAtIndex:i],[jsondata objectForKey:[keys objectAtIndex:i]] );
    }
    
    
    return urlParam;
}

@end
