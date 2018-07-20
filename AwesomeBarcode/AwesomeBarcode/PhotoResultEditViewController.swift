//
//  PhotoResultEditViewController.swift
//  AwesomeBarcode
//
//  Created by Dynamsoft on 18/07/2018.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

import UIKit

class PhotoResultEditViewController: UIViewController {

    var imageBrowser:UIImageView!
    var previewImg:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageBrowser = UIImageView()
        self.imageBrowser.contentMode = .scaleAspectFit
        self.imageBrowser.frame = self.view.bounds
        self.imageBrowser.image = previewImg
        self.view.addSubview(self.imageBrowser)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
