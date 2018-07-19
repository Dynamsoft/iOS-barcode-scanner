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

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.imageBrowser = UIImageView()
        self.imageBrowser.frame = self.view.bounds
        self.imageBrowser.image = previewImg
        self.view.addSubview(self.imageBrowser)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
