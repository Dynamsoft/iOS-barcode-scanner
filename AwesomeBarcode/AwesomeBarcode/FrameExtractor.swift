//
//  FrameExtractor.swift
//  AwesomeBarcode
//
//  Created by Dynamsoft on 2018/6/20.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

import UIKit
import AVFoundation


class FrameExtractor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let position = AVCaptureDevice.Position.back
    private let quality = AVCaptureSession.Preset.medium
    
    private var permissionGranted = false
    private let captureQueue = DispatchQueue(label: "com.dynamsoft.barcode.session")
    private let session = AVCaptureSession()
    private let ciContext = CIContext()
    
    override init() {
        super.init()
        verifyPermission()
        self.captureQueue.async { [unowned self] in
            self.configureSession()
            self.session.startRunning()
        }
    }

    // MARK: Camera permission.
    private func verifyPermission() {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authorizationStatus {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            requestPermission()
        case .denied, .restricted:
            permissionGranted = false
        }
    }
    
    private func requestPermission() {
        captureQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            self.permissionGranted = granted
            self.captureQueue.resume()
        }
    }
    
    private func configureSession() {
        guard permissionGranted else { return }
        session.sessionPreset = quality
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        guard let sessionInput = try? AVCaptureDeviceInput(device: device) else { return }
        guard session.canAddInput(sessionInput) else { return }
        session.addInput(sessionInput)
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.dynamsoft.barcode.buffer"))
        guard session.canAddOutput(dataOutput) else { return }
        session.addOutput(dataOutput)
        guard let connection = dataOutput.connection(with: .video) else { return }
        guard connection.isVideoOrientationSupported else { return }
        guard connection.isVideoMirroringSupported else { return }
        connection.videoOrientation = .portrait
        connection.isVideoMirrored = (position == .front)
    }
}

extension FrameExtractor {
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let image = uiImageFromSampleBuffer(sampleBuffer) else { return }
        
    }
    
    private func uiImageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
