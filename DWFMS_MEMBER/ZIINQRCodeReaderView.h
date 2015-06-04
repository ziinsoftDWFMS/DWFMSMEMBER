#import <UIKit/UIKit.h>

@class ZIINQRCodeReaderView;

@protocol ZIINQRCodeReaderViewDelegate <NSObject>

//결과는 callback
- (void)reader:(ZIINQRCodeReaderView *)reader didScanResult:(NSString *)result;

@end

@interface ZIINQRCodeReaderView : UIView

@property (nonatomic, weak)   id<ZIINQRCodeReaderViewDelegate> delegate;

@property (nonatomic, assign) CGRect innerViewRect;     //스캐너 기본 정사각형

@property (nonatomic, getter = isAutoStartEnabled) BOOL autoStart;      //자동시작여부, YES

/**
 *  카메라 사용여부
 *
 *  @return YES:可用  NO:不可用
 */
+ (BOOL)isCameraAvailable;

/**
 *  스캔 수동호출 시작
 */
- (void)startScanning;
- (void)isHiddenCam;
/**
 *  끝
 */
- (void)stopScanning;

@end

