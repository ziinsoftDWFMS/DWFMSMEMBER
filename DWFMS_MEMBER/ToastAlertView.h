//
//  ToastAlertView.h
//  DWFMS
//
//  Created by youngseok Kim on 2015. 6. 13..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface ToastAlertView : UIView

@property (strong, nonatomic) NSString *text;

+ (void)showToastInParentView: (UIView *)parentView withText:(NSString *)text withDuaration:(float)duration;

@end
