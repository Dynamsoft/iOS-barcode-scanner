//
//  RuntimeSettingsModel.swift
//  AwesomeBarcode
//
//  Created by Dynamsoft on 03/08/2018.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

import UIKit

enum SettingScene{
    case GeneralScan
    case MulBrcdsBestCoverage
    case Overlapping
    case Panaroma
}



class RuntimeSettingsModel: NSObject, NSCoding {
    
    static var runtimeSettings:PublicSettings!
    static var settingScene:SettingScene!//1:General 2:MulBrcdsBestCoverage 3:MulBrcdsBalanceMode
    var name: String
    var antiDamageLevel:String
    var barcodeFormat:String
    var barcodeInvertMode:String
    var binarizationBlockSize:String
    var colourImageConvert:String
    var deblurLevel:String
    var enableFillBinaryVacancy:String
    var expectedBarcodeCount:String
    var grayEqualizationSensitivity:String
    var localizationAlgorithmPriority:String
    var maxBarcodeCount:String
    var maxDimofFullImageAsBarcodeZone:String
    var regionPredetection:String
    var scaleDownThreshold:String
    var textFilterMode:String
    var textureDetectionSensitivity:String
    var timeout:String
    
    struct PropertyKey {
        static let name = "TemplateName"
        static let antiDamageLevel = "AntiDamageLevel"
        static let barcodeFormat = "BarcodeFormat"
        static let barcodeInvertMode = "BarcodeInvertMode"
        static let binarizationBlockSize = "BinarizationBlockSize"
        static let colourImageConvert  = "ColourImageConvert"
        static let deblurLevel = "DeblurLevel"
        static let enableFillBinaryVacancy = "EnableFillBinaryVacancy"
        static let expectedBarcodeCount = "ExpectedBarcodesCount"
        static let grayEqualizationSensitivity  = "GrayEqualizationSensitivity"
        static let localizationAlgorithmPriority = "LocalizationAlgorithmPriority"
        static let maxBarcodeCount = "MaxBarcodeCount"
        static let maxDimofFullImageAsBarcodeZone = "MaxDimofFullImageAsBarcodeZone"
        static let regionPredetection = "RegionPredetection"
        static let scaleDownThreshold = "ScaleDownThreshold"
        static let textFilterMode = "TextFilterMode"
        static let textureDetectionSensitivity = "TextureDetectionSensitivity"
        static let timeout = "Timeout"
    }
    
    static let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = documentDir.appendingPathComponent("runtime.settings")

    init(setting:PublicSettings) {
        self.name = setting.name
        self.antiDamageLevel = String(setting.antiDamageLevel)
        self.barcodeFormat = String(setting.barcodeTypeID)
        self.barcodeInvertMode = String(RuntimeSettingsModel.GetBarcodeInvertIntVal(invertMode: setting.barcodeInvert))
        self.binarizationBlockSize = String(setting.binarizationBlockSize)
        self.colourImageConvert = String(RuntimeSettingsModel.GetColourImageConvertIntVal(convert: setting.colourImageConvert))
        self.deblurLevel = String(setting.deblurLevel)
        self.enableFillBinaryVacancy = String(setting.enableFillBinaryVacancy)
        self.expectedBarcodeCount = String(setting.expectedBarcodeCount)
        self.grayEqualizationSensitivity = String(setting.grayEqualizationSensitivity)
        self.localizationAlgorithmPriority = String(setting.localizationAlgorithmPriority)
        self.maxBarcodeCount = String(setting.maxBarcodeCount)
        self.maxDimofFullImageAsBarcodeZone = String(setting.maxDimOfFullImageAsBarcodeZone)
        self.regionPredetection = String(RuntimeSettingsModel.GetRegionPredetectionIntVal(rgnPrdtctn: setting.regionPredetection))
        self.scaleDownThreshold = String(setting.scaleDownThreshold)
        self.textFilterMode = String(RuntimeSettingsModel.GetTextFilterIntVal(txtFltr: setting.textFilter))
        self.textureDetectionSensitivity = String(setting.textureDetectionSensitivity)
        self.timeout = String(setting.timeout)
        RuntimeSettingsModel.runtimeSettings = setting
    }
    
    init(name: String,atDmgeLvl:String, format: String, brcdInvrtMode:String,bnrztnBlckSz:String,clrImgCnvrt:String,dblrLvl:String,enableFllBnryVcncy:String, expBrcdCount: String,gryEqlztionSnstvty:String,lclztionAlgrthmPrrty:String,maxBrcdCnt:String, maxDmOfFllImgAsBrcdZn:String,rgnPrdtction:String,sclDwnThrshld:String, txtFltrMode:String, txtrDtctionSnstvty:String, tmout: String) {
        self.name = name
        self.antiDamageLevel = atDmgeLvl
        self.barcodeFormat = format
        self.barcodeInvertMode = brcdInvrtMode
        self.binarizationBlockSize = bnrztnBlckSz
        self.colourImageConvert = clrImgCnvrt
        self.deblurLevel = dblrLvl
        self.enableFillBinaryVacancy = enableFllBnryVcncy
        self.expectedBarcodeCount = expBrcdCount
        self.grayEqualizationSensitivity = gryEqlztionSnstvty
        self.localizationAlgorithmPriority = lclztionAlgrthmPrrty
        self.maxBarcodeCount = maxBrcdCnt
        self.maxDimofFullImageAsBarcodeZone = maxDmOfFllImgAsBrcdZn
        self.regionPredetection = rgnPrdtction
        self.scaleDownThreshold = sclDwnThrshld
        self.textFilterMode = txtFltrMode
        self.textureDetectionSensitivity = txtrDtctionSnstvty
        self.timeout = tmout
        
        //set RuntimeSettingsModel.runtimeSettings
        do
        {
            RuntimeSettingsModel.runtimeSettings = try BarcodeData.barcodeReader.getRuntimeSettings()
            RuntimeSettingsModel.runtimeSettings.name = self.name
            RuntimeSettingsModel.runtimeSettings.antiDamageLevel = Int(self.antiDamageLevel)!
            RuntimeSettingsModel.runtimeSettings.barcodeTypeID = Int(self.barcodeFormat)!
            RuntimeSettingsModel.runtimeSettings.barcodeInvert =  RuntimeSettingsModel.GetBarcodeInvertByIntVal(val: Int(self.barcodeInvertMode)!)
            RuntimeSettingsModel.runtimeSettings.binarizationBlockSize = Int(self.binarizationBlockSize)!
            RuntimeSettingsModel.runtimeSettings.colourImageConvert = RuntimeSettingsModel.GetColourImageConvertByIntVal(val: Int(self.colourImageConvert)!)
            RuntimeSettingsModel.runtimeSettings.deblurLevel = Int(self.deblurLevel)!
            RuntimeSettingsModel.runtimeSettings.enableFillBinaryVacancy = Int(self.enableFillBinaryVacancy)!
            RuntimeSettingsModel.runtimeSettings.expectedBarcodeCount =  Int(self.expectedBarcodeCount)!
            RuntimeSettingsModel.runtimeSettings.grayEqualizationSensitivity = Int(self.grayEqualizationSensitivity)!
            RuntimeSettingsModel.runtimeSettings.localizationAlgorithmPriority = self.localizationAlgorithmPriority
            RuntimeSettingsModel.runtimeSettings.maxBarcodeCount = Int(self.maxBarcodeCount)!
            RuntimeSettingsModel.runtimeSettings.maxDimOfFullImageAsBarcodeZone = Int(self.maxDimofFullImageAsBarcodeZone)!
            RuntimeSettingsModel.runtimeSettings.regionPredetection = RuntimeSettingsModel.GetRegionPredetectionByIntVal(val: Int(self.regionPredetection)!)
            RuntimeSettingsModel.runtimeSettings.scaleDownThreshold = Int(self.scaleDownThreshold)!
            RuntimeSettingsModel.runtimeSettings.textFilter = RuntimeSettingsModel.GetTextFilterByIntVal(val: Int(self.textFilterMode)!)
            RuntimeSettingsModel.runtimeSettings.textureDetectionSensitivity = Int(self.textureDetectionSensitivity)!
            RuntimeSettingsModel.runtimeSettings.timeout = Int(self.timeout)!
        }
        catch{
            print(error);
        }
    }

    static func GetGeneralScanSettings() -> PublicSettings
    {
        var defaultSetting = PublicSettings()
        do
        {
            if(RuntimeSettingsModel.runtimeSettings != nil)
            {
                defaultSetting = RuntimeSettingsModel.runtimeSettings
            }
            else
            {
                defaultSetting = try BarcodeData.barcodeReader.getRuntimeSettings()
            }
            defaultSetting.name = "Custom_134010_125"
            defaultSetting.antiDamageLevel = 9
            defaultSetting.barcodeTypeID = BarcodeType.ALL.rawValue
            defaultSetting.barcodeInvert = BarcodeInvert.darkOnLight
            defaultSetting.binarizationBlockSize = 0
            defaultSetting.colourImageConvert = ColourImageConvert.auto
            defaultSetting.deblurLevel = 9
            defaultSetting.enableFillBinaryVacancy = 1
            defaultSetting.expectedBarcodeCount = 0
            defaultSetting.grayEqualizationSensitivity = 0
            defaultSetting.localizationAlgorithmPriority = ""
            defaultSetting.maxBarcodeCount = 2147483647
            defaultSetting.maxDimOfFullImageAsBarcodeZone = 262144
            defaultSetting.regionPredetection = RegionPredetection.disable
            defaultSetting.scaleDownThreshold = 2300
            defaultSetting.textFilter = TextFilter.enable
            defaultSetting.textureDetectionSensitivity = 5
            defaultSetting.timeout = 10000
        }
        catch{
            print(error);
        }
        return defaultSetting
    }
    
    static func GetMulBrcdsBestCoverageSettings() -> PublicSettings
    {
        var defaultSetting = PublicSettings()
        do
        {
            if(RuntimeSettingsModel.runtimeSettings != nil)
            {
                defaultSetting = RuntimeSettingsModel.runtimeSettings
            }
            else
            {
                defaultSetting = try BarcodeData.barcodeReader.getRuntimeSettings()
            }
            defaultSetting.name = "Custom_134010_126"
            defaultSetting.antiDamageLevel = 7
            defaultSetting.barcodeTypeID = BarcodeType.ALL.rawValue
            defaultSetting.barcodeInvert = BarcodeInvert.darkOnLight
            defaultSetting.binarizationBlockSize = 0
            defaultSetting.colourImageConvert = ColourImageConvert.auto
            defaultSetting.deblurLevel = 9
            defaultSetting.enableFillBinaryVacancy = 1
            defaultSetting.expectedBarcodeCount = 0
            defaultSetting.grayEqualizationSensitivity = 0
            defaultSetting.localizationAlgorithmPriority = ""
            defaultSetting.maxBarcodeCount = 2147483647
            defaultSetting.maxDimOfFullImageAsBarcodeZone = 262144
            defaultSetting.regionPredetection = RegionPredetection.disable
            defaultSetting.scaleDownThreshold = 1000
            defaultSetting.textFilter = TextFilter.enable
            defaultSetting.textureDetectionSensitivity = 5
            defaultSetting.timeout = 10000
        }
        catch{
            print(error);
        }
        return defaultSetting
    }
    
    static func GetOverlappingSettings() -> PublicSettings
    {
        var defaultSetting = PublicSettings()
        do
        {
            if(RuntimeSettingsModel.runtimeSettings != nil)
            {
                defaultSetting = RuntimeSettingsModel.runtimeSettings
            }
            else
            {
                defaultSetting = try BarcodeData.barcodeReader.getRuntimeSettings()
            }
            defaultSetting.name = "Custom_134010_127"
            defaultSetting.antiDamageLevel = 5
            defaultSetting.barcodeTypeID = BarcodeType.ALL.rawValue
            defaultSetting.barcodeInvert = BarcodeInvert.darkOnLight
            defaultSetting.binarizationBlockSize = 0
            defaultSetting.colourImageConvert = ColourImageConvert.auto
            defaultSetting.deblurLevel = 5
            defaultSetting.enableFillBinaryVacancy = 1
            defaultSetting.expectedBarcodeCount = 0
            defaultSetting.grayEqualizationSensitivity = 0
            defaultSetting.localizationAlgorithmPriority = "ConnectedBlock,Lines,Statistics, FullImageAsBarcodeZone"
            defaultSetting.maxBarcodeCount = 2147483647
            defaultSetting.maxDimOfFullImageAsBarcodeZone = 262144
            defaultSetting.regionPredetection = RegionPredetection.disable
            defaultSetting.scaleDownThreshold = 1000
            defaultSetting.textFilter = TextFilter.enable
            defaultSetting.textureDetectionSensitivity = 5
            defaultSetting.timeout = 10000
        }
        catch{
            print(error);
        }
        return defaultSetting
    }
    
    static func GetPanaromaSettings() -> PublicSettings
    {
        var defaultSetting = PublicSettings()
        do
        {
            if(RuntimeSettingsModel.runtimeSettings != nil)
            {
                defaultSetting = RuntimeSettingsModel.runtimeSettings
            }
            else
            {
                defaultSetting = try BarcodeData.barcodeReader.getRuntimeSettings()
            }
            defaultSetting.name = "Custom_134010_127"
            defaultSetting.antiDamageLevel = 5
            defaultSetting.barcodeTypeID = BarcodeType.ALL.rawValue
            defaultSetting.barcodeInvert = BarcodeInvert.darkOnLight
            defaultSetting.binarizationBlockSize = 0
            defaultSetting.colourImageConvert = ColourImageConvert.auto
            defaultSetting.deblurLevel = 5
            defaultSetting.enableFillBinaryVacancy = 1
            defaultSetting.expectedBarcodeCount = 0
            defaultSetting.grayEqualizationSensitivity = 0
            defaultSetting.localizationAlgorithmPriority = "ConnectedBlock,Lines,Statistics, FullImageAsBarcodeZone"
            defaultSetting.maxBarcodeCount = 2147483647
            defaultSetting.maxDimOfFullImageAsBarcodeZone = 262144
            defaultSetting.regionPredetection = RegionPredetection.disable
            defaultSetting.scaleDownThreshold = 1000
            defaultSetting.textFilter = TextFilter.enable
            defaultSetting.textureDetectionSensitivity = 5
            defaultSetting.timeout = 10000
        }
        catch{
            print(error);
        }
        return defaultSetting
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let _name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else { return nil }
        guard let _antiDamageLevel = aDecoder.decodeObject(forKey: PropertyKey.antiDamageLevel) as? String else { return nil }

        guard let _barcodeFormat = aDecoder.decodeObject(forKey: PropertyKey.barcodeFormat) as? String else { return nil }
        guard let _barcodeInvert = aDecoder.decodeObject(forKey: PropertyKey.barcodeInvertMode) as? String else { return nil }
        guard let _binarizationBlockSize = aDecoder.decodeObject(forKey: PropertyKey.binarizationBlockSize) as? String else { return nil }
        guard let _colourImageConvert = aDecoder.decodeObject(forKey: PropertyKey.colourImageConvert) as? String else {return nil}
        guard let _deblurLevel = aDecoder.decodeObject(forKey: PropertyKey.deblurLevel) as? String else {return nil}
        guard let _enableFillBinaryVacancy = aDecoder.decodeObject(forKey: PropertyKey.enableFillBinaryVacancy) as? String else { return nil }
        guard let _expectedBarcodeCount = aDecoder.decodeObject(forKey: PropertyKey.expectedBarcodeCount) as? String else { return nil }
        guard let _grayEqualizationSensitivity = aDecoder.decodeObject(forKey: PropertyKey.grayEqualizationSensitivity) as? String else { return nil }
        guard let _localizationAlgorithmPriority = aDecoder.decodeObject(forKey: PropertyKey.localizationAlgorithmPriority) as? String else { return nil }
        guard let _maxBarcodeCount = aDecoder.decodeObject(forKey: PropertyKey.maxBarcodeCount) as? String else {return nil}
        guard let _maxDimOfFullImageAsBarcodeZone = aDecoder.decodeObject(forKey: PropertyKey.maxDimofFullImageAsBarcodeZone) as? String else {return nil}
        guard let _regionPredetection = aDecoder.decodeObject(forKey: PropertyKey.regionPredetection) as? String else { return nil }
        guard let _scaleDownThreshold = aDecoder.decodeObject(forKey: PropertyKey.scaleDownThreshold) as? String else { return nil }
        guard let _textFilterMode = aDecoder.decodeObject(forKey: PropertyKey.textFilterMode) as? String else { return nil }
        guard let _textureDetectionSensitivity = aDecoder.decodeObject(forKey: PropertyKey.textureDetectionSensitivity) as? String else { return nil }
        guard let _timeout = aDecoder.decodeObject(forKey: PropertyKey.timeout) as? String else {return nil}

        self.init(name: _name, atDmgeLvl: _antiDamageLevel, format: _barcodeFormat, brcdInvrtMode: _barcodeInvert, bnrztnBlckSz: _binarizationBlockSize, clrImgCnvrt: _colourImageConvert, dblrLvl: _deblurLevel, enableFllBnryVcncy: _enableFillBinaryVacancy, expBrcdCount: _expectedBarcodeCount, gryEqlztionSnstvty: _grayEqualizationSensitivity, lclztionAlgrthmPrrty: _localizationAlgorithmPriority, maxBrcdCnt: _maxBarcodeCount, maxDmOfFllImgAsBrcdZn: _maxDimOfFullImageAsBarcodeZone, rgnPrdtction: _regionPredetection, sclDwnThrshld: _scaleDownThreshold, txtFltrMode: _textFilterMode, txtrDtctionSnstvty: _textureDetectionSensitivity, tmout: _timeout)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: PropertyKey.name)
        aCoder.encode(self.antiDamageLevel, forKey: PropertyKey.antiDamageLevel)
        aCoder.encode(self.barcodeFormat, forKey: PropertyKey.barcodeFormat)
        aCoder.encode(self.barcodeInvertMode , forKey: PropertyKey.barcodeInvertMode)
        aCoder.encode(self.binarizationBlockSize,forKey: PropertyKey.binarizationBlockSize)
        aCoder.encode(self.colourImageConvert ,forKey: PropertyKey.colourImageConvert)
        aCoder.encode(self.deblurLevel,forKey: PropertyKey.deblurLevel)
        aCoder.encode(self.enableFillBinaryVacancy,forKey: PropertyKey.enableFillBinaryVacancy)
        aCoder.encode(self.expectedBarcodeCount,forKey: PropertyKey.expectedBarcodeCount)
        aCoder.encode(self.grayEqualizationSensitivity,forKey: PropertyKey.grayEqualizationSensitivity)
        aCoder.encode(self.localizationAlgorithmPriority,forKey: PropertyKey.localizationAlgorithmPriority)
        aCoder.encode(self.maxBarcodeCount,forKey: PropertyKey.maxBarcodeCount)
        aCoder.encode(self.maxDimofFullImageAsBarcodeZone,forKey: PropertyKey.maxDimofFullImageAsBarcodeZone)
        aCoder.encode(self.regionPredetection,forKey: PropertyKey.regionPredetection)
        aCoder.encode(self.scaleDownThreshold,forKey: PropertyKey.scaleDownThreshold)
        aCoder.encode(self.textFilterMode,forKey: PropertyKey.textFilterMode)
        aCoder.encode(self.textureDetectionSensitivity,forKey: PropertyKey.textureDetectionSensitivity)
        aCoder.encode(self.timeout,forKey: PropertyKey.timeout)
    }

    static func GetTextFilterIntVal(txtFltr:TextFilter)  -> Int{
        return txtFltr == .disable ? 1 : 2
    }

    static func GetTextFilterByIntVal(val:Int) -> TextFilter {
        return val == 1 ? .disable : .enable
    }

    static func GetRegionPredetectionIntVal(rgnPrdtctn:RegionPredetection) -> Int{
        return rgnPrdtctn == RegionPredetection.disable ? 1 : 2
    }

    static func GetRegionPredetectionByIntVal(val:Int) -> RegionPredetection {
        return val == 1 ? .disable : .enable
    }

    static func GetBarcodeInvertIntVal(invertMode:BarcodeInvert) -> Int{
        return invertMode == .darkOnLight ? 1 : 2
    }

    static func GetBarcodeInvertByIntVal(val:Int) -> BarcodeInvert{
        return val == 1 ? .darkOnLight : .lightOnDark
    }

    static func GetColourImageConvertIntVal(convert:ColourImageConvert) -> Int{
        return convert == .auto ? 1 : 2
    }

    static func GetColourImageConvertByIntVal(val:Int) -> ColourImageConvert{
        return val == 1 ? .auto : .grayScale
    }
    
}
