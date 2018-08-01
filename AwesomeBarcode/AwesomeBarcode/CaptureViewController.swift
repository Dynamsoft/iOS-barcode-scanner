//
//  CaptureViewController.swift
//  AwesomeBarcode
//
//  Created by Dynamsoft on 2018/5/29.
//  Copyright © 2018年 Dynamsoft. All rights reserved.
//

import UIKit
import AVFoundation
import Accelerate

let FullScreenSize = UIScreen.main.bounds

fileprivate struct SessionQuality {
    var quality:AVCaptureSession.Preset
    var h:CGFloat
    var w:CGFloat
}

fileprivate struct SessionConfiguration {
    static private let qualityConf_hd1280x720 = SessionQuality(quality: AVCaptureSession.Preset.hd1280x720, h: 1280, w: 720)
    static private let qualityConf_hd1920x1080 = SessionQuality(quality: AVCaptureSession.Preset.hd1920x1080, h: 1920, w: 1080)
    static private let qualityConf_hd4K3840x2160 = SessionQuality(quality: AVCaptureSession.Preset.hd4K3840x2160, h: 3840, w: 2160)
    static let curQualityConf = qualityConf_hd1920x1080
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
    @IBOutlet weak var startJigsaw: UIButton!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        session = AVCaptureSession()
        sessionQueue = DispatchQueue(label: "com.dynamsoft.captureQueue")
        let item = UIBarButtonItem(title: "tack a photo", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.changeMedieMode))
        self.navigationItem.rightBarButtonItem = item
        isGettingVideo = true
        viewAppearCount = 0
        preFrameImgBeStored = false
        jigsawStatus = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    override func viewDidDisappear(_ animated: Bool) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.stopRunning()
        }
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
        cameraStream.bringSubview(toFront: ScannedCount)
        cameraStream.bringSubview(toFront: self.startJigsaw)
        verOffset = (cameraStream.bounds.height - SessionConfiguration.curQualityConf.h * convertProportion) / 2
    }
    
    func alertPromptForCameraAuthority() {
        let alert = UIAlertController(title: "FuckAPP", message: "FuckAPP want to use your camera.", preferredStyle: .alert)
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
    
    func changeUI() {
        session.stopRunning()
        if(self.isGettingVideo)
        {
            self.ScannedCount.isHidden = true;
            self.resultsTableView!.isHidden = true;
            if(photoButton == nil)
            {
                photoButton = UIButton(type: .custom)
                photoButton?.frame = CGRect(x: kScreenWH.width * 1 / 2.0 - 50, y: kScreenWH.height - 120, width: 100, height: 100)
                photoButton?.setImage(UIImage(named: "photograph"), for: .normal)
                photoButton?.addTarget(self, action: #selector(self.takePictures), for: .touchUpInside)
                view.addSubview(photoButton!)
            }
            else
            {
                self.photoButton?.isHidden = false
            }
            if(photoAlbumBtn == nil)
            {
                photoAlbumBtn  = UIButton.init()
                photoAlbumBtn!.frame = CGRect.init(x: kScreenWH.width - 70, y: kScreenWH.height - 100, width: 60, height: 60)
                photoAlbumBtn!.setImage(UIImage.init(named: "Album"), for: .normal)
                photoAlbumBtn!.addTarget(self, action: #selector(self.photoAlbumAction), for: .touchUpInside)
                view.addSubview(photoAlbumBtn!)
            }
            else
            {
                photoAlbumBtn?.isHidden = false
            }

            maskView.isHidden = true;
            session.removeOutput(videoOutput)
            session.addOutput(photoOutput)
            self.navigationItem.rightBarButtonItem?.title = "video"
        }
        else
        {
            self.photoButton?.isHidden = true;
            self.ScannedCount.isHidden = false;
            self.resultsTableView!.isHidden = false;
            maskView.isHidden = false;
            session.removeOutput(photoOutput)
            session.addOutput(videoOutput)
            self.navigationItem.rightBarButtonItem?.title = "photo"
        }
        self.isGettingVideo = !self.isGettingVideo
        session.startRunning()
    }
    
    @objc func changeMedieMode(){
        changeUI()
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
            let serialQueue = DispatchQueue(label: "com.dynamsoft.decodeQueue")
            serialQueue.async() { () -> Void in
                do
                {
                    let results = try BarcodeData.barcodeReader.decode(originImage!, withTemplate: "")
                    var barcodeBate:BarcodeData?
                    var image:UIImage!
                    if results.count > 0 {
                        image = BarcodeMaskView.mixImage(originImage!, with: results.map{ CaptureViewController.pixelPointsFromResult($0.localizationResult!.resultPoints!, in: originImage!.size) })

                            self.tempResults = Array.init(Set.init(results))
                            barcodeBate = BarcodeData(path: self.imagePath, type: self.tempResults!.map({$0.barcodeFormat.description}), text: self.tempResults!.map({$0.barcodeText!}), locations: self.tempResults!.map({$0.localizationResult?.resultPoints}) as! [[CGPoint]])
                    }
                    else
                    {
                        image = originImage
                    }
                    
                    DispatchQueue.main.async {
                        let photoResultVC = PhotoResultEditViewController()
                        photoResultVC.previewImg = image
                        self.navigationController?.pushViewController(photoResultVC, animated: true)
                    }
                    if results.count > 0 {
                        self.archiveResults(UIImageJPEGRepresentation(originImage!, 1.0)!, barcodeData: barcodeBate!)
                    }
                    
                }
                catch{
                    print(error);
                }
            }
            
        })
    }
    
    @objc  func photoAlbumAction() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }else{
            print("open Ablum failed!")
        }
    }
    
    @IBAction func clickJiasaw(_ sender: UIButton) {
        
        if(self.jigsawStatus & 1 == 0)
        {
            self.startJigsaw.setTitle("endJigsaw", for: .normal)
            if(localBarcode.count > 1)
            {
                for i in  1...(localBarcode.count - 1)
                {
                    let paras = ParametersOfCoordsMapFunction()!
                    let preData = localBarcode[i - 1]
                    let curData = localBarcode[i]
                    SetParasInfo(data1: preData, data2: curData, paras: paras)
                    let m = NSMutableArray()
                    var byteSize:Int32 = 0
                    var outputImage = UIImage()
                    var w:Int32 = 0
                    var h:Int32 = 0
                    let result1 = paras.stitchImg(outputImage,byteSize:&byteSize,width:&w,height:&h,mapResult: m)
                    var outputBuffer = Data()
                    var width:Int32 = 0
                    var height:Int32 = 0
                    var byteSize2:Int32 = 0
                    let result = paras.stitchImg(outputBuffer, byteSize: &byteSize2, w: &width, h: &height, mapResult: m)
                    switch result {
                    case 0:
                        break
                    case 1 :
                        self.removeItemInArchiveResults(index: i - 1)
                        break
                    case 2 :
                        self.removeItemInArchiveResults(index: i)
                        break
                    case 3:
                        self.removeItemInArchiveResults(index: i - 1)
                        self.removeItemInArchiveResults(index: i)
                        let mapResults  = GetBarcodeDataByMutableArr(m: m)
                        
//                        let image = outputImage
                        //                            self.archiveResults(UIImageJPEGRepresentation(image, 1.0)!, barcodeData: barcodeData)
                        //
                        break
                    default:
                        break
                    }
                    self.jigsawStatus = self.jigsawStatus + 1
                }
            }
        }
        else
        {
            self.startJigsaw.setTitle("startJigsaw", for: .normal)
            self.jigsawStatus = self.jigsawStatus + 1
        }
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        do
        {
            imagePicker.dismiss(animated: true, completion: nil)
            let img:UIImage = info[UIImagePickerControllerEditedImage]as! UIImage
            startRecognitionDate = NSDate()
            let results = try BarcodeData.barcodeReader.decode(img, withTemplate: "")
            self.onReadImageComplete(readResults: results)
        }
        catch{
            print(error);
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func GetResultText(id:Int, textResult:TextResult) -> String {
        var left:CGFloat = CGFloat(Float.greatestFiniteMagnitude)
        var top:CGFloat = CGFloat(Float.greatestFiniteMagnitude)
        var right:CGFloat = 0;
        var bottom:CGFloat = 0;
        for element in (textResult.localizationResult?.resultPoints!)! {
            let resultPoint =  element as! CGPoint;
            left = left < resultPoint.x ? left : resultPoint.x;
            top = top < resultPoint.y ? top : resultPoint.y;
            right = right > resultPoint.x ? right : resultPoint.x;
            bottom = bottom > resultPoint.y ? bottom : resultPoint.y
        }
        return String(format:"\nresult%d:\n\nType: %@\n\nValue: %@\n\nRegion: {Left: %.f, Top: %.f, Right: %.f, Bottom: %.f}\n\n", id + 1, textResult.barcodeFormat.description, textResult.barcodeText != nil ? textResult.barcodeText! : "null", left, top, right, bottom)
    }
    
    func onReadImageComplete(readResults:[TextResult])
    {
        let timeInterval = (startRecognitionDate?.timeIntervalSinceNow)! * -1;
        var msgText = "";
        if(readResults.count == 0)
        {
            msgText = "\nno barcode found\n\n";
        }
        else
        {
            for i in  0...(readResults.count-1)
            {
                let barcode = readResults[i]
                msgText = msgText + GetResultText(id:i,textResult: barcode);
            }
        }
        msgText = msgText + String(format: "Interval: %.03f seconds\n\n", timeInterval)
        let ac = UIAlertController(title: "Result", message: msgText, preferredStyle: .alert)
        self.customizeAC(ac:ac);
        let okButton = UIAlertAction(title: "OK", style: .default, handler: {
            action in
        })
        ac.addAction(okButton)
        self.present(ac, animated: true, completion: nil)
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
}

extension CaptureViewController {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard canDecodeBarcode else { return }
        
        //        guard let device = AVCaptureDevice.default(for: .video) else { return }
        //        if(device.isAdjustingFocus == true)
        //        {
        ////            itrFocusFinish = itrFocusFinish + 1;
        ////            if(itrFocusFinish == 1)
        ////            {
        ////                return;
        ////            }
        //            return;
        //        }
        
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
        
//        do
//        {
//            let settings = try BarcodeData.barcodeReader.templateSettings(withName: "");
//            settings.barcodeTypeID = BarcodeType.ONED.rawValue;
//            BarcodeData.barcodeReader.setTemplateSettings(settings, error: nil);
//        }
//        catch{
//            print(error);
//        }

        //        startRecognitionDate = NSDate();

        guard let results = try? BarcodeData.barcodeReader.decodeBuffer(buffer, withWidth: width, height: height, stride: bpr, format: .ARGB_8888, templateName: "") else { return }
        //        let timeInterval = (self.startRecognitionDate?.timeIntervalSinceNow)! * -1
        //        if(timeInterval > 1)
        //        {
        //            var ciImage:CIImage?
        //            if #available(iOS 9.0, *) {
        //                ciImage = CIImage(cvImageBuffer: imageBuffer)
        //            } else {
        //                // Fallback on earlier versions
        //            };
        //            if(ciImage == nil)
        //            {
        //                return;
        //            }
        //            let cgImage = ciContext.createCGImage(ciImage!, from: ciImage!.extent);
        //            let uiImage = UIImage(cgImage: cgImage!);
        //            print(timeInterval)
        //        }
        if results.count > 0 {
            self.tempResults = Array.init(Set.init(results))
            let quadrilaterals = results.map { self.pointsFromResult($0.localizationResult!.resultPoints!) }
            self.maskView.maskPoints = quadrilaterals
            DispatchQueue.main.async {
                self.ScannedCount.text = self.tempResults!.count.description + " Barcode"
                self.maskView.setNeedsDisplay()
                self.resultsTableView.reloadData()
            }
            let barcodeData = BarcodeData(path: imagePath, type: self.tempResults!.map({$0.barcodeFormat.description}), text: self.tempResults!.map({$0.barcodeText!}), locations: self.tempResults!.map({$0.localizationResult?.resultPoints}) as! [[CGPoint]])
            let curImg = uiImageFromSamplebuffer(sampleBuffer)!
            var firstImgNeedSave = true
            var secondImgNeedSave = false
            if(preFrameImg != nil)
            {
                var mapResults:BarcodeData
                let firstLocalBarcode:BarcodeData = localBarcode.last!
                let secondLocalBarcode:BarcodeData = barcodeData
                var result = 1
                let paras = ParametersOfCoordsMapFunction()
                paras!.domainOfImg1 = CGPoint(x:preFrameImg!.size.height,y:preFrameImg!.size.width)
                paras!.domainOfImg2 = CGPoint(x:curImg.size.height,y:curImg.size.width)
                paras!.barcodeRecogResultOfImg1 = SetBarcodeRecogResultOfImg(localBarcode: firstLocalBarcode)
                paras!.barcodeRecogResultOfImg2 = SetBarcodeRecogResultOfImg(localBarcode: secondLocalBarcode)
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
                mapResults = GetBarcodeDataByMutableArr(m: m)
                
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

            preFrameImg = curImg;
        } else {
            self.maskView.maskPoints.removeAll()
            DispatchQueue.main.async {
                self.ScannedCount.text = "0 Barcode"
                self.maskView.setNeedsDisplay()
                self.resultsTableView.reloadData()
            }
        }
    }
    
    func GetBarcodeDataByMutableArr(m:NSMutableArray) -> BarcodeData
    {
        var tmapResults = m as! [BarcodeRecogResult]
        let imagePath: URL = URL(string: "nil")!
        var barcodeTypes: [String] = [String]()
        var barcodeTexts: [String] = [String]()
        var barcodeLocations: [[CGPoint]] = [[CGPoint]]()
        if(tmapResults.count > 0)
        {
            for i in  0...(tmapResults.count - 1)
            {
                barcodeTypes.append("")
                barcodeTexts.append(tmapResults[i].barcodeText)
                var loc = [CGPoint]()
                for j in 0...3
                {
                    loc.append(CGPoint(x:tmapResults[i].pts[j * 2] as! Int, y: tmapResults[i].pts[ j * 2 + 1] as! Int))
                }
                barcodeLocations.append(loc)
            }
        }
        let mapResults  = BarcodeData(path: imagePath, type: barcodeTypes, text: barcodeTexts, locations: barcodeLocations)
        return mapResults
    }
    
    func SetParasInfo(data1:BarcodeData,data2:BarcodeData,paras:ParametersOfCoordsMapFunction)
    {
        let preData = data1
        let curData = data2
        let preImg = UIImage(contentsOfFile: preData.imagePath.path)!
        let curImg = UIImage(contentsOfFile: curData.imagePath.path)!
        
        paras.bInfoImage1 = BuffInfOfImg(uiImage: preImg)
        paras.bInfoImage2 = BuffInfOfImg(uiImage: curImg)
        paras.domainOfImg1 = CGPoint(x:preImg.size.height,y:preImg.size.width)
        paras.domainOfImg2 = CGPoint(x:curImg.size.height,y:curImg.size.width)
        paras.barcodeRecogResultOfImg1 = SetBarcodeRecogResultOfImg(localBarcode: preData)
        paras.barcodeRecogResultOfImg2 = SetBarcodeRecogResultOfImg(localBarcode: curData)
    }

    func SetBarcodeRecogResultOfImg(localBarcode:BarcodeData) -> [BarcodeRecogResult]
    {
        var result = [BarcodeRecogResult]()
        if(localBarcode.barcodeLocations.count > 0)
        {
            for i in  0...(localBarcode.barcodeLocations.count - 1)
            {
                let recogResult = BarcodeRecogResult()

                let loc = localBarcode.barcodeLocations[i]
                recogResult.pts = [Int(loc[0].x),Int(loc[0].y),Int(loc[1].x),Int(loc[1].y),Int(loc[2].x),Int(loc[2].y),Int(loc[3].x),Int(loc[3].y)]

                recogResult.barcodeText = localBarcode.barcodeTexts[i]
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSSS"
        dateFormatter.timeZone = TimeZone.current
        let dataTimeStamp = dateFormatter.string(from: Date())
        let dataName = dataTimeStamp.replacingOccurrences(of: ":", with: "")
        return BarcodeData.documentDir.appendingPathComponent(dataName+".jpg")
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
            guard let _ = try? FileManager.default.removeItem(at: willRemove.imagePath) else { return }
            localBarcode.append(barcodeData)
        }
        guard let _ = try? buffer.write(to: barcodeData.imagePath) else { return }
        NSKeyedArchiver.archiveRootObject(localBarcode, toFile: BarcodeData.ArchiveURL.path)
    }
    
    func removeLastOneInArchiveResults(){
        let willRemove = localBarcode.removeLast()
        guard let _ = try? FileManager.default.removeItem(at: willRemove.imagePath) else { return }
        NSKeyedArchiver.archiveRootObject(localBarcode, toFile: BarcodeData.ArchiveURL.path)
    }
    
    func removeItemInArchiveResults(index: Int){
        let willRemove = localBarcode.remove(at: index)
        guard let _ = try? FileManager.default.removeItem(at: willRemove.imagePath) else { return }
        NSKeyedArchiver.archiveRootObject(localBarcode, toFile: BarcodeData.ArchiveURL.path)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "identifiedResult") else { return UITableViewCell(style: .subtitle, reuseIdentifier: nil) }
        cell.textLabel?.text = tempResults?[indexPath.row].barcodeFormat.description
        cell.detailTextLabel?.text = tempResults?[indexPath.row].barcodeText
        return cell
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        canDecodeBarcode = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        canDecodeBarcode = true
    }
}
