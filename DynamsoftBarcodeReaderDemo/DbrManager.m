
#import "DbrManager.h"
#import <DynamsoftBarcodeReader/DynamsoftBarcodeReader.h>

@implementation DbrManager
{
    AVCaptureSession *m_videoCaptureSession;
    BarcodeReader *m_barcodeReader;
    
    SEL m_recognitionCallback;
    id m_recognitionReceiver;
}

@synthesize barcodeFormat;
@synthesize startRecognitionDate;
@synthesize isPauseFramesComing;
@synthesize isCurrentFrameDecodeFinished;
@synthesize cameraResolution;

-(id)initWithLicense:(NSString *)license{
    self = [super init];
    
    if(self)
    {
        m_videoCaptureSession = nil;
        m_barcodeReader = [[BarcodeReader alloc] initWithLicense:license];
        
        isPauseFramesComing = NO;
        isCurrentFrameDecodeFinished = YES;
        
        barcodeFormat = [Barcode UNKNOWN];
        startRecognitionDate = nil;
        
        m_recognitionReceiver = nil;
    }
    
    return self;
}

-(id)init{
    return [self initWithLicense:@""];
}

-(void)beginVideoSession {
    AVCaptureDevice *inputDevice = [self getAvailableCamera];
    
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput
                                          deviceInputWithDevice:inputDevice
                                          error:nil];
    
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    dispatch_queue_t queue;
    queue = dispatch_queue_create("dbrCameraQueue", NULL);
    [captureOutput setSampleBufferDelegate:self queue:queue];
    
    // Enable continuous autofocus
    if ([inputDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        NSError *error = nil;
        if ([inputDevice lockForConfiguration:&error]) {
            inputDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            [inputDevice unlockForConfiguration];
        }
    }
    
    // Enable AutoFocusRangeRestriction
     if([inputDevice respondsToSelector:@selector(isAutoFocusRangeRestrictionSupported)] &&
        inputDevice.autoFocusRangeRestrictionSupported) {
         if([inputDevice lockForConfiguration:nil]) {
             inputDevice.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNear;
             [inputDevice unlockForConfiguration];
         }
     }
    
    [captureOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
    if(captureInput == nil || captureOutput == nil)
    {
        return;
    }
    
    m_videoCaptureSession = [[AVCaptureSession alloc] init];
    [m_videoCaptureSession addInput:captureInput];
    [m_videoCaptureSession addOutput:captureOutput];
    
    if ([m_videoCaptureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080])
    {
        [m_videoCaptureSession setSessionPreset :AVCaptureSessionPreset1920x1080];
        cameraResolution.width = 1920;
        cameraResolution.height = 1080;
    }
    else if ([m_videoCaptureSession canSetSessionPreset:AVCaptureSessionPreset1280x720])
    {
        [m_videoCaptureSession setSessionPreset :AVCaptureSessionPreset1280x720];
        cameraResolution.width = 1280;
        cameraResolution.height = 720;
    }
    else if([m_videoCaptureSession canSetSessionPreset:AVCaptureSessionPreset640x480])
    {
        [m_videoCaptureSession setSessionPreset :AVCaptureSessionPreset640x480];
        cameraResolution.width = 640;
        cameraResolution.height = 480;
    }
    
    [m_videoCaptureSession startRunning];
}

-(AVCaptureSession*) getVideoSession {
    return m_videoCaptureSession;
}

-(void)setRecognitionCallback :(id)sender :(SEL)callback {
    m_recognitionReceiver = sender;
    m_recognitionCallback = callback;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;
{
    @autoreleasepool {
        if(isPauseFramesComing == YES || isCurrentFrameDecodeFinished == NO) return;
        
        isCurrentFrameDecodeFinished = NO;
        
        void *imageData = NULL;
        uint8_t *copyToAddress;
        
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        OSType pixelFormat = CVPixelBufferGetPixelFormatType(imageBuffer);
        
        if (!(pixelFormat == '420v' || pixelFormat == '420f'))
        {
            isCurrentFrameDecodeFinished = YES;
            return;
        }
        
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        int numPlanes = (int)CVPixelBufferGetPlaneCount(imageBuffer);
        int bufferSize = (int)CVPixelBufferGetDataSize(imageBuffer);
        int imgWidth = (int)CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
        int imgHeight = (int)CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
        
        if(numPlanes < 1)
        {
            isCurrentFrameDecodeFinished = YES;
            return;
        }
        
        uint8_t *baseAddress = (uint8_t *) CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
        size_t bytesToCopy = CVPixelBufferGetHeightOfPlane(imageBuffer, 0) * CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
        imageData = malloc(bytesToCopy);
        copyToAddress = (uint8_t *) imageData;
        memcpy(copyToAddress, baseAddress, bytesToCopy);
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
        
        NSData *buffer = [NSData dataWithBytesNoCopy:imageData length:bufferSize freeWhenDone:YES];
        
        startRecognitionDate = [NSDate date];
        
        // read frame using Dynamsoft Barcode Reader in async manner
        [m_barcodeReader readSingleAsync:buffer width:imgWidth height:imgHeight barcodeFormat: barcodeFormat sender:m_recognitionReceiver onComplete:m_recognitionCallback];
    }
}

-(AVCaptureDevice *)getAvailableCamera {
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices) {
        if (device.position == AVCaptureDevicePositionBack) {
            captureDevice = device;
            break;
        }
    }
    
    if (!captureDevice)
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    return captureDevice;
}

@end
