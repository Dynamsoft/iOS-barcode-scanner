//
//  DbrManager.swift
//  DynamsoftBarcodeReaderDemo
//
//  Created by Dynamsoft on 05/07/2018.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

import UIKit
import AVFoundation

class  DbrManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var barcodeFormat:Int?;
    var startRecognitionDate:NSDate?;
    var startVidioStreamDate:NSDate?;
    var isPauseFramesComing:Bool?;
    var isCurrentFrameDecodeFinished:Bool?;
    var adjustingFocus:Bool?;
    var cameraResolution:CGSize?;
    var m_videoCaptureSession:AVCaptureSession!
    var barcodeReader: DynamsoftBarcodeReader!;
    var m_recognitionCallback:Selector?;
    var m_recognitionReceiver:ScanViewController?;
    var ciContext:CIContext?;
    var frameId:Int?;
    var inputDevice:AVCaptureDevice?;
    var itrFocusFinish:Int!;
    var firstFocusFinish:Bool!;
    
    init(license:NSString)
    {
        m_videoCaptureSession = nil;
        barcodeReader = DynamsoftBarcodeReader(license: license as String);
        isPauseFramesComing = false;
        isCurrentFrameDecodeFinished = true;
        barcodeFormat = BarcodeType.ALL.rawValue ;
        startRecognitionDate = nil;
        ciContext = CIContext();
        m_recognitionReceiver = nil;
        startVidioStreamDate  = NSDate();
        adjustingFocus = true;
        frameId = 0;
        itrFocusFinish = 0;
        firstFocusFinish = false;
    }
    
    func setBarcodeFormat(format:Int)
    {
        do
        {
            barcodeFormat = format;
            let settings = try barcodeReader.templateSettings(withName: "");
            settings.barcodeTypeID = format;
            barcodeReader.setTemplateSettings(settings, error: nil);
        }
        catch{
            print(error);
        }
    }
    
    func beginVideoSession()
    {
        do
        {
            inputDevice = self.getAvailableCamera();
            let tInputDevice = inputDevice!;
            let captureInput = try? AVCaptureDeviceInput(device: tInputDevice);
            let captureOutput = AVCaptureVideoDataOutput.init();
            captureOutput.alwaysDiscardsLateVideoFrames = true;
            var queue:DispatchQueue;
            queue = DispatchQueue(label: "dbrCameraQueue");
            captureOutput.setSampleBufferDelegate(self as AVCaptureVideoDataOutputSampleBufferDelegate, queue: queue);
            
            // Enable continuous autofocus
            if(tInputDevice.isFocusModeSupported(AVCaptureDevice.FocusMode.continuousAutoFocus))
            {
                try tInputDevice.lockForConfiguration();
                tInputDevice.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus;
                tInputDevice.unlockForConfiguration();
            }
            
            // Enable AutoFocusRangeRestriction
            if(tInputDevice.isAutoFocusRangeRestrictionSupported)
            {
                try tInputDevice.lockForConfiguration();
                tInputDevice.autoFocusRangeRestriction = AVCaptureDevice.AutoFocusRangeRestriction.near;
                tInputDevice.unlockForConfiguration();
            }
            captureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA] as [String : Any];
            
            if(captureInput == nil)
            {
                return;
            }
            self.m_videoCaptureSession = AVCaptureSession.init()
            self.m_videoCaptureSession.addInput(captureInput!);
            self.m_videoCaptureSession.addOutput(captureOutput);
            
            if(self.m_videoCaptureSession.canSetSessionPreset(AVCaptureSession.Preset(rawValue: "AVCaptureSessionPreset1920x1080"))){
                self.m_videoCaptureSession.sessionPreset = AVCaptureSession.Preset(rawValue: "AVCaptureSessionPreset1920x1080")
            }
            else if(self.m_videoCaptureSession.canSetSessionPreset(AVCaptureSession.Preset(rawValue: "AVCaptureSessionPreset1280x720"))){
                self.m_videoCaptureSession.sessionPreset = AVCaptureSession.Preset(rawValue: "AVCaptureSessionPreset1280x720")
            }
            else if(self.m_videoCaptureSession.canSetSessionPreset(AVCaptureSession.Preset(rawValue: "AVCaptureSessionPreset640x480"))){
                self.m_videoCaptureSession.sessionPreset = AVCaptureSession.Preset(rawValue: "AVCaptureSessionPreset640x480")
            }
            
            self.m_videoCaptureSession.startRunning()
        }catch{
            print(error);
        }
    }
    
    func getAvailableCamera() -> AVCaptureDevice {
        let videoDevices = AVCaptureDevice.devices(for: AVMediaType.video);
        var captureDevice:AVCaptureDevice?;
        for device in videoDevices
        {
            if(device.position == AVCaptureDevice.Position.back)
            {
                captureDevice = device;
                break;
            }
        }
        if(captureDevice != nil)
        {
            captureDevice = AVCaptureDevice.default(for: AVMediaType.video);
        }
        return captureDevice!;
    }
    
    func getVideoSession() -> AVCaptureSession
    {
        return m_videoCaptureSession;
    }
    
    //AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    {
        do
        {
            if(inputDevice == nil)
            {
                return;
            }
            if(inputDevice?.isAdjustingFocus == false)
            {
                itrFocusFinish = itrFocusFinish + 1;
                if(itrFocusFinish == 1)
                {
                    firstFocusFinish = true;
                }
            }
            if(!firstFocusFinish || isPauseFramesComing == true || isCurrentFrameDecodeFinished == false)
            {
                return;
            }

            isCurrentFrameDecodeFinished = false;
            let imageBuffer:CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
            CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)
            let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
            let bufferSize = CVPixelBufferGetDataSize(imageBuffer)
            let width = CVPixelBufferGetWidth(imageBuffer)
            let height = CVPixelBufferGetHeight(imageBuffer)
            let bpr = CVPixelBufferGetBytesPerRow(imageBuffer)
            CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly)
            startRecognitionDate = NSDate();
            let buffer = Data(bytes: baseAddress!, count: bufferSize)
            
            guard let results = try? barcodeReader.decodeBuffer(buffer, withWidth: width, height: height, stride: bpr, format: .ARGB_8888, templateName: "") else { return }
            
            DispatchQueue.main.async{
                self.m_recognitionReceiver?.performSelector(inBackground: self.m_recognitionCallback!, with: results as NSArray);
            }
        }
        catch{
            print(error);
        }
    }
    
    func setRecognitionCallback(sender:ScanViewController, callBack:Selector)
    {
        m_recognitionReceiver = sender;
        m_recognitionCallback = callBack;
    }
    
}
