//
//  BarcodeMaskView.swift
//  AwesomeBarcode
//
//  Created by Dynamsoft on 2018/7/9.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

import UIKit

class BarcodeMaskView: UIView {

    struct MaskViewConfiguration {
        static let lineColor: UIColor = #colorLiteral(red: 0, green: 0.8588235294, blue: 0, alpha: 1)
        static let regionColor: UIColor = #colorLiteral(red: 0, green: 0.8588235294, blue: 0, alpha: 1)
        static let lineWidth: CGFloat = 3
    }
    
    var maskPoints: [[CGPoint]] = [[CGPoint]]()
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        MaskViewConfiguration.regionColor.setStroke()
        let path = UIBezierPath()
        path.lineWidth = MaskViewConfiguration.lineWidth
        for mask in maskPoints {
            path.move(to: mask[0])
            path.addLine(to: mask[1])
            path.addLine(to: mask[2])
            path.addLine(to: mask[3])
            path.close()
            path.stroke()
        }
    }
 
    convenience init(frame: CGRect, maskPoints: [[CGPoint]]) {
        self.init(frame: frame)
        self.maskPoints = maskPoints
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("No implementation")
    }
    
    static func mixImage(_ image: UIImage, with quadrilaterals: [[CGPoint]]) -> UIImage {
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        let len = max(image.size.width,image.size.height)
        #colorLiteral(red: 0, green: 0.8588235294, blue: 0, alpha: 1).setStroke()
        let path = UIBezierPath()
        path.lineWidth = MaskViewConfiguration.lineWidth * len/1000
        for mask in quadrilaterals {
            path.move(to: mask[0])
            path.addLine(to: mask[1])
            path.addLine(to: mask[2])
            path.addLine(to: mask[3])
            path.close()
            path.stroke()
        }
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
}
