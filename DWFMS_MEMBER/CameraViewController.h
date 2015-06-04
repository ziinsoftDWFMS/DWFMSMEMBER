//
//  CameraViewController.h
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 26..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UIViewController<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    IBOutlet UIImageView *imageView;
    NSString * filepath;
    NSString * num;
    BOOL getImage;
    NSString *makeFilename;
}

@end
