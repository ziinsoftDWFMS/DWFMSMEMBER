#import "ZIINQRCodeReaderView.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "AppDelegate.h"

@interface ZIINQRCodeReaderView()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) CAShapeLayer     *overlay;

@property (nonatomic, strong) AVCaptureSession *session;        //스캔 session

@property (nonatomic, strong) CADisplayLink    *displayLink;    //검색바 위치를 새로고침

@property (strong, nonatomic) UIImageView      *imgLine;

@property (nonatomic, strong) NSString         *scannedValue;

@end


@implementation ZIINQRCodeReaderView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self addOverlay];
        [self setUp];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addOverlay];
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    /*
    self.autoStart = YES;
    
    //비디오 장치 설정
    AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //입력 값
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
    
    //출력 값
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    //
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    self.session = [[AVCaptureSession alloc] init];
    
    if(videoInput)
        [self.session addInput:videoInput];
    else
        NSLog(@"Error: %@", error);
    [self.session addOutput:metadataOutput];
    
    //
    metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    previewLayer.frame = self.layer.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:previewLayer];
    
    if (self.isAutoStartEnabled){
        [self startScanning];
    }
     */
    
}


- (void)drawRect:(CGRect)rect
{
    CGRect innerRect = CGRectInset(rect, 50, 50);
    
    CGFloat minSize = MIN(innerRect.size.width, innerRect.size.height);
    if (innerRect.size.width != minSize) {
        innerRect.origin.x   += 50;
        innerRect.size.width = minSize;
    }
    else if (innerRect.size.height != minSize) {
        innerRect.origin.y   += (rect.size.height - minSize) / 2 - rect.size.height / 6;
        innerRect.size.height = minSize;
    }
    CGRect offsetRect = CGRectOffset(innerRect, 0, 15);
    
    self.innerViewRect = offsetRect;
    
    _overlay.path = [UIBezierPath bezierPathWithRect:offsetRect].CGPath;
    
    [self addOtherLay:offsetRect];
    [self addRightAngleLay:offsetRect];
}

- (CADisplayLink *)displayLink {
    if (_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
        _displayLink.frameInterval = 120;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        _displayLink.paused = YES;
    }
    
    return _displayLink;
}

- (UIImageView *)imgLine {
    if (_imgLine == nil) {
        _imgLine = [[UIImageView alloc] init];
        _imgLine.image = [UIImage imageNamed:@"QRCodeScanLine"];
        _imgLine.frame = CGRectMake(self.innerViewRect.origin.x, self.innerViewRect.origin.y, CGRectGetWidth(self.innerViewRect), 10);
        [self addSubview:_imgLine];
    }
    return _imgLine;
}

//
- (void)handleDisplayLink:(CADisplayLink *)displayLink
{
    [self scanAnimate];
}

//
- (void)scanAnimate
{
    /*
    self.imgLine.frame = CGRectMake(self.innerViewRect.origin.x, self.innerViewRect.origin.y, CGRectGetWidth(self.innerViewRect), 10);
    [UIView animateWithDuration:2 animations:^{
        _imgLine.frame = CGRectMake(_imgLine.frame.origin.x, _imgLine.frame.origin.y + self.innerViewRect.size.height - 6, _imgLine.frame.size.width, _imgLine.frame.size.height);
    }];
     */
}

#pragma mark - public methods
+ (BOOL)isCameraAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    return [videoDevices count] > 0;
}

- (void)startScanning
{
    [self.session startRunning];
    self.displayLink.paused = NO;
}

- (void)stopScanning
{
    [self.session stopRunning];
    self.displayLink.paused = YES;
}

#pragma mark - capture delegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0) {
        //[session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = metadataObjects.firstObject ;

        self.scannedValue = metadataObject.stringValue;
        
        NSLog(@"capture output ===>   %@",metadataObject.stringValue);
        
        if ([self.delegate respondsToSelector:@selector(reader: didScanResult:)]) {
            [self.delegate reader:self didScanResult:self.scannedValue];
        }
        [self stopScanning];
        //----------------------------------- audio add, scan result return, navigate
        
        
        
        
        self.hidden = YES;
        
        //-----------------------------------
        AppDelegate * ad =  [[UIApplication sharedApplication] delegate] ;
        NSLog(@" appdeligate %@",ad);
        [[ad main] setQRcode:self.scannedValue];
    }
}

#pragma mark - Private Methods

- (void)isHiddenCam{
    
    self.autoStart = YES;
    
    //비디오 장치 설정
    AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //입력 값
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
    
    //출력 값
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    //
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    self.session = [[AVCaptureSession alloc] init];
    
    if(videoInput)
        [self.session addInput:videoInput];
    else
        NSLog(@"Error: %@", error);
    [self.session addOutput:metadataOutput];
    
    //
    metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    
    previewLayer.frame = self.layer.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:previewLayer];
    
    if ([videoCaptureDevice respondsToSelector:@selector(setVideoZoomFactor:)]) {
        NSLog(@"Error: %@", @"1");
        if ([ videoCaptureDevice lockForConfiguration:nil]) {
            NSLog(@"Error: %@", @"2");
            float zoomFactor = videoCaptureDevice.activeFormat.videoZoomFactorUpscaleThreshold;
            [videoCaptureDevice setVideoZoomFactor:1.0];
            [videoCaptureDevice unlockForConfiguration];
        }
    }
    
    if (self.isAutoStartEnabled){
        [self startScanning];
    }

}


//SCAN 레이어 내부 설정
- (void)addOverlay
{
    _overlay = [[CAShapeLayer alloc] init];
    _overlay.backgroundColor = [UIColor redColor].CGColor;
    _overlay.fillColor       = [UIColor clearColor].CGColor;
    _overlay.strokeColor     = [UIColor lightGrayColor].CGColor;
    _overlay.lineWidth       = 1;
    _overlay.lineDashPattern = @[@50,@0];
    _overlay.lineDashPhase   = 1;
    _overlay.opacity         = 1.0;
    [self.layer addSublayer:_overlay];
}

//SCAN 레이어 테두리 설정
- (void)addOtherLay:(CGRect)rect
{
    UIColor *fillColor = [UIColor blackColor];
    float opacity = 0.5;
    
    UIBezierPath *topPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, CGRectGetWidth(self.bounds), rect.origin.y)];
    
    UIBezierPath *leftPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, rect.origin.y, rect.origin.x, CGRectGetHeight(self.bounds) - rect.origin.y)];
    
    UIBezierPath *rightPath = [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x + CGRectGetWidth(rect), rect.origin.y, CGRectGetWidth(self.bounds) - rect.origin.x - CGRectGetWidth(rect), CGRectGetHeight(rect))];
    
    UIBezierPath *bottomPath = [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x, rect.origin.y + CGRectGetHeight(rect), CGRectGetWidth(self.bounds) - rect.origin.x, CGRectGetHeight(self.bounds) - rect.origin.y - CGRectGetHeight(rect))];
    
    [self addShapeLayerWithPath:topPath fillColor:fillColor opacity:opacity];
    [self addShapeLayerWithPath:leftPath fillColor:fillColor opacity:opacity];
    [self addShapeLayerWithPath:rightPath fillColor:fillColor opacity:opacity];
    [self addShapeLayerWithPath:bottomPath fillColor:fillColor opacity:opacity];

}

//Right angle
- (void)addRightAngleLay:(CGRect)rect
{
    UIColor *fillColor = [UIColor redColor];
    
    UIBezierPath *topLeftVerPath = [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x -1, rect.origin.y -1, 3, 15)];
    
    UIBezierPath *topLeftHorPath = [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x -1, rect.origin.y -1, 15, 3)];
    
    UIBezierPath *topRightVerPath = [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x + CGRectGetWidth(rect) -2, rect.origin.y - 1, 3, 15)];
    
    UIBezierPath *topRithtHorPath = [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x + CGRectGetWidth(rect) - 14, rect.origin.y-1, 15, 3)];
    
    UIBezierPath *bottomLeftVerPath = [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x -1, rect.origin.y + CGRectGetHeight(rect) - 14, 3, 15)];
    
    UIBezierPath *bottomLeftHorPath = [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x -1, rect.origin.y + CGRectGetHeight(rect) -2, 15, 3)];
    
    UIBezierPath *bottomRithtVerPath = [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x + CGRectGetWidth(rect) -2, rect.origin.y +CGRectGetHeight(rect) -15, 3, 15)];
    
    UIBezierPath *bottomRithtHorPath = [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x + CGRectGetWidth(rect) -14, rect.origin.y +CGRectGetHeight(rect) -2, 15, 3)];
    
    [self addShapeLayerWithPath:topLeftVerPath fillColor:fillColor opacity:1.0];
    [self addShapeLayerWithPath:topLeftHorPath fillColor:fillColor opacity:1.0];
    [self addShapeLayerWithPath:topRightVerPath fillColor:fillColor opacity:1.0];
    [self addShapeLayerWithPath:topRithtHorPath fillColor:fillColor opacity:1.0];
    [self addShapeLayerWithPath:bottomLeftVerPath fillColor:fillColor opacity:1.0];
    [self addShapeLayerWithPath:bottomLeftHorPath fillColor:fillColor opacity:1.0];
    [self addShapeLayerWithPath:bottomRithtVerPath fillColor:fillColor opacity:1.0];
    [self addShapeLayerWithPath:bottomRithtHorPath fillColor:fillColor opacity:1.0];
    
}


- (void)addShapeLayerWithPath:(UIBezierPath *)path fillColor:(UIColor *)color opacity:(float)opacity {
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.fillColor     = color.CGColor;
    shapeLayer.opacity       = opacity;
    shapeLayer.path          = path.CGPath;
    [self.layer addSublayer:shapeLayer];
}

@end
