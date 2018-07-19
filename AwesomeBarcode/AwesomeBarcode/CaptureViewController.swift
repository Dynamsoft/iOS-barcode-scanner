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
fileprivate let convertProportion: CGFloat = FullScreenSize.width/720.0

fileprivate struct SessionConfiguration {
    static let quality = AVCaptureSession.Preset.hd1280x720
}

fileprivate struct DeviceConfiguration {
    static let position = AVCaptureDevice.Position.back
    static let focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
}

struct kScreenWH {
    static let  width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
}

class CaptureViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var ScannedCount: UILabel!
    @IBOutlet weak var cameraStream: UIView!
    
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
    //    static var itrFocusFinish:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        //        CaptureViewController.itrFocusFinish = 0

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        session = AVCaptureSession()
        sessionQueue = DispatchQueue(label: "com.dynamsoft.captureQueue")
        
        let item = UIBarButtonItem(title: "tack a photo", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.changeMedieMode))
        self.navigationItem.rightBarButtonItem = item
        isGettingVideo = true;
        if let _localBarcode = NSKeyedUnarchiver.unarchiveObject(withFile: BarcodeData.ArchiveURL.path) as? [BarcodeData] {
            localBarcode = _localBarcode
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAndStartCamera()
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
        session.sessionPreset = SessionConfiguration.quality
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
        cameraStream.bringSubview(toFront: ScannedCount)
        maskView.frame = cameraStream.bounds
        cameraStream.addSubview(maskView)
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
            maskView.isHidden = true;
            session.removeOutput(videoOutput)
            session.addOutput(photoOutput)
            self.navigationItem.rightBarButtonItem?.title = "take a video"
            
        }
        else
        {
            self.photoButton?.isHidden = true;
            self.ScannedCount.isHidden = false;
            self.resultsTableView!.isHidden = false;
            maskView.isHidden = false;
            session.removeOutput(photoOutput)
            session.addOutput(videoOutput)
            self.navigationItem.rightBarButtonItem?.title = "tack a photo"
        }
        self.isGettingVideo = !self.isGettingVideo
        session.startRunning()
    }
    
    @objc func changeMedieMode(){
        changeUI()
    }
    
    @objc func takePictures() {
        //MARK:拍照按钮点击事件 
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
            
            do
            {
                let results = try BarcodeData.barcodeReader.decode(originImage!, withTemplate: "")
                var image:UIImage!
                if results.count > 0 {
                    image = BarcodeMaskView.mixImage(originImage!, with: results.map{ self.pixelPointsFromResult($0.localizationResult!.resultPoints!, in: originImage!.size) })
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
            }
            catch{
                print(error);
            }
        })
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
        //            settings.barcodeTypeID = BarcodeType.QRCODE.rawValue;
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
            
            if tempResults!.count > 2 {
                let barcodeData = BarcodeData(path: imagePath, type: self.tempResults!.map({$0.barcodeFormat.description}), text: self.tempResults!.map({$0.barcodeText!}), locations: quadrilaterals)
                let originImage = uiImageFromSamplebuffer(sampleBuffer)!
                let image = BarcodeMaskView.mixImage(originImage, with: results.map{ self.pixelPointsFromResult($0.localizationResult!.resultPoints!, in: originImage.size) })
                self.archiveResults(UIImageJPEGRepresentation(image, 1.0)!, barcodeData: barcodeData)
            }
            
            DispatchQueue.main.async {
                self.ScannedCount.text = self.tempResults!.count.description + " Barcode"
                self.maskView.setNeedsDisplay()
                self.resultsTableView.reloadData()
            }
        } else {
            self.maskView.maskPoints.removeAll()
            DispatchQueue.main.async {
                self.ScannedCount.text = "0 Barcode"
                self.maskView.setNeedsDisplay()
                self.resultsTableView.reloadData()
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
        
        let point0 = CGPoint(x: FullScreenSize.width-p0.y*convertProportion, y: p0.x*convertProportion-84)
        let point1 = CGPoint(x: FullScreenSize.width-p1.y*convertProportion, y: p1.x*convertProportion-84)
        let point2 = CGPoint(x: FullScreenSize.width-p2.y*convertProportion, y: p2.x*convertProportion-84)
        let point3 = CGPoint(x: FullScreenSize.width-p3.y*convertProportion, y: p3.x*convertProportion-84)
        
        return [point0, point1, point2, point3]
    }
    
    func pixelPointsFromResult(_ result: [Any], in imageRect: CGSize) -> [CGPoint] {
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
