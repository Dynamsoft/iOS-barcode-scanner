//
//  File.swift
//  AwesomeBarcode
//
//  Created by Dynamsoft on 2018/7/10.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

import Foundation

extension BarcodeType {
    var description: String {
        switch self {
        case BarcodeType.CODE39:
            return "CODE_39"
        case BarcodeType.CODE128:
            return "CODE_128"
        case BarcodeType.CODE93:
            return "CODE_93"
        case BarcodeType.CODABAR:
            return "CODABAR"
        case BarcodeType.ITF:
            return "ITF"
        case BarcodeType.UPCA:
            return "UPC_A"
        case BarcodeType.UPCE:
            return "UPC_E"
        case BarcodeType.EAN13:
            return "EAN_13"
        case BarcodeType.EAN8:
            return "EAN_8"
        case BarcodeType.INDUSTRIAL:
            return "INDUSTRIAL_25"
        case BarcodeType.ONED:
            return "OneD"
        case BarcodeType.QRCODE:
            return "QR_CODE"
        case BarcodeType.PDF417:
            return "PDF417"
        case BarcodeType.DATAMATRIX:
            return "DATAMATRIX"
        case BarcodeType.AZTEC:
            return "AZTEC"
        default:
            return "UNKNOWN"
        }
    }
}
