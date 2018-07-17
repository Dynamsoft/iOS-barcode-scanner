//
//  BarcodeData.swift
//  AwesomeBarcode
//
//  Created by Dynamsoft on 2018/7/5.
//  Copyright © 2018年 Dynamsoft. All rights reserved.
//

import UIKit

class BarcodeData: NSObject, NSCoding {
    let imagePath: URL
    let barcodeTypes: [String]
    let barcodeTexts: [String]
    let barcodeLocations: [[CGPoint]]
    
    struct PropertyKey {
        static let imagePath = "ImagePath"
        static let barcodeType = "BarcodeType"
        static let barcodeText = "BarcodeText"
        static let barcodeLocations = "BarcodeLocations"
    }
    
    static let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = documentDir.appendingPathComponent("barcode.data")
    
    static let barcodeReader = DynamsoftBarcodeReader(license: "t0068MgAAABhYnpGyll51x5q4jrPNUojC1czRgf4dREMHtyMSIyuHSpJA6SAL7NWTXsTyCtcgLKnYEOiGG+v0hTnZQkgUT7E=" as String);
    
    init(path: URL, type: [String], text: [String], locations: [[CGPoint]]) {
        self.imagePath = path
        self.barcodeTypes = type
        self.barcodeTexts = text
        self.barcodeLocations = locations
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let _imagePath = aDecoder.decodeObject(forKey: PropertyKey.imagePath) as? URL else { return nil }
        guard let _barcodeTypes = aDecoder.decodeObject(forKey: PropertyKey.barcodeType) as? [String] else { return nil }
        guard let _barcodeTexts = aDecoder.decodeObject(forKey: PropertyKey.barcodeText) as? [String] else { return nil }
        guard let _barcodeLocations = aDecoder.decodeObject(forKey: PropertyKey.barcodeLocations) as? [[CGPoint]] else { return nil }
        self.init(path: _imagePath, type: _barcodeTypes, text: _barcodeTexts, locations: _barcodeLocations)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(imagePath, forKey: PropertyKey.imagePath)
        aCoder.encode(barcodeTypes, forKey: PropertyKey.barcodeType)
        aCoder.encode(barcodeTexts, forKey: PropertyKey.barcodeText)
        aCoder.encode(barcodeLocations, forKey: PropertyKey.barcodeLocations)
    }
}
