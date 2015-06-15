//
//  CameraViewController.m
//  DWFMS
//
//  Created by 김향기 on 2015. 5. 26..
//  Copyright (c) 2015년 DWFMS. All rights reserved.
//

#import "CameraViewController.h"
#import "AppDelegate.h"
#import "GlobalData.h"
#import "GlobalDataManager.h"


@implementation CameraViewController



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@"??callcamera1");
    NSMutableDictionary * cData =  [[GlobalDataManager getgData]cameraData] ;
    makeFilename =[NSString stringWithFormat:@"%@_%@.jpg",[cData valueForKey:@"key"],[cData valueForKey:@"num"]];
    
    NSString * searchWord = @"-";
    NSString * replaceWord = @"";
    makeFilename =  [makeFilename stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];
    searchWord = @":";
    replaceWord = @"";
    makeFilename =  [makeFilename stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];
    searchWord = @" ";
    replaceWord = @"";
    makeFilename =  [makeFilename stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];
    searchWord = @"'";
    replaceWord = @"";
    makeFilename =  [makeFilename stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];
    
    searchWord = @"'";
    replaceWord = @"";
    makeFilename =  [makeFilename stringByReplacingOccurrencesOfString:searchWord withString:replaceWord];
    
    NSLog(@"filename %@",makeFilename);
//    filepath = [NSString stringWithFormat:@"resources/App_Company/%@/%@.jpg",[[GlobalDataManager getgData] compCd],[cData valueForKey:@"type"],filename];
     filepath = [NSString stringWithFormat:@"resources/App_Company/%@/%@/",[[GlobalDataManager getgData] compCd],[cData valueForKey:@"type"]];
    num = [cData valueForKey:@"num"];
    
}
- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@" 00 %@ ",(getImage ? @"YES" : @"NO"));
    if(!getImage){
    self.open;
    }
}
-  (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) open
{
    getImage = NO;
    UIActionSheet *actionsheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"취소"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"사진 촬영", @"앨범에서 가져오기", nil];
    
    [actionsheet showInView:self.view];
    
}
#pragma mark UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *imagepickerController = [[UIImagePickerController alloc] init];
    [imagepickerController setDelegate:self];
    [imagepickerController setAllowsEditing:YES];
    NSLog(@" 11 %@ ",(getImage ? @"YES" : @"NO"));
    if(!getImage){
        if(buttonIndex == 0){
            [imagepickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
            
            [self presentModalViewController:imagepickerController animated:YES];
        }
        else if(buttonIndex == 1){
            getImage =YES;
            [imagepickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            
            [self presentModalViewController:imagepickerController animated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
 
    }
    else{
        
        if(buttonIndex == 0){
            
            UIImageWriteToSavedPhotosAlbum([imageView image], self, @selector(saveImage:didFinishedSavingWhithError:contextInfo:),nil);
            
            NSLog(@"?? save??? ");
          
            
        }
        [self fileUp];
        

    }
    
}

#pragma mark UIImagePickerContoller Delegate
- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
     imageView.image = image;
    float hi =  image.size.height;
    float wh = image.size.width;
    
    NSLog(@"?? hi %f  wh %f ",hi,wh);
    NSData *dataObj = UIImageJPEGRepresentation(image, 0.3);
    
    NSLog(@"?? size? %d ",dataObj.length);
     NSLog(@" 22 %@ ",(getImage ? @"YES" : @"NO"));
    [self dismissModalViewControllerAnimated:YES];
    if(!getImage){
        getImage = YES;
         NSLog(@" 33 %@ ",(getImage ? @"YES" : @"NO"));
        
        
        UIActionSheet *isSave = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"저장 안함"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"사진 저장", nil];
        [isSave showInView:self.view];
    }
    else{
        [self fileUp];
    }
    
}

-(void) saveImage:(UIImage*) image didFinishedSavingWhithError:(NSError*) error contextInfo:(void *) contextInfo
{
    if(error){
        NSLog(@" image save error!!!!");
    }else{
        NSLog(@" image save!!!!");
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

-(void) fileUp{
    
    NSLog(@"???filepath %@ " ,filepath);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30.0f];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"YAGOM_Boundary";
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSString *senders = @"yagom";
    NSString *receiver = @"prettyWoman";
    
    NSDictionary *params = @{@"sender": senders, @"receiver" : receiver};
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    //UIImage *imageToUpload = [UIImage imageNamed:@"/Library/Desktop Pictures/Moon.jpg"];
    NSData *imageData = UIImageJPEGRepresentation([imageView image], 0.3);
    
    NSLog(@"image length : %lu",(unsigned long)[imageData length]);
    
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"imageToLove\"; filename=\"%@\"\r\n", makeFilename]dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    NSString *makeUrl = [NSString stringWithFormat:@"%@/resources/filedown.jsp?path=%@",[GlobalData getServerIp],filepath];
    NSLog(@"make url = %@",makeUrl);
    [request setURL:[NSURL URLWithString:makeUrl]];
    
    // start upload
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    [connection start];
}
// connection 실행되는동안 실행되는 메소드 (현재는 file upload되는 %를 log에 출력하는 소스 적용중)
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    NSLog(@"%.2f Percent complete", (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite * 100.0f);
}

// connection 실행을 맞치고 aalert 메지시장 출력
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"dd123 %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
     AppDelegate * ad =  [[UIApplication sharedApplication] delegate] ;
    [[ad main]setimage:[NSString stringWithFormat:@"%@%@",filepath,makeFilename] num:num];
     [self dismissViewControllerAnimated:YES completion:nil];
}


@end
