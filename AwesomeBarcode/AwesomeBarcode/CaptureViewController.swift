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

class CaptureViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var ScannedCount: UILabel!
    @IBOutlet weak var cameraStream: UIView!
    let session: AVCaptureSession = AVCaptureSession()
    let sessionQueue: DispatchQueue = DispatchQueue(label: "com.dynamsoft.captureQueue")
    let barcodeReader = DynamsoftBarcodeReader(license: "t0068MgAAABhYnpGyll51x5q4jrPNUojC1czRgf4dREMHtyMSIyuHSpJA6SAL7NWTXsTyCtcgLKnYEOiGG+v0hTnZQkgUT7E=")
    var tempResults: [TextResult]?
    var maskView = BarcodeMaskView(frame: .zero)
    var canDecodeBarcode = true
    var localBarcode = [BarcodeData]()
    
    let ciContext = CIContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _localBarcode = NSKeyedUnarchiver.unarchiveObject(withFile: BarcodeData.ArchiveURL.path) as? [BarcodeData] {
            localBarcode = _localBarcode
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAndStartCamera()
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
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.setSampleBufferDelegate(self, queue: sessionQueue)
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
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
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler:{(_) in
                self.navigationController?.popViewController(animated: true)
            })
        })
        alert.addAction(cancelAction)
        alert.addAction(requestAction)
        present(alert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
}

extension CaptureViewController {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard canDecodeBarcode else { return }
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
        guard let results = try? barcodeReader.decodeBuffer(buffer, withWidth: width, height: height, stride: bpr, format: .ARGB_8888, templateName: "") else { return }
        if results.count > 0 {
            self.tempResults = Array.init(Set.init(results))
            let quadrilaterals = results.map { self.pointsFromResult($0.localizationResult!.resultPoints!) }
            self.maskView.maskPoints = quadrilaterals
            
            if tempResults!.count > 2 {
                let barcodeData = BarcodeData(path: imagePath, type: self.tempResults!.map({$0.barcodeFormat.description}), text: self.tempResults!.map({$0.barcodeText!}), locations: quadrilaterals)
                let originImage = uiImageFromSamplebuffer(sampleBuffer)!
                let image = mixImage(originImage, with: results.map{ self.pixelPointsFromResult($0.localizationResult!.resultPoints!, in: originImage.size) })
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
    
    func mixImage(_ image: UIImage, with quadrilaterals: [[CGPoint]]) -> UIImage {
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        #colorLiteral(red: 0.9957528327, green: 1, blue: 0.2315606233, alpha: 0.5).setFill()
        let path = UIBezierPath()
        path.lineWidth = 0
        for mask in quadrilaterals {
            path.move(to: mask[0])
            path.addLine(to: mask[1])
            path.addLine(to: mask[2])
            path.addLine(to: mask[3])
            path.close()
            path.fill()
        }
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
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
