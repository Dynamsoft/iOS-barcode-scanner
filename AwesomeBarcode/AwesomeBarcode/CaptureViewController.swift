//
//  CaptureViewController.swift
//  AwesomeBarcode
//
//  Created by Dynamsoft on 2018/5/29.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

import UIKit
import AVFoundation
import Accelerate

let FullScreenSize = UIScreen.main.bounds
let NavigationH: CGFloat = 44
let StatusH: CGFloat = 20

fileprivate struct SessionQuality {
    var quality:AVCaptureSession.Preset
    var h:CGFloat
    var w:CGFloat
}

fileprivate struct SessionConfiguration {
    static private let qualityConf_hd1280x720 = SessionQuality(quality: AVCaptureSession.Preset.hd1280x720, h: 1280, w: 720)
    static private let qualityConf_hd1920x1080 = SessionQuality(quality: AVCaptureSession.Preset.hd1920x1080, h: 1920, w: 1080)
    static private let qualityConf_hd4K3840x2160 = SessionQuality(quality: AVCaptureSession.Preset.hd4K3840x2160, h: 3840, w: 2160)
    static let curQualityConf = qualityConf_hd1280x720
}

fileprivate let convertProportion: CGFloat = FullScreenSize.width / SessionConfiguration.curQualityConf.w

fileprivate struct DeviceConfiguration {
    static let position = AVCaptureDevice.Position.back
    static let focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
}

struct kScreenWH {
    static let  width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
}

class CaptureViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var ScannedCount: UILabel!
    @IBOutlet weak var cameraStream: UIView!
    //    @IBOutlet weak var startJigsaw: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var resultCountsView: UIView!

    var tableViewIsPop:Bool!
    var imagePicker:UIImagePickerController!
    var pan:UIPanGestureRecognizer!
    var session: AVCaptureSession!
    var sessionQueue: DispatchQueue!
    var tempResults: [TextResult]?
    var maskView = BarcodeMaskView(frame: .zero)
    var canDecodeBarcode = true
    var localBarcode = [BarcodeData]()
    let ciContext = CIContext()
    var startRecognitionDate:NSDate?
    var photoOutput:AVCaptureStillImageOutput!
    var videoOutput:AVCaptureVideoDataOutput!
    var imageView: UIImageView?
    var isGettingVideo:Bool!
    var photoButton: UIButton?
    var photoAlbumBtn:UIButton?
    var viewAppearCount:Int!
    var verOffset:CGFloat!
    var preFrameImg:UIImage?
    var preFrameImgBeStored:Bool!
    var jigsawStatus:Int!
    var isFlashOn:Bool!
    private var _showmenueBtnSelected = false
    private var popView:YHPopMenu?
    private var resultArr:[String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        resultsTableView.tableFooterView = UIView(frame: CGRect.zero)
        session = AVCaptureSession()
        sessionQueue = DispatchQueue(label: "com.dynamsoft.captureQueue")
        isGettingVideo = true
        viewAppearCount = 0
        preFrameImgBeStored = false
        jigsawStatus = 0
        self.resultCountsView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 29)
        self.ScannedCount.center = self.resultCountsView.center
        self.ScannedCount.textColor = UIColor.white
        self.resultsTableView.frame = CGRect(x: 0, y: FullScreenSize.height - 75, width: FullScreenSize.width, height: 75)
        self.resultsTableView.register(UINib(nibName:"histroyDetailTableViewCell", bundle:nil),forCellReuseIdentifier:"historyResultsCell")
        self.title = "Scan Barcode"
        self.tableViewIsPop = false
        self.isFlashOn = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.canDecodeBarcode = true
        if let _localBarcode = NSKeyedUnarchiver.unarchiveObject(withFile: BarcodeData.ArchiveURL.path) as? [BarcodeData] {
            localBarcode = _localBarcode
        }
        viewAppearCount = viewAppearCount + 1
        if(viewAppearCount > 1)
        {
            if(self.session.isRunning == false)
            {
                self.session.startRunning()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(viewAppearCount == 1)
        {
            checkAndStartCamera()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if _showmenueBtnSelected == true {
            _hidePopMenu(animate: true)
        }
        self.canDecodeBarcode = false
        
        super.viewWillDisappear(animated)
        
        if(isFlashOn)
        {
            isFlashOn = false
            self.turnFlashOn(on: isFlashOn);
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {

        DispatchQueue.global(qos: .userInitiated).async {
            self.session.stopRunning()
        }
        super.viewDidDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        self.canDecodeBarcode = false
    }
    
    func checkAndStartCamera() {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authorizationStatus {
        case .authorized:
            setUpCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                DispatchQueue.main.async {
                    if granted {
                        self.setUpCamera()
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            })
        case .denied, .restricted:
            alertPromptForCameraAuthority()
        }
    }
    
    func setUpCamera() {
        guard !session.isRunning else { return }
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        guard session.canAddInput(input) else { return }
        session.addInput(input)
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        photoOutput = AVCaptureStillImageOutput()
        guard session.canAddOutput(videoOutput) else { return }
        session.addOutput(videoOutput)
        guard session.canAddOutput(photoOutput) else { return }
        session.addOutput(photoOutput)
        session.sessionPreset = SessionConfiguration.curQualityConf.quality
        //        guard let connection = output.connection(with: .video) else { return }
        //        guard connection.isVideoMirroringSupported else { return }
        //        connection.isVideoMirrored = (device.position == .front)
        //        guard connection.isVideoOrientationSupported else { return }
        //        connection.videoOrientation = .portrait
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = cameraStream.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraStream.layer.addSublayer(previewLayer)
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
        
        maskView.frame = cameraStream.bounds
        
        cameraStream.addSubview(maskView)
        cameraStream.bringSubview(toFront: self.flashButton)
        cameraStream.bringSubview(toFront: self.resultCountsView)
        verOffset = (cameraStream.bounds.height - SessionConfiguration.curQualityConf.h * convertProportion) / 2
    }
    
    func alertPromptForCameraAuthority() {
        let alert = UIAlertController(title: "DynamsoftBarcodeReader X", message: "DynamsoftBarcodeReader X want to use your camera.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_) in
            self.navigationController?.popViewController(animated: true)
        })
        let requestAction = UIAlertAction(title: "Allow Camera", style: .default, handler: {(_) in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler:{(_) in
                    self.navigationController?.popViewController(animated: true)
                })
            } else {
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!);
            }
        })
        alert.addAction(cancelAction)
        alert.addAction(requestAction)
        present(alert, animated: true, completion: nil)
    }
    
    func setPhotographUI()
    {
        if(self.isGettingVideo)
        {
            self.isGettingVideo = false
            self.resultCountsView.isHidden = true
            self.resultsTableView!.isHidden = true
            if(photoButton == nil)
            {
                photoButton = UIButton(type: .custom)
                photoButton?.frame = CGRect(x: kScreenWH.width / 2.0 - 38.5, y: kScreenWH.height - 126, width: 77, height: 77)
                photoButton?.setImage(UIImage(named: "icon_capture"), for: .normal)
                photoButton?.addTarget(self, action: #selector(self.takePictures), for: .touchUpInside)
                view.addSubview(photoButton!)
            }
            else
            {
                self.photoButton?.isHidden = false
            }
            if(isFlashOn)
            {
                self.turnFlashOn(on: isFlashOn)
            }
            maskView.isHidden = true;
        }
    }
    
    func setVideoUI()
    {
        if(!self.isGettingVideo)
        {
            self.isGettingVideo = true
            self.photoButton?.isHidden = true
            self.resultCountsView.isHidden = false
            self.resultsTableView!.isHidden = false
            maskView.backgroundColor = .clear
            maskView.isHidden = false;
            if(isFlashOn)
            {
                self.turnFlashOn(on: isFlashOn)
            }
        }
    }
    
    func changeUI() {
        session.stopRunning()
        if(self.isGettingVideo)
        {
            setPhotographUI()
        }
        else
        {
            setVideoUI()
        }
        self.isGettingVideo = !self.isGettingVideo
        session.startRunning()
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
                    } else {
                        device?.torchMode = AVCaptureDevice.TorchMode.off;
                        device?.flashMode = AVCaptureDevice.FlashMode.off;
                    }
                    device?.unlockForConfiguration();
                }
            }
        }
        catch{
            print(error);
        }
    }
    
    @objc func changeMedieMode(){
        changeUI()
    }
    
    
    func fixOrientation(aImage: UIImage) -> UIImage {
        
        if (aImage.imageOrientation == .up) {
            return aImage
        }
        var transform = CGAffineTransform.identity
        switch (aImage.imageOrientation) {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: aImage.size.width, y: aImage.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: aImage.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: aImage.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi / 2))
        default:
            break
        }
        switch (aImage.imageOrientation) {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: aImage.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: aImage.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        default:
            break
        }

        let ctx = CGContext(data: nil, width: Int(aImage.size.width), height: Int(aImage.size.height),
                            bitsPerComponent: aImage.cgImage!.bitsPerComponent, bytesPerRow: 0,
                            space: aImage.cgImage!.colorSpace!,
                            bitmapInfo: aImage.cgImage!.bitmapInfo.rawValue)
        ctx!.concatenate(transform)
        switch (aImage.imageOrientation) {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(aImage.cgImage!, in: CGRect(x: 0, y: 0, width: aImage.size.height, height: aImage.size.width))
            break
        default:
            ctx?.draw(aImage.cgImage!, in: CGRect(x: 0, y: 0, width: aImage.size.width, height: aImage.size.height))
            break
        }
        let cgimg = ctx!.makeImage()
        return UIImage(cgImage: cgimg!)
    }
    
    func feedPic(img:UIImage,isFromImagePicker:Bool)
    {
        var originImage = img
        if(isFromImagePicker)
        {
            originImage = fixOrientation(aImage: originImage)
        }
        let serialQueue = DispatchQueue(label: "com.dynamsoft.decodeQueue")
        serialQueue.async() { () -> Void in
            do
            {
                self.startRecognitionDate = NSDate()
                let tempResults = try BarcodeData.barcodeReader.decode(originImage, withTemplate: "")
                let results = self.filterLowConfidenceFrame(results: tempResults)
                let timeInterval = Int(self.startRecognitionDate!.timeIntervalSinceNow * -1000)
                var barcodeBata:BarcodeData!
                let image:UIImage!
                if results.count > 0 {
                    if(isFromImagePicker)
                    {
                        image = BarcodeMaskView.mixImage(originImage, with: results.map{ $0.localizationResult!.resultPoints! as! [CGPoint]})
                    }
                    else
                    {
                        image = BarcodeMaskView.mixImage(originImage, with: results.map{ CaptureViewController.pixelPointsFromResult($0.localizationResult!.resultPoints!, in: originImage.size)})
                    }

                    self.tempResults = Array.init(Set.init(results))
                    barcodeBata = BarcodeData(path: self.imagePath, type: self.tempResults!.map({String($0.barcodeFormat.rawValue)}),typeDes: self.tempResults!.map({$0.barcodeFormat.description}),text: self.tempResults!.map({$0.barcodeText!}), locations: self.tempResults!.map({$0.localizationResult!.resultPoints}) as! [[CGPoint]], date:Date(),time:String(timeInterval),crdntNeedRotate:isFromImagePicker ? "false" : "true"
                    )
                }
                else
                {
                    image = originImage
                    barcodeBata = BarcodeData(path: self.imagePath, type: [""],typeDes:[""], text: ["no barcode found"], locations: [[CGPoint]](), date:Date(), time:String(timeInterval))
                }
                DispatchQueue.main.async {
                    let secondView = QuickLookViewController()
                    secondView.index = 0
                    secondView.localBarcode = [barcodeBata]
                    secondView.singleImgMode = true
                    secondView.singleImg = image
                    self.navigationController?.pushViewController(secondView , animated: true)
                }
                if results.count > 0 {
                    self.archiveResults(UIImageJPEGRepresentation(originImage, 1.0)!, barcodeData: barcodeBata!)
                }
            }
            catch{
                print(error);
            }
        }
    }
    
    
    @objc func takePictures() {
        
        let videoConnection: AVCaptureConnection? = photoOutput.connection(with: AVMediaType.video)
        if videoConnection == nil {
            print("take photo failed!")
            return
        }
        photoOutput.captureStillImageAsynchronously(from: videoConnection ?? AVCaptureConnection(), completionHandler: {(_ imageDataSampleBuffer: CMSampleBuffer?, _ error: Error?) -> Void in
            if imageDataSampleBuffer == nil {
                return
            }
            let imageData: Data? = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer!)
            let originImage = UIImage(data: imageData!)
            self.feedPic(img: originImage!,isFromImagePicker:  false)
        })
    }
    
    @objc  func photoAlbumAction() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        else{
            print("open Ablum failed!")
        }
    }
    
    //debug:
    func printInfoOfParas(paras:ParametersOfStitchImagesFun)
    {
//        print img1
        print("paras.bInfOfImg.width:\(paras.bInfOfImg.width)\n");
        print("paras.bInfOfImg.height:\(paras.bInfOfImg.height)\n");
        print("paras.bInfOfImg.stride:\(paras.bInfOfImg.stride)\n");
        print("paras.bInfOfImg.format:\(paras.bInfOfImg.format)\n");
        print("paras.domainOfImg.x:\(paras.domainOfImg.x) preParas.domainOfImg.y:\(paras.domainOfImg.y)\n");
        print("paras.lengthThreshold:\(paras.lengthThreshold)\n");
        
        print("barcodeRecogResultOfImg:\n")
        for i in  0...(paras.barcodeRecogResultOfImg.count - 1)
        {
            let result =  paras.barcodeRecogResultOfImg[i]
            print("result.barcodeText:\(result.barcodeText)\n")
            print("result.barcodeFormat:\(result.barcodeFormat)\n")
            print("result.loc:",result.pts[0],result.pts[1],result.pts[2],result.pts[3],result.pts[4],result.pts[5],result.pts[6],result.pts[7])
        }
    }
    
    @IBAction func takeWholeView(_ sender: UIBarButtonItem) {
        if(self.jigsawStatus & 1 == 0)
        {
            if(localBarcode.count > 1)
            {
                for i in  1...(localBarcode.count - 1)
                {
                    let preParas = ParametersOfStitchImagesFun()
                    let preData = localBarcode[i - 1]
                    SetParasInfo(data: preData, paras: preParas)
                    
                    let curParas = ParametersOfStitchImagesFun()
                    let curData = localBarcode[i]
                    SetParasInfo(data: curData, paras: curParas)

                    let inputParas = [preParas,curParas]
                    let m = NSMutableArray()
                    let stchImg = StitchImage()

                    var img:UIImage? = UIImage()

//                    self.printInfoOfParas(paras: preParas)
//                    self.printInfoOfParas(paras: curParas)
                    
                    var resutl = stchImg!.stitchImg(inputParas, mapResult: m, resultImg: &img)
                    
//                    let mapResults = GetBarcodeDataByMutableArr(m: m,time:0)
                    
                    
//                    let m = NSMutableArray()
//                    var byteSize:Int32 = 0
//                    var outputImage = UIImage()
//                    var w:Int32 = 0
//                    var h:Int32 = 0
//                    let result1 = paras.stitchImg(outputImage,byteSize:&byteSize,width:&w,height:&h,mapResult: m)
//                    var outputBuffer = Data()
//                    var width:Int32 = 0
//                    var height:Int32 = 0
//                    var byteSize2:Int32 = 0
//                    let result = paras.stitchImg(outputBuffer, byteSize: &byteSize2, w: &width, h: &height, mapResult: m)
//                    switch result {
//                    case 0:
//                        break
//                    case 1 :
//                        self.removeItemInArchiveResults(index: i - 1)
//                        break
//                    case 2 :
//                        self.removeItemInArchiveResults(index: i)
//                        break
//                    case 3:
//                        self.removeItemInArchiveResults(index: i - 1)
//                        self.removeItemInArchiveResults(index: i)
//                        let mapResults  = GetBarcodeDataByMutableArr(m: m)
//
//                        //                        let image = outputImage
//                        //                            self.archiveResults(UIImageJPEGRepresentation(image, 1.0)!, barcodeData: barcodeData)
//                        //
//                        break
//                    default:
//                        break
//                    }
                    self.jigsawStatus = self.jigsawStatus + 1
                }
            }
        }
        else
        {
            self.jigsawStatus = self.jigsawStatus + 1
        }
    }
    
    @IBAction func FlashBtnClick(_ sender: UIButton) {
        isFlashOn = isFlashOn == true ? false : true;
        self.turnFlashOn(on: isFlashOn);
    }
    
    @IBAction func openMenu(_ sender: UIBarButtonItem) {
        _showmenueBtnSelected = !_showmenueBtnSelected
        if _showmenueBtnSelected == true {
            _showMenu()
        }else{
            _hidePopMenu(animate: true)
        }
    }
    
    private func _showMenu(){
        let itemH = CGFloat(60)
        let w = CGFloat(140)
        let h = CGFloat(3*itemH)
        let r = CGFloat(5)
        let x = FullScreenSize.width - w - r
        let y = CGFloat(10)
        
        popView =  YHPopMenu(frame: CGRect(x: x, y: y, width: w, height: h))
        popView?.itemNameArray = ["Scanning","Capture","File"]
        popView?.iconNameArray = ["icon_scanning_selected","icon_camera_selected","icon_file_selected"]
        popView?.itemH     = itemH
        popView?.fontSize  = 12.0
        popView?.fontColor = UIColor.white
        popView?.canTouchTabbar = true
        popView?.itemBgColor = kGreenColor
        popView?.show()
        
        popView?.dismiss(handler: { [unowned self] (isCanceled, row) in
            if isCanceled == false {
                if (row == 0) {
                    self.setVideoUI()
                }
                else if(row == 1){
                    self.setPhotographUI()
                }
                else if(row == 2){
                    self.photoAlbumAction()
                }
            }
            self._showmenueBtnSelected = false
        })
        
    }
    
    func _hidePopMenu(animate:Bool){
        popView?.hide(animate: animate)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        do
        {
            imagePicker.dismiss(animated: true, completion: nil)
            
            let img:UIImage = info[UIImagePickerControllerOriginalImage]as! UIImage
            self.feedPic(img: img, isFromImagePicker:true)
        }
        catch{
            print(error);
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

extension CaptureViewController {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard canDecodeBarcode else { return }
        if(!self.isGettingVideo){ return }
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        let bufferSize = CVPixelBufferGetDataSize(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        let bpr = CVPixelBufferGetBytesPerRow(imageBuffer)
//        var src = vImage_Buffer(data: baseAddress!, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: bpr)
//        let map: [UInt8] = [3, 2, 1, 0]
//        vImagePermuteChannels_ARGB8888(&src, &src, map, vImage_Flags(kvImageNoFlags))
        CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly)
        let buffer = Data(bytes: baseAddress!, count: bufferSize)
        self.startRecognitionDate = NSDate();
        do
        {
            guard let tempResults =  try? BarcodeData.barcodeReader.decodeBuffer(buffer, withWidth: width, height: height, stride: bpr, format: .ARGB_8888, templateName:"") else { return }
            let results = filterLowConfidenceFrame(results: tempResults)
            let timeInterval = Int(self.startRecognitionDate!.timeIntervalSinceNow * -1000)
            if results.count > 0 {
                self.tempResults = Array.init(Set.init(results))
                let quadrilaterals = results.map { self.pointsFromResult($0.localizationResult!.resultPoints!) }
                self.maskView.maskPoints = quadrilaterals
                
                let resultCount = GetResultCount(tempResults: self.tempResults!)
                let charS = resultCount > 1 ? "s" : ""
                let scannedCountStr = "\(resultCount) Barcode\(charS) Scanned"
                DispatchQueue.main.async {
                    self.ScannedCount.text = scannedCountStr
                    self.maskView.setNeedsDisplay()
                    self.resultsTableView.reloadData()
                }
                for i in  0...(self.tempResults!.count - 1)
                {
                    if(self.tempResults![i].barcodeText == nil)
                    {
                        self.tempResults![i].barcodeText = ""
                    }
                }

                let barcodeData = BarcodeData(path: imagePath, type: self.tempResults!.map({String($0.barcodeFormat.rawValue)}),typeDes: self.tempResults!.map({$0.barcodeFormat.description}), text: self.tempResults!.map({$0.barcodeText!}), locations: self.tempResults!.map({$0.localizationResult?.resultPoints}) as! [[CGPoint]],date:Date(),time:String(timeInterval)
                )

                let curImg = uiImageFromSamplebuffer(sampleBuffer)!
                var firstImgNeedSave = true
                var secondImgNeedSave = false
                if(preFrameImg != nil)
                {
                    var mapResults:BarcodeData
                    let firstLocalBarcode:BarcodeData = localBarcode.last!
                    let secondLocalBarcode:BarcodeData = barcodeData

                    if(isRepeated(localBarcode:firstLocalBarcode) || isRepeated(localBarcode:secondLocalBarcode))
                    {
                        firstImgNeedSave = true
                        secondImgNeedSave = true
                    }
                    else
                    {
                        var result = 1
                        let paras = ParametersOfCoordsMapFunction()
                        paras!.domainOfImg1 = CGPoint(x:preFrameImg!.size.height,y:preFrameImg!.size.width)
                        paras!.domainOfImg2 = CGPoint(x:curImg.size.height,y:curImg.size.width)
                        paras!.barcodeRecogResultOfImg1 = SetBarcodeRecogResultOfImg4CordMap(localBarcode: firstLocalBarcode)
                        paras!.barcodeRecogResultOfImg2 = SetBarcodeRecogResultOfImg4CordMap(localBarcode: secondLocalBarcode)
                        //                var text_1 = secondLocalBarcode
                        //                var text_2 = firstLocalBarcode
                        //                if(firstLocalBarcode.barcodeTexts.count < secondLocalBarcode.barcodeTexts.count)
                        //                {
                        //                    text_1 = firstLocalBarcode
                        //                    text_2 = secondLocalBarcode
                        //                }
                        //                var isContained = true
                        //                if(text_1.barcodeTexts.count > 0)
                        //                {
                        //                    for i in 0...(text_1.barcodeTexts.count - 1)
                        //                    {
                        //                        var k = 0
                        //                        for j in 0...(text_2.barcodeTexts.count - 1)
                        //                        {
                        //                            k = k + 1
                        //                            if(text_1.barcodeTexts[i] == text_2.barcodeTexts[j])
                        //                            {
                        //                                break
                        //                            }
                        //                        }
                        //                        if(k == text_2.barcodeTexts.count)
                        //                        {
                        //                            isContained = false
                        //                            break
                        //                        }
                        //                    }
                        //                }
                        
                        let m = NSMutableArray()
                        var isAllCodeMapped = false
                        result = Int(paras!.coordinationMap(m, isAllCodeMapped: &isAllCodeMapped))
                        mapResults = GetBarcodeDataByMutableArr(m: m,time:timeInterval)
                        
                        switch result {
                        case -1:
                            firstImgNeedSave = true
                            secondImgNeedSave = false
                            break
                        case 0  :
                            firstImgNeedSave = true
                            secondImgNeedSave = true
                            break
                        case 1 :
                            firstImgNeedSave = true
                            if(isAllCodeMapped)
                            {
                                MapResultsToTar(tarLocalBarcode: firstLocalBarcode, mapFromLocalBarcode: secondLocalBarcode, mapResults: mapResults)
                                secondImgNeedSave = false
                            }
                            else
                            {
                                secondImgNeedSave = true
                            }
                            break
                        default :
                            secondImgNeedSave = true
                            if(isAllCodeMapped)
                            {
                                MapResultsToTar(tarLocalBarcode: secondLocalBarcode, mapFromLocalBarcode: firstLocalBarcode, mapResults: mapResults)
                                firstImgNeedSave = false
                            }
                            else
                            {
                                firstImgNeedSave = true
                            }
                            break
                        }
                    }
                }
                else
                {
                    firstImgNeedSave = true
                    secondImgNeedSave = true
                }
                
                if(!firstImgNeedSave)
                {
                    self.removeLastOneInArchiveResults()
                }
                if(secondImgNeedSave)
                {
                    self.archiveResults(UIImageJPEGRepresentation(curImg, 1.0)!, barcodeData: barcodeData)
                }
                preFrameImg = nil
                preFrameImg = curImg
            } else {
                self.maskView.maskPoints.removeAll()
                DispatchQueue.main.async {
                    self.maskView.setNeedsDisplay()
                    self.resultsTableView.reloadData()
                }
            }
        }
        catch{
            print(error)
        }
        
        if(canDecodeBarcode == false)
        {
            self.maskView.maskPoints.removeAll()
            DispatchQueue.main.async {
                self.maskView.setNeedsDisplay()
            }
        }
    }

    func isRepeated(localBarcode:BarcodeData) -> Bool
    {
        var isFlag = false
        for i in 0 ..< localBarcode.barcodeTexts.count {
            for j in (i + 1) ..< localBarcode.barcodeTexts.count {
                if(localBarcode.barcodeTexts[i] == localBarcode.barcodeTexts[j] || Int(localBarcode.barcodeTypes[i]) == Int(localBarcode.barcodeTypes[j]))
                {
                    isFlag = true
                    return isFlag
                }
            }
        }
        return isFlag
    }

    func GetBarcodeDataByMutableArr(m:NSMutableArray,time:Int) -> BarcodeData
    {
        var tmapResults = m as! [BarcodeRecogResultForCordsMap]
        let imagePath: URL = URL(string: "nil")!
        var barcodeTypes: [String] = [String]()
        var barcodeTypeDes: [String] = [String]()
        var barcodeTexts: [String] = [String]()
        var barcodeLocations: [[CGPoint]] = [[CGPoint]]()
        if(tmapResults.count > 0)
        {
            for i in  0...(tmapResults.count - 1)
            {
                barcodeTypeDes.append("")
                barcodeTypes.append(String(tmapResults[i].barcodeFormat))
                barcodeTexts.append(tmapResults[i].barcodeText)
                var loc = [CGPoint]()
                for j in 0...3
                {
                    loc.append(CGPoint(x:tmapResults[i].pts[j * 2] as! Int, y: tmapResults[i].pts[ j * 2 + 1] as! Int))
                }
                barcodeLocations.append(loc)
            }
        }
        let mapResults  = BarcodeData(path: imagePath, type: barcodeTypes,typeDes: barcodeTypeDes, text: barcodeTexts, locations: barcodeLocations,date:Date(),time:String(time))
        return mapResults
    }
    
    func GetResultCount(tempResults:[TextResult]) -> Int
    {
        for item in tempResults
        {
            if(item.barcodeText != nil && !self.resultArr.contains(item.barcodeText!) && item.localizationResult!.extendedResults![0].confidence > 30)
            {
                self.resultArr.append(item.barcodeText!)
            }
        }
        return self.resultArr.count
    }
    
    func SetParasInfo(data:BarcodeData,paras:ParametersOfStitchImagesFun)
    {
        let img = UIImage(contentsOfFile: data.imagePath.path)!
        paras.domainOfImg = CGPoint(x:img.size.width,y:img.size.height)
        paras.barcodeRecogResultOfImg = SetBarcodeRecogResultOfImg4StitchImg(localBarcode: data)
        paras.bInfOfImg = BuffInfOfImg(uiImage: img)
    }

    func SetBarcodeRecogResultOfImg4StitchImg(localBarcode:BarcodeData) -> [BarcodeRecogResult4StitchImg]
    {
        var result = [BarcodeRecogResult4StitchImg]()
        if(localBarcode.barcodeLocations.count > 0)
        {
            for i in  0...(localBarcode.barcodeLocations.count - 1)
            {
                let recogResult = BarcodeRecogResult4StitchImg()
                let loc = localBarcode.barcodeLocations[i]
                recogResult.pts = [Int(loc[0].x),Int(loc[0].y),Int(loc[1].x),Int(loc[1].y),Int(loc[2].x),Int(loc[2].y),Int(loc[3].x),Int(loc[3].y)]
                recogResult.barcodeText = localBarcode.barcodeTexts[i]
                recogResult.barcodeFormat = Int32(localBarcode.barcodeTypes[i])!
                result.append(recogResult)
            }
        }
        return result
    }
    
    func SetBarcodeRecogResultOfImg4CordMap(localBarcode:BarcodeData) -> [BarcodeRecogResultForCordsMap]
    {
        var result = [BarcodeRecogResultForCordsMap]()
        if(localBarcode.barcodeLocations.count > 0)
        {
            for i in  0...(localBarcode.barcodeLocations.count - 1)
            {
                let recogResult = BarcodeRecogResultForCordsMap()
                let loc = localBarcode.barcodeLocations[i]
                recogResult.pts = [Int(loc[0].x),Int(loc[0].y),Int(loc[1].x),Int(loc[1].y),Int(loc[2].x),Int(loc[2].y),Int(loc[3].x),Int(loc[3].y)]
                recogResult.barcodeText = localBarcode.barcodeTexts[i]
                recogResult.barcodeFormat = Int32(localBarcode.barcodeTypes[i])!
                result.append(recogResult)
            }
        }
        return result
    }
    
    func MapResultsToTar(tarLocalBarcode:BarcodeData,mapFromLocalBarcode:BarcodeData,mapResults:BarcodeData)
    {
        if(mapResults.barcodeLocations.count > 0)
        {
            for i in  0...(mapResults.barcodeLocations.count - 1)
            {
                tarLocalBarcode.barcodeLocations.append(mapResults.barcodeLocations[i])
                tarLocalBarcode.barcodeTexts.append(mapResults.barcodeTexts[i])
                if(mapFromLocalBarcode.barcodeLocations.count > 0)
                {
                    for j in  0...(mapFromLocalBarcode.barcodeLocations.count - 1)
                    {
                        if(mapResults.barcodeTexts[i] == mapFromLocalBarcode.barcodeTexts[j])
                        {
                            tarLocalBarcode.barcodeTypes.append(mapFromLocalBarcode.barcodeTypes[j])
                            break
                        }
                    }
                }
            }
        }
    }
    
    var imagePath: URL {
        
        let date = Date()
        let dataName =  String(date.timeIntervalSince1970)
        return BarcodeData.documentDir.appendingPathComponent(dataName + ".jpg")
    }
    
    func pointsFromResult(_ result: [Any]) -> [CGPoint] {
        let p0 = result[0] as! CGPoint
        let p1 = result[1] as! CGPoint
        let p2 = result[2] as! CGPoint
        let p3 = result[3] as! CGPoint
        
        let point0 = CGPoint(x: FullScreenSize.width - p0.y * convertProportion, y: p0.x * convertProportion + verOffset)
        let point1 = CGPoint(x: FullScreenSize.width - p1.y * convertProportion, y: p1.x * convertProportion + verOffset)
        let point2 = CGPoint(x: FullScreenSize.width - p2.y * convertProportion, y: p2.x * convertProportion + verOffset)
        let point3 = CGPoint(x: FullScreenSize.width - p3.y * convertProportion, y: p3.x * convertProportion + verOffset)
        
        return [point0, point1, point2, point3]
    }
    
    static func pixelPointsFromResult(_ result: [Any], in imageRect: CGSize) -> [CGPoint] {
        let p0 = result[0] as! CGPoint
        let p1 = result[1] as! CGPoint
        let p2 = result[2] as! CGPoint
        let p3 = result[3] as! CGPoint
        let point0 = CGPoint(x: imageRect.width - p0.y, y: p0.x)
        let point1 = CGPoint(x: imageRect.width - p1.y, y: p1.x)
        let point2 = CGPoint(x: imageRect.width - p2.y, y: p2.x)
        let point3 = CGPoint(x: imageRect.width - p3.y, y: p3.x)
        return [point0, point1, point2, point3]
        
    }
    
    static func pixelPointsFromResultInverse(_ result: [Any], in imageRect: CGSize) -> [CGPoint] {
        let p0 = result[0] as! CGPoint
        let p1 = result[1] as! CGPoint
        let p2 = result[2] as! CGPoint
        let p3 = result[3] as! CGPoint
        let point0 = CGPoint(x: p0.y, y: imageRect.width - p0.x)
        let point1 = CGPoint(x: p1.y, y: imageRect.width - p1.x)
        let point2 = CGPoint(x: p2.y, y: imageRect.width - p2.x)
        let point3 = CGPoint(x: p3.y, y: imageRect.width - p3.x)
        return [point0, point1, point2, point3]
    }
    
    func uiImageFromSamplebuffer(_ sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent)
        return UIImage(cgImage: cgImage!, scale: 1.0, orientation: .right)
    }
    
    func archiveResults(_ buffer: Data, barcodeData: BarcodeData) {
        if localBarcode.count < 16 {
            localBarcode.append(barcodeData)
        } else {
            let willRemove = localBarcode.removeFirst()
            localBarcode.append(barcodeData)
        }
        guard let _ = try? buffer.write(to: barcodeData.imagePath) else { return }
        NSKeyedArchiver.archiveRootObject(localBarcode, toFile: BarcodeData.ArchiveURL.path)
    }
    
    func removeLastOneInArchiveResults(){
        let willRemove = localBarcode.removeLast()
        NSKeyedArchiver.archiveRootObject(localBarcode, toFile: BarcodeData.ArchiveURL.path)
    }
    
    func removeItemInArchiveResults(index: Int){
        let willRemove = localBarcode.remove(at: index)
        NSKeyedArchiver.archiveRootObject(localBarcode, toFile: BarcodeData.ArchiveURL.path)
    }
    
    func filterLowConfidenceFrame(results:[TextResult]) -> [TextResult]{
        var textResults = [TextResult]()
        for item in results
        {
            if(item.barcodeText != nil && item.localizationResult!.extendedResults![0].confidence > 30)
            {
                textResults.append(item)
            }
        }
        return textResults
    }
    
}

extension CaptureViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = tempResults?.count else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = (tableView.dequeueReusableCell(withIdentifier: "historyResultsCell", for: indexPath)) as! histroyDetailTableViewCell
        cell.cellNum.text = indexPath.row + 1 < 10 ? "0\(indexPath.row + 1)": String(indexPath.row + 1)
        let text = tempResults?[indexPath.row].barcodeText
        let format = tempResults?[indexPath.row].barcodeFormat.description
        cell.txtLabel.text = "Text: \(text)"
        cell.formatLabel.text = "Format: \(format)"
        
        return cell
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    @objc func dismiss(alert:UIAlertController) {
        alert.dismiss(animated: true, completion: nil)
    }
    
     func alertScanningIsStop()
    {
        
        
        
       
        
        
        let alert = UIAlertController(title: nil, message: "Scanning is stopped!", preferredStyle: .alert)
        
        
        alert.view.transform = CGAffineTransform.init(translationX: 0, y: -200)
 
        self.present(alert, animated: true, completion: nil)
        self.perform(#selector(dismiss(alert:)), with: alert, afterDelay: 0.2)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let offsetY = scrollView.contentOffset.y + scrollView.contentInset.top
        if(offsetY > 20 && !self.tableViewIsPop)
        {
            self.tableViewIsPop = true
            self.canDecodeBarcode = false
            self.alertScanningIsStop()
            self.maskView.maskPoints.removeAll()
            DispatchQueue.main.async {
                self.maskView.setNeedsDisplay()
//                self.resultsTableView.reloadData()
            }
            
            UIView.animate(withDuration: 0.2) {
                self.resultsTableView.frame.origin.y = FullScreenSize.height / 2
                self.resultsTableView.frame.size.height = FullScreenSize.height - self.resultsTableView.frame.origin.y
            }
        }
        else if(offsetY < -40 && self.tableViewIsPop)
        {
            UIView.animate(withDuration: 0.2) {
                self.resultsTableView.frame.origin.y = FullScreenSize.height - 75
                self.resultsTableView.frame.size.height = FullScreenSize.height - self.resultsTableView.frame.origin.y
            }
            self.tableViewIsPop = false
            self.canDecodeBarcode = true
            
        }
    }
}
