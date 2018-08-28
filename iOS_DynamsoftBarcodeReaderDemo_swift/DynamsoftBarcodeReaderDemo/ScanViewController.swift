//
//  ScanViewController.swift
//  DynamsoftBarcodeReaderDemo
//
//  Created by Dynamsoft on 08/07/2018.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

import UIKit
import AVFoundation

class ScanViewController: UIViewController {
    @IBOutlet var rectLayerImage: UIImageView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var detectDescLabel: UILabel!
    
    var cameraPreview: UIView?;
    var previewLayer: AVCaptureVideoPreviewLayer?;
    var dbrManager: DbrManager?;
    var isFlashOn:Bool!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        UIApplication.shared.isIdleTimerDisabled = true;
        //register notification for UIApplicationDidBecomeActiveNotification
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil);
        
        
        //init DbrManager with Dynamsoft Barcode Reader mobile license
        dbrManager = DbrManager(license:"t0068MgAAACxiTMNhK39G1UvCL179uDHeVDQFprcUphE4HKnMtD5nWVUUA / TCMrf / MdAYzY5dRoIRK / Vzh5nDQHmwOL0zjr8 =");
        dbrManager?.setRecognitionCallback(sender: self, callBack: #selector(onReadImageBufferComplete));
        dbrManager?.beginVideoSession();
        self.configInterface();
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        dbrManager?.isPauseFramesComing = false;
        self.turnFlashOn(on: isFlashOn);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showBarcodeTypes"){
            let newBackButton = UIBarButtonItem.init(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil);
            self.navigationItem.backBarButtonItem = newBackButton;
            self.navigationController?.navigationBar.tintColor = UIColor.white;
            let destViewController = segue.destination as! BarcodeTypesTableViewController;
            destViewController.mainView = self;
            
            self.turnFlashOn(on: false);
            dbrManager?.isPauseFramesComing = true;
        }
    }
    
    @objc func onReadImageBufferComplete(readResult:NSArray)
    {
        if(readResult.count == 0 || dbrManager?.isPauseFramesComing == true)
        {
            dbrManager?.isCurrentFrameDecodeFinished = true;
            return;
        }
        let timeInterval = (dbrManager?.startRecognitionDate?.timeIntervalSinceNow)! * -1;
        let barcode = readResult.firstObject as? TextResult;
        if(barcode == nil){
            dbrManager?.isCurrentFrameDecodeFinished = true;
            return;
        }
        var left:CGFloat = CGFloat(Float.greatestFiniteMagnitude);
        var top:CGFloat = CGFloat(Float.greatestFiniteMagnitude);
        var right:CGFloat = 0;
        var bottom:CGFloat = 0;
        for element in (barcode!.localizationResult?.resultPoints!)! {
            let resultPoint =  element as! CGPoint;
            left = left < resultPoint.x ? left : resultPoint.x;
            top = top < resultPoint.y ? top : resultPoint.y;
            right = right > resultPoint.x ? right : resultPoint.x;
            bottom = bottom > resultPoint.y ? bottom : resultPoint.y
        }
        let msgText = String(format:"\nType: %@\n\nValue: %@\n\nRegion: {Left: %.f, Top: %.f, Right: %.f, Bottom: %.f}\n\nInterval: %.03f seconds\n\n", self.barcodeTypeStringValue(type: barcode!.barcodeFormat) ,barcode!.barcodeText != nil ? barcode!.barcodeText! : "null", left, top, right, bottom, timeInterval);
        
        let ac = UIAlertController(title: "Result", message: msgText,preferredStyle: .alert)
        self.customizeAC(ac:ac);
        let okButton = UIAlertAction(title: "OK", style: .default, handler: {
            action in
            self.dbrManager?.isCurrentFrameDecodeFinished = true;
            self.dbrManager?.startVidioStreamDate! = NSDate();
        })
        ac.addAction(okButton)
        self.present(ac, animated: false, completion: nil)
    }
    
    @objc func didBecomeActive(notification:NSNotification) {
        if(dbrManager?.isPauseFramesComing == false)
        {
            self.turnFlashOn(on: isFlashOn);
        }
    }
    
    func configInterface()
    {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        let w = UIScreen.main.bounds.size.width;
        let h = UIScreen.main.bounds.size.height;
        var mainScreenLandscapeBoundary = CGRect.zero;
        mainScreenLandscapeBoundary.size.width = min(w, h);
        mainScreenLandscapeBoundary.size.height = max(w, h);
        rectLayerImage?.frame = mainScreenLandscapeBoundary;
        rectLayerImage?.contentMode = UIViewContentMode.topLeft;
        self.createRectBorderAndAlignControls();
        //init vars and controls
        isFlashOn = false;
        flashButton.layer.zPosition = 1;
        detectDescLabel.layer.zPosition = 1;
        flashButton.setTitle(" Flash off", for: UIControlState.normal);
        //show vedio capture
        let captureSession = dbrManager?.getVideoSession();
        if(captureSession == nil)
        {
            return;
        }
        previewLayer = AVCaptureVideoPreviewLayer(session:captureSession!);
        previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill;
        previewLayer!.frame = mainScreenLandscapeBoundary;
        cameraPreview = UIView();
        cameraPreview!.layer.addSublayer(previewLayer!);
        self.view.insertSubview(cameraPreview!, at: 0);
    }
    
    func createRectBorderAndAlignControls()
    {
        let width = rectLayerImage.bounds.size.width;
        let height = rectLayerImage.bounds.size.height;
        let widthMargin = width * 0.1;
        let heightMargin = (height - width + 2 * widthMargin) / 2;
        UIGraphicsBeginImageContext(self.rectLayerImage.bounds.size);
        let ctx = UIGraphicsGetCurrentContext();
        //1. draw gray rect
        UIColor.black.setFill();
        ctx!.fill(CGRect(x: 0, y: 0, width: widthMargin, height: height))
        ctx!.fill(CGRect(x: 0, y: 0, width: width, height: heightMargin))
        ctx!.fill(CGRect(x: width - widthMargin, y: 0, width: widthMargin, height: height))
        ctx!.fill(CGRect(x: 0, y: height - heightMargin, width: width, height: heightMargin))
        //2. draw red line
        var points = [CGPoint](repeating:CGPoint.zero, count: 2);
        UIColor.red.setStroke();
        ctx!.setLineWidth(2.0);
        points[0] = CGPoint(x:widthMargin + 5 , y:height / 2);
        points[1] = CGPoint(x:width - widthMargin - 5 , y:height / 2);
        ctx!.strokeLineSegments(between: points);
        //3. draw white rect
        UIColor.white.setStroke();
        ctx!.setLineWidth(1.0);
        // draw left side;
        points[0] = CGPoint(x:widthMargin,y:heightMargin);
        points[1] = CGPoint(x:widthMargin,y:height - heightMargin);
        ctx!.strokeLineSegments(between: points);
        // draw right side
        points[0] = CGPoint(x:width - widthMargin,y:heightMargin);
        points[1] = CGPoint(x:width - widthMargin,y:height - heightMargin);
        ctx!.strokeLineSegments(between: points);
        // draw top side
        points[0] = CGPoint(x:widthMargin,y:heightMargin);
        points[1] = CGPoint(x:width - widthMargin,y:heightMargin);
        ctx!.strokeLineSegments(between: points);
        // draw bottom side
        points[0] = CGPoint(x:widthMargin,y:height - heightMargin);
        points[1] = CGPoint(x:width - widthMargin,y:height - heightMargin);
        ctx!.strokeLineSegments(between: points);
        //4. draw orange corners
        UIColor.orange.setStroke();
        ctx!.setLineWidth(2.0);
        // draw left up corner
        points[0] = CGPoint(x:widthMargin - 2,y:heightMargin - 2);
        points[1] = CGPoint(x:widthMargin + 18,y:heightMargin - 2);
        ctx!.strokeLineSegments(between: points);
        points[0] = CGPoint(x:widthMargin - 2,y:heightMargin - 2);
        points[1] = CGPoint(x:widthMargin - 2,y:heightMargin + 18);
        ctx!.strokeLineSegments(between: points);
        // draw left bottom corner
        points[0] = CGPoint(x:widthMargin - 2,y:height - heightMargin + 2);
        points[1] = CGPoint(x:widthMargin + 18,y:height - heightMargin + 2);
        ctx!.strokeLineSegments(between: points);
        points[0] = CGPoint(x:widthMargin - 2,y:height - heightMargin + 2);
        points[1] = CGPoint(x:widthMargin - 2,y:height - heightMargin - 18);
        ctx!.strokeLineSegments(between: points);
        // draw right up corner
        points[0] = CGPoint(x:width - widthMargin + 2,y:heightMargin - 2);
        points[1] = CGPoint(x:width - widthMargin - 18,y:heightMargin - 2);
        ctx!.strokeLineSegments(between: points);
        points[0] = CGPoint(x:width - widthMargin + 2,y:heightMargin - 2);
        points[1] = CGPoint(x:width - widthMargin + 2,y:heightMargin + 18);
        ctx!.strokeLineSegments(between: points);
        // draw right bottom corner
        points[0] = CGPoint(x:width - widthMargin + 2,y:height - heightMargin + 2);
        points[1] = CGPoint(x:width - widthMargin - 18,y:height - heightMargin + 2);
        ctx!.strokeLineSegments(between: points);
        points[0] = CGPoint(x:width - widthMargin + 2,y:height - heightMargin + 2);
        points[1] = CGPoint(x:width - widthMargin + 2,y:height - heightMargin - 18);
        ctx!.strokeLineSegments(between: points);
        //5. set image
        rectLayerImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //6. align detectDescLabel horizontal center
        var tempFrame = detectDescLabel.frame;
        tempFrame.origin.x = (width - detectDescLabel.bounds.size.width) / 2;
        tempFrame.origin.y = heightMargin * 0.6;
        detectDescLabel.frame = tempFrame;
        //7. align flashButton horizontal center
        tempFrame = flashButton.frame;
        tempFrame.origin.x = (width - flashButton.bounds.size.width) / 2;
        tempFrame.origin.y = (heightMargin + (width - widthMargin * 2) + height) * 0.5 - flashButton.bounds.size.height * 0.5;
        flashButton.frame = tempFrame;
        return;
    }
    
    func turnFlashOn(on: Bool){
        do
        {
            let captureDeviceClass = NSClassFromString("AVCaptureDevice");
            if (captureDeviceClass != nil) {
                let device = AVCaptureDevice.default(for: AVMediaType.video);
                if (device != nil && device!.hasTorch && device!.hasFlash){
                    try device!.lockForConfiguration();
                    if (on == true) {
                        device!.torchMode = AVCaptureDevice.TorchMode.on;
                        device!.flashMode = AVCaptureDevice.FlashMode.on;
                        flashButton.setImage(UIImage(named: "flash_on"), for: UIControlState.normal);
                        flashButton.setTitle(" Flash on", for: UIControlState.normal);
                    } else {
                        device?.torchMode = AVCaptureDevice.TorchMode.off;
                        device?.flashMode = AVCaptureDevice.FlashMode.off;
                        flashButton.setImage(UIImage(named: "flash_on"), for: UIControlState.normal);
                        flashButton.setTitle(" Flash off", for: UIControlState.normal);
                    }
                    device?.unlockForConfiguration();
                }
            }
        }
        catch{
            print(error);
        }
    }
    
    // MARK: Addition explaination
    func barcodeTypeStringValue(type:BarcodeType) -> NSString
    {
        switch (type) {
        case BarcodeType.CODE39:
            return "CODE 39";
        case BarcodeType.CODE128:
            return "CODE 128";
        case BarcodeType.CODE93:
            return "CODE 93";
        case BarcodeType.CODABAR:
            return "CODABAR";
        case BarcodeType.ITF:
            return "ITF";
        case BarcodeType.EAN13:
            return "EAN-13";
        case BarcodeType.EAN8:
            return "EAN-8";
        case BarcodeType.UPCA:
            return "UPC-A";
        case BarcodeType.UPCE:
            return "UPC-E";
        case BarcodeType.INDUSTRIAL:
            return "INDUSTRIAL";
        case BarcodeType.PDF417:
            return "PDF417";
        case BarcodeType.QRCODE:
            return "QRCODE";
        case BarcodeType.DATAMATRIX:
            return "DataMatrix";
        case BarcodeType.AZTEC:
            return "Aztec";
        default:
            return "Unknown code";
        }
    }
    
    func customizeAC(ac: UIAlertController){

        let subView1 = ac.view.subviews[0] as UIView;
        let subView2 = subView1.subviews[0] as UIView;
        let subView3 = subView2.subviews[0] as UIView;
        let subView4 = subView3.subviews[0] as UIView;
        let subView5 = subView4.subviews[0] as UIView;
        let titleLab = subView5.subviews[0] as! UILabel;
        let messageLab = subView5.subviews[1] as! UILabel;
        titleLab.textAlignment = NSTextAlignment.left;
        messageLab.textAlignment = NSTextAlignment.left;
 
    }
    
    @IBAction func onFlashButtonClick(_ sender: Any) {
        isFlashOn = isFlashOn == true ? false : true;
        self.turnFlashOn(on: isFlashOn);
    }
    
    @IBAction func onAboutInfoClick(_ sender: Any) {
        dbrManager?.isPauseFramesComing = true;
        let ac = UIAlertController(title: "About", message: "\nDynamsoft Barcode Reader Mobile App Demo(Dynamsoft Barcode Reader SDK v6.3.0)\n\n© 2018 Dynamsoft. All rights reserved. \n\nIntegrate Barcode Reader Functionality into Your own Mobile App? \n\nClick 'Overview' button for further info.\n\n",preferredStyle: .alert)
        self.customizeAC(ac:ac);
        let linkAction = UIAlertAction(title: "Overview", style: .default, handler: {
            action in
            let urlString = "http://www.dynamsoft.com/Products/barcode-scanner-sdk-iOS.aspx";
            let url = NSURL(string: urlString );
            if(UIApplication.shared.canOpenURL(url! as URL))
            {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url! as URL)
                } else {
                    UIApplication.shared.openURL(url! as URL);
                };
            }
            self.dbrManager?.isPauseFramesComing = false;
        })
        ac.addAction(linkAction);
        
        let yesButton = UIAlertAction(title: "OK", style: .default, handler: {
            action in
            self.dbrManager?.isPauseFramesComing = true;
        })
        ac.addAction(yesButton);
        self.present(ac, animated: true, completion: nil)
    }
}
