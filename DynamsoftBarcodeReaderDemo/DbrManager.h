
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

@interface DbrManager : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>

@property long barcodeFormat;

@property (strong, nonatomic) NSDate *startRecognitionDate;

@property BOOL isPauseFramesComing;
@property BOOL isCurrentFrameDecodeFinished;

@property CGSize cameraResolution;

-(id)initWithLicense:(NSString *)license;

-(void)beginVideoSession;

-(AVCaptureSession*) getVideoSession;

-(void)setRecognitionCallback :(id)sender :(SEL)callback;

@end
