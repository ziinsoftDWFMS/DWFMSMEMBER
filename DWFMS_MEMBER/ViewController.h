//
//  ViewController.h
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 15..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZIINQRCodeReaderView.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet ZIINQRCodeReaderView *qrView;

- (void) setimage:(NSString*) path num:(NSString*)num;
- (void) setQRcode:(NSString*) data ;
@end

@interface UIWebView(JavaScriptAlert)
- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;
- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;
@end