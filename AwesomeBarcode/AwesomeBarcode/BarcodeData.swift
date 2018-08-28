//
//  BarcodeData.swift
//  AwesomeBarcode
//
//  Created by Dynamsoft on 2018/7/5.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

import UIKit

class BarcodeData: NSObject, NSCoding {
    let imagePath: URL
    var barcodeTypes: [String]
    var barcodeTypesDes:[String]
    var barcodeTexts: [String]
    var barcodeLocations: [[CGPoint]]
    var decodeDate:Date
    var decodeTime:String
    var coordinateNeedRotate:String
    
    struct PropertyKey {
        static let imagePath = "ImagePath"
        static let barcodeType = "BarcodeType"
        static let barcodeTypeDes = "BarcodeTypeDes"
        static let barcodeText = "BarcodeText"
        static let barcodeLocations = "BarcodeLocations"
        static let decodeDate = "DecodeDate"
        static let decodeTime = "DecodeTime"
        static let coordinateNeedRotate = "CoordinateNeedRotate"
    }
    
    static let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = documentDir.appendingPathComponent("barcode.data")
    static var barcodeReader:DynamsoftBarcodeReader = GetBarcodeReaderInstance()

    init(path: URL, type: [String],typeDes: [String], text: [String], locations: [[CGPoint]],date:Date,time:String,crdntNeedRotate:String = "true") {
        self.imagePath = path
        self.barcodeTypes = type
        self.barcodeTypesDes = typeDes
        self.barcodeTexts = text
        self.barcodeLocations = locations
        self.decodeDate = date
        self.decodeTime = time
        self.coordinateNeedRotate = crdntNeedRotate
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let _imagePath = aDecoder.decodeObject(forKey: PropertyKey.imagePath) as? URL else { return nil }
        guard let _barcodeTypes = aDecoder.decodeObject(forKey: PropertyKey.barcodeType) as? [String] else { return nil }
        guard let _barcodeTypesDes = aDecoder.decodeObject(forKey: PropertyKey.barcodeTypeDes) as? [String] else { return nil }
        guard let _barcodeTexts = aDecoder.decodeObject(forKey: PropertyKey.barcodeText) as? [String] else { return nil }
        guard let _barcodeLocations = aDecoder.decodeObject(forKey: PropertyKey.barcodeLocations) as? [[CGPoint]] else { return nil }
        guard let _decodeDate = aDecoder.decodeObject(forKey: PropertyKey.decodeDate) as? Date else {return nil}
        guard let _time = aDecoder.decodeObject(forKey: PropertyKey.decodeTime) as? String else {return nil}
        
        guard let _crdntNeedRotate = aDecoder.decodeObject(forKey: PropertyKey.coordinateNeedRotate) as? String else {return nil}
        
        self.init(path: _imagePath, type: _barcodeTypes,typeDes: _barcodeTypesDes, text: _barcodeTexts, locations: _barcodeLocations, date:_decodeDate, time:_time, crdntNeedRotate:_crdntNeedRotate)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(imagePath, forKey: PropertyKey.imagePath)
        aCoder.encode(barcodeTypes, forKey: PropertyKey.barcodeType)
        aCoder.encode(barcodeTypesDes, forKey: PropertyKey.barcodeTypeDes)
        aCoder.encode(barcodeTexts, forKey: PropertyKey.barcodeText)
        aCoder.encode(barcodeLocations, forKey: PropertyKey.barcodeLocations)
        aCoder.encode(decodeDate,forKey: PropertyKey.decodeDate)
        aCoder.encode(decodeTime,forKey: PropertyKey.decodeTime)
        aCoder.encode(coordinateNeedRotate,forKey: PropertyKey.coordinateNeedRotate)
    }
    
    static func GetBarcodeReaderInstance() -> DynamsoftBarcodeReader
    {
         return DynamsoftBarcodeReader(license: "f0068MgAAAAD4O091AxxjY/jIoPG4O9JBv0sIqaGf7TASs/Yf/j33pNHCqAhmuDlY9/gKqjUd3ueukcEzohiF9KxnKa9ARDw=" as String)
    }
    
    static func SetRuntimeSettings()
    {
        do
        {
            var settings = try BarcodeData.barcodeReader.getRuntimeSettings()
            settings.antiDamageLevel = RuntimeSettingsModel.runtimeSettings.antiDamageLevel
            settings.barcodeTypeID = RuntimeSettingsModel.runtimeSettings.barcodeTypeID
            settings.barcodeInvert = RuntimeSettingsModel.runtimeSettings.barcodeInvert
            settings.binarizationBlockSize = RuntimeSettingsModel.runtimeSettings.binarizationBlockSize
            settings.colourImageConvert = RuntimeSettingsModel.runtimeSettings.colourImageConvert
            settings.deblurLevel = RuntimeSettingsModel.runtimeSettings.deblurLevel
            settings.enableFillBinaryVacancy = RuntimeSettingsModel.runtimeSettings.enableFillBinaryVacancy
            settings.expectedBarcodeCount = RuntimeSettingsModel.runtimeSettings.expectedBarcodeCount
            settings.grayEqualizationSensitivity = RuntimeSettingsModel.runtimeSettings.grayEqualizationSensitivity
            settings.localizationAlgorithmPriority = RuntimeSettingsModel.runtimeSettings.localizationAlgorithmPriority
            settings.maxBarcodeCount = RuntimeSettingsModel.runtimeSettings.maxBarcodeCount
            settings.maxDimOfFullImageAsBarcodeZone = RuntimeSettingsModel.runtimeSettings.maxDimOfFullImageAsBarcodeZone
            settings.regionPredetection = RuntimeSettingsModel.runtimeSettings.regionPredetection
            settings.scaleDownThreshold = RuntimeSettingsModel.runtimeSettings.scaleDownThreshold
            settings.textFilter = RuntimeSettingsModel.runtimeSettings.textFilter
            settings.textureDetectionSensitivity = RuntimeSettingsModel.runtimeSettings.textureDetectionSensitivity
            settings.timeout = RuntimeSettingsModel.runtimeSettings.timeout
            
            var error:NSError? = NSError()
            BarcodeData.barcodeReader.updateRuntimeSettings(settings, error: &error)
//          BarcodeData.barcodeReader.setTemplateSettings(settings, error: nil);
            
            
            
//            //log:
//            settings = try BarcodeData.barcodeReader.getRuntimeSettings()
//            print(settings.antiDamageLevel)
//            print(settings.barcodeTypeID)
//            print(settings.barcodeInvert)
//            print(settings.binarizationBlockSize)
//            print(settings.colourImageConvert)
//            print(settings.deblurLevel)
//            print(settings.enableFillBinaryVacancy)
//            print(settings.expectedBarcodeCount)
//            print(settings.grayEqualizationSensitivity)
//            print(settings.localizationAlgorithmPriority)
//            print(settings.maxBarcodeCount)
//            print(settings.maxDimOfFullImageAsBarcodeZone)
//            print(settings.regionPredetection)
//            print(settings.scaleDownThreshold)
//            print(settings.textFilter)
//            print(settings.textureDetectionSensitivity)
//            print(settings.timeout)
        }
        catch{
            print(error);
        }
    }
}
