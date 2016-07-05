
#import "ViewController.h"
#import "BarcodeTypesTableViewController.h"
#import "DbrManager.h"
#import <DynamsoftBarcodeReader/DynamsoftBarcodeReader.h>

@interface ViewController ()

@end

@implementation ViewController
{
    BOOL m_isFlashOn;
}

@synthesize cameraPreview;
@synthesize previewLayer;

@synthesize rectLayerImage;

@synthesize dbrManager;
@synthesize flashButton;
@synthesize detectDescLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    //register notification for UIApplicationDidBecomeActiveNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    //init DbrManager with Dynamsoft Barcode Reader mobile license
    dbrManager = [[DbrManager alloc] initWithLicense:@"4B182CDC982B922A94EDB1CAE852139F"];
    [dbrManager setRecognitionCallback:self :@selector(onReadImageBufferComplete:)];
    [dbrManager beginVideoSession];
    
    [self configInterface];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didBecomeActive:(NSNotification *)notification;
{
    if(dbrManager.isPauseFramesComing == NO)
        [self turnFlashOn:m_isFlashOn];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    dbrManager.isPauseFramesComing = NO;
    [self turnFlashOn:m_isFlashOn];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) turnFlashOn: (BOOL) on {
    // validate whether flashlight is available
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (device != nil && [device hasTorch] && [device hasFlash]){
            [device lockForConfiguration:nil];
            
            if (on == YES) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                [flashButton setImage:[UIImage imageNamed:@"flash_on"] forState:UIControlStateNormal];
                [flashButton setTitle:NSLocalizedString(@"flash-on", @"flash on string") forState:UIControlStateNormal];
                
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                [flashButton setImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];
                [flashButton setTitle:NSLocalizedString(@"flash-off", @"flash off string") forState:UIControlStateNormal];
            }
            
            [device unlockForConfiguration];
        }
    }
}

- (IBAction)onFlashButtonClick:(id)sender {
    
    m_isFlashOn = m_isFlashOn == YES ? NO : YES;
    
    [self turnFlashOn:m_isFlashOn];
}

- (void) custmizeAC : (UIAlertController *) ac
{
    if(ac == nil) return;
    
    NSArray *viewArray = [[[[[[[[[[[[ac view] subviews] firstObject] subviews] firstObject] subviews] firstObject] subviews] firstObject] subviews] firstObject] subviews];
    UILabel *alertTitle = viewArray[0];
    UILabel *alertMessage = viewArray[1];
    alertTitle.textAlignment = NSTextAlignmentLeft;
    alertMessage.textAlignment = NSTextAlignmentLeft;
}

- (IBAction)onAboutInfoClick:(id)sender {
    dbrManager.isPauseFramesComing = YES;
    
    NSString *title = NSLocalizedString(@"about-alert-title", @"about alert title string");
    NSString *message = NSLocalizedString(@"about-alert-content", @"about alert content string");
    NSString *overviewButtonString = NSLocalizedString(@"about-alert-overivew-button", @"about alert overivew button string");
    NSString *okButtonString = NSLocalizedString(@"about-alert-ok-button", @"about alert ok button string");
    

    if ([UIAlertController class])
    {
        [self configAndShowAboutAlertController:title message:message overviewButtonString:overviewButtonString okButtonString:okButtonString];
    }
    else{
        [self configAndShowAboutAlertView: title message:message overviewButtonString:overviewButtonString okButtonString:okButtonString];
    }
}

- (void) configAndShowAboutAlertController : (NSString *) title
                                    message: (NSString *) message
                       overviewButtonString: (NSString *) overviewButtonString
                             okButtonString: (NSString *) okButtonString
{
    UIAlertController * ac=   [UIAlertController
                               alertControllerWithTitle:title
                               message:message
                               preferredStyle:UIAlertControllerStyleAlert];
    
    [self custmizeAC:ac];
    
    UIAlertAction* linkAction = [UIAlertAction actionWithTitle:overviewButtonString style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                 {
                                     [self openOverviewPage];
                                     dbrManager.isPauseFramesComing = NO;
                                 }];
    [ac addAction:linkAction];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:okButtonString
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    dbrManager.isPauseFramesComing = NO;
                                }];
    
    [ac addAction:yesButton];
    
    [self presentViewController:ac animated:YES completion:nil];
}

- (void) configAndShowAboutAlertView : (NSString *) title
                              message: (NSString *) message
                 overviewButtonString: (NSString *) overviewButtonString
                       okButtonString: (NSString *) okButtonString
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:overviewButtonString
                                          otherButtonTitles:okButtonString, nil];
    
    [alert show];
}


- (void) openOverviewPage{
    NSString *urlString = NSLocalizedString(@"about-alert-overivew-link", @"about alert overivew link string");
    NSURL *url = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    NSString *title = alertView.title;
    
    if([title isEqualToString: NSLocalizedString(@"about-alert-title", @"about alert title string")])
    {
        if(buttonIndex == 0)
        {
            [self openOverviewPage];
        }
        
        dbrManager.isPauseFramesComing = NO;
    }
    else if([title isEqualToString: NSLocalizedString(@"reslut-alert-title", @"reslut alert title string")])
    {
        dbrManager.isCurrentFrameDecodeFinished = YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showBarcodeTypes"]) {
        UIBarButtonItem *newBackButton =
        [[UIBarButtonItem alloc] initWithTitle:@""
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
        
        [[self navigationItem] setBackBarButtonItem:newBackButton];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        BarcodeTypesTableViewController *destViewController = segue.destinationViewController;
        
        if(destViewController != nil)
            destViewController.mainView = self;
        
        [self turnFlashOn:NO];
        
        dbrManager.isPauseFramesComing = YES;
    }
}

-(void) onReadImageBufferComplete:(ReadResult *) readResult{
    if(readResult.barcodes == nil || dbrManager.isPauseFramesComing == YES)
    {
        dbrManager.isCurrentFrameDecodeFinished = YES;
        return;
    }
    
    double timeInterval = [dbrManager.startRecognitionDate timeIntervalSinceNow] * -1;
    
    Barcode *barcode = (Barcode *)readResult.barcodes[0];
    
    CGFloat top = FLT_MAX;
    CGFloat left = FLT_MAX;
    
    for (int i = 0; i < [barcode.cornerPoints count]; i++) {
        CGPoint cgPoint = [barcode.cornerPoints[i] CGPointValue];
        left = (left > dbrManager.cameraResolution.height - cgPoint.y) ? (dbrManager.cameraResolution.height - cgPoint.y) : left;
        top = (top > cgPoint.x) ? cgPoint.x : top;
    }
    
    NSString *title = NSLocalizedString(@"reslut-alert-title", @"reslut alert title string");
    
    NSString *msgText = [NSString stringWithFormat:@"\n%@: %@\n\n%@: %@\n\n%@: {%@: %.f, %@: %.f, %@: %.f, %@: %.f}\n\n%@: %.03f %@\n\n",
                         NSLocalizedString(@"reslut-alert-type-string", @"reslut alert type string"),barcode.formatString, NSLocalizedString(@"reslut-alert-value-string", @"reslut alert value string"), barcode.displayValue, NSLocalizedString(@"reslut-alert-region-string", @"reslut alert region string"), NSLocalizedString(@"reslut-alert-left-string", @"reslut alert left string"), left, NSLocalizedString(@"reslut-alert-top-string", @"reslut alert top string"), top, NSLocalizedString(@"reslut-alert-width-string", @"reslut alert width string"), barcode.boundingbox.size.height, NSLocalizedString(@"reslut-alert-height-string", @"reslut alert height string"), barcode.boundingbox.size.width, NSLocalizedString(@"reslut-alert-interval-string", @"reslut alert interval string"), timeInterval, NSLocalizedString(@"reslut-alert-seconds-string", @"reslut alert seconds string")];
    
    NSString *okButtonString = NSLocalizedString(@"reslut-alert-ok-button", @"reslut alert ok button string");
    
    if ([UIAlertController class])
    {
        [self configAndShowResultAlertController:title message:msgText okButtonString:okButtonString];
    }
    else{
        [self configAndShowResultAlertView:title message:msgText okButtonString:okButtonString];
    }
}

- (void) configAndShowResultAlertController : (NSString *) title
                               message: (NSString *) message
                        okButtonString: (NSString *) okButtonString
{
    UIAlertController * ac=   [UIAlertController
                               alertControllerWithTitle:title
                               message:message
                               preferredStyle:UIAlertControllerStyleAlert];
    
    [self custmizeAC:ac];
    
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:okButtonString
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   dbrManager.isCurrentFrameDecodeFinished = YES;
                               }];
    
    [ac addAction:okButton];
    
    [self presentViewController:ac animated:YES completion:nil];
}

- (void) configAndShowResultAlertView : (NSString *) title
                              message: (NSString *) message
                       okButtonString: (NSString *) okButtonString
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:okButtonString
                                          otherButtonTitles:nil];
    
    [alert show];
}

- (void) configInterface{
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    CGFloat w = [[UIScreen mainScreen] bounds].size.width;
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    CGRect mainScreenLandscapeBoundary = CGRectZero;
    mainScreenLandscapeBoundary.size.width = MIN(w, h);
    mainScreenLandscapeBoundary.size.height = MAX(w, h);

    rectLayerImage.frame = mainScreenLandscapeBoundary;
    rectLayerImage.contentMode = UIViewContentModeTopLeft;
    
    [self createRectBorderAndAlignControls];
    
    //init vars and controls
    m_isFlashOn = NO;
    flashButton.layer.zPosition = 1;
    detectDescLabel.layer.zPosition = 1;
    [flashButton setTitle:NSLocalizedString(@"flash-off", @"flash off string") forState:UIControlStateNormal];
    
    //show vedio capture
    AVCaptureSession* captureSession = [dbrManager getVideoSession];
    if(captureSession == nil)
        return;
    
    previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        previewLayer.frame = mainScreenLandscapeBoundary;
    cameraPreview = [[UIView alloc] init];
    [cameraPreview.layer addSublayer:previewLayer];
    [self.view insertSubview:cameraPreview atIndex:0];
}

- (void)createRectBorderAndAlignControls {
    int width = rectLayerImage.bounds.size.width;
    int height = rectLayerImage.bounds.size.height;
    
    int widthMargin = width * 0.1;
    int heightMargin = (height - width + 2 * widthMargin) / 2;
    
    UIGraphicsBeginImageContext(self.rectLayerImage.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //1. draw gray rect
    [[UIColor blackColor] setFill];
    CGContextFillRect(ctx, (CGRect){{0,      0}, {widthMargin, height}});
    CGContextFillRect(ctx, (CGRect){{0,      0}, {width, heightMargin}});
    CGContextFillRect(ctx, (CGRect){{width - widthMargin, 0}, {widthMargin, height}});
    CGContextFillRect(ctx, (CGRect){{0, height - heightMargin}, {width, heightMargin}});
    
    //2. draw red line
    CGPoint points[2];
    [[UIColor redColor] setStroke];
    CGContextSetLineWidth(ctx, 2.0);
    points[0]=(CGPoint){widthMargin + 5,height/2}; points[1]=(CGPoint){width-widthMargin-5,height/2};
    CGContextStrokeLineSegments(ctx, points, 2);
    
    //3. draw white rect
    [[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(ctx, 1.0);
    // draw left side
    points[0]=(CGPoint){widthMargin,heightMargin}; points[1]=(CGPoint){widthMargin,height - heightMargin};
    CGContextStrokeLineSegments(ctx, points, 2);
    // draw right side
    points[0]=(CGPoint){width - widthMargin,heightMargin}; points[1]=(CGPoint){width - widthMargin,height - heightMargin};
    CGContextStrokeLineSegments(ctx, points, 2);
    // draw top side
    points[0]=(CGPoint){widthMargin,heightMargin}; points[1]=(CGPoint){width - widthMargin,heightMargin};
    CGContextStrokeLineSegments(ctx, points, 2);
    // draw bottom side
    points[0]=(CGPoint){widthMargin,height - heightMargin}; points[1]=(CGPoint){width - widthMargin,height - heightMargin};
    CGContextStrokeLineSegments(ctx, points, 2);
    
    //4. draw orange corners
    [[UIColor orangeColor] setStroke];
    CGContextSetLineWidth(ctx, 2.0);
    // draw left up corner
    points[0]=(CGPoint){widthMargin - 2,heightMargin - 2}; points[1]=(CGPoint){widthMargin + 18,heightMargin - 2};
    CGContextStrokeLineSegments(ctx, points, 2);
    points[0]=(CGPoint){widthMargin - 2,heightMargin - 2}; points[1]=(CGPoint){widthMargin - 2,heightMargin + 18};
    CGContextStrokeLineSegments(ctx, points, 2);
    // draw left bottom corner
    points[0]=(CGPoint){widthMargin - 2,height - heightMargin + 2}; points[1]=(CGPoint){widthMargin + 18,height - heightMargin + 2};
    CGContextStrokeLineSegments(ctx, points, 2);
    points[0]=(CGPoint){widthMargin - 2,height - heightMargin + 2}; points[1]=(CGPoint){widthMargin - 2,height - heightMargin - 18};
    CGContextStrokeLineSegments(ctx, points, 2);
    // draw right up corner
    points[0]=(CGPoint){width - widthMargin + 2,heightMargin - 2}; points[1]=(CGPoint){width - widthMargin - 18,heightMargin - 2};
    CGContextStrokeLineSegments(ctx, points, 2);
    points[0]=(CGPoint){width - widthMargin + 2,heightMargin - 2}; points[1]=(CGPoint){width - widthMargin + 2,heightMargin + 18};
    CGContextStrokeLineSegments(ctx, points, 2);
    // draw right bottom corner
    points[0]=(CGPoint){width - widthMargin + 2,height - heightMargin + 2}; points[1]=(CGPoint){width - widthMargin - 18,height - heightMargin + 2};
    CGContextStrokeLineSegments(ctx, points, 2);
    points[0]=(CGPoint){width - widthMargin + 2,height - heightMargin + 2}; points[1]=(CGPoint){width - widthMargin + 2,height - heightMargin - 18};
    CGContextStrokeLineSegments(ctx, points, 2);
    
    //5. set image
    rectLayerImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //6. align detectDescLabel horizontal center
    CGRect tempFrame = detectDescLabel.frame;
    tempFrame.origin.x = (width - detectDescLabel.bounds.size.width) / 2;
    tempFrame.origin.y = heightMargin * 0.6;
    [detectDescLabel setFrame:tempFrame];
    
    //7. align flashButton horizontal center
    tempFrame = flashButton.frame;
    tempFrame.origin.x = (width - flashButton.bounds.size.width) / 2;
    tempFrame.origin.y = (heightMargin + (width - widthMargin * 2) + height) * 0.5 - flashButton.bounds.size.height * 0.5;
    [flashButton setFrame:tempFrame];
    
    return;
}

@end
