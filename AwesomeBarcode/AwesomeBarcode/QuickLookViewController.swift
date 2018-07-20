//
//  QuickLookViewController.swift
//  AwesomeBarcode
//
//  Created by Dynamsoft on 2018/7/3.
//  Copyright © 2018年 Dynamsoft. All rights reserved.
//

import UIKit

class QuickLookViewController: UIViewController {

    @IBOutlet weak var imageBrowser: UIScrollView!
    var maskView = BarcodeMaskView(frame: .zero)
    var localBarcode: [BarcodeData]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: BarcodeData.ArchiveURL.path) as? [BarcodeData]
    }
    var index: Int = 0
    var imageViews = [UIImageView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for (i, barcode) in localBarcode!.enumerated() {
            var originImage = UIImage(contentsOfFile: barcode.imagePath.path)
//            results.map{ self.pixelPointsFromResult($0.localizationResult!.resultPoints!, in: originImage!.size) }
            let image = BarcodeMaskView.mixImage(originImage!, with: barcode.barcodeLocations)
            originImage = nil
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: CGFloat(i) * FullScreenSize.width, y: 0, width: FullScreenSize.width, height: FullScreenSize.height - 64)
            imageView.contentMode = .scaleAspectFit
            imageViews.append(imageView)
//            setMaskView(at: i)
            imageBrowser.addSubview(imageView)
        }
        imageBrowser.contentSize = CGSize(width: CGFloat(localBarcode!.count) * imageBrowser.bounds.width, height: imageBrowser.bounds.height)
        imageBrowser.bounces = false
        imageBrowser.contentOffset = CGPoint(x: CGFloat(index) * imageBrowser.bounds.width, y: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setMaskView(at i: Int) {
        maskView.frame = GetMaskViewBound(at: i)
        imageViews[i].addSubview(maskView)
        let quadrilaterals = localBarcode![i].barcodeLocations.map { self.pointsFromResult($0)}
        maskView.maskPoints = quadrilaterals
        maskView.setNeedsDisplay()
    }
    
    func GetMaskViewBound(at i: Int) -> CGRect {
        let hfactor = imageViews[i].image!.size.width / imageViews[i].frame.size.width
        let vfactor = imageViews[i].image!.size.height / imageViews[i].frame.size.height
        
        let factor = max(hfactor, vfactor)
        
        // Divide the size by the greater of the vertical or horizontal shrinkage factor
        let newWidth = imageViews[i].image!.size.width / factor
        let newHeight = imageViews[i].image!.size.height / factor
        
        // Then figure out if you need to offset it to center vertically or horizontally
        let leftOffset = (imageViews[i].frame.size.width - newWidth) / 2
        let topOffset = (imageViews[i].frame.size.height - newHeight) / 2
        
        return CGRect(x: leftOffset, y: topOffset, width: newWidth, height: newHeight)
    }

    func pointsFromResult(_ result: [CGPoint]) -> [CGPoint] {
        
        let point0 = CGPoint(x: result[0].x-10, y: result[0].y+54)
        let point1 = CGPoint(x: result[1].x-10, y: result[1].y+54)
        let point2 = CGPoint(x: result[2].x-10, y: result[2].y+54)
        let point3 = CGPoint(x: result[3].x-10, y: result[3].y+54)
        
        return [point0, point1, point2, point3]
    }
}
