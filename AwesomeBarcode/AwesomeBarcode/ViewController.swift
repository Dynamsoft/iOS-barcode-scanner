//
//  ViewController.swift
//  AwesomeBarcode
//
//  Created by Dynamsoft on 2018/5/29.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var splitLine: UIView!
    @IBOutlet weak var titleBarcodeScannerX: UILabel!
    @IBOutlet weak var GeneralScanBtn: UIButton!
    @IBOutlet weak var MulBacdBestConverageBtn: UIButton!
    @IBOutlet weak var MulBacdBalancecModBtn: UIButton!
    @IBOutlet weak var HistoryBtn: UIButton!

    var startRecognitionDate:NSDate?
    var runtimeSettings:PublicSettings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        runtimeSettings = PublicSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let btn = sender as! UIButton
        var settings: PublicSettings?  = nil
        switch btn.tag {
        case 1:
            
            let temp = NSKeyedUnarchiver.unarchiveObject(withFile: RuntimeSettingsModel.ArchiveURL.path)as? RuntimeSettingsModel
            if (temp) == nil {
                settings = RuntimeSettingsModel.GetGeneralScanSettings()
            }
            RuntimeSettingsModel.settingScene = SettingScene.GeneralScan
            break
        case 2:
            settings = RuntimeSettingsModel.GetMulBrcdsBestCoverageSettings()
            RuntimeSettingsModel.settingScene = SettingScene.MulBrcdsBestCoverage
            break
        case 3:
            settings = RuntimeSettingsModel.GetMulBrcdsBalanceModeSettings()
            RuntimeSettingsModel.settingScene = SettingScene.MulBrcdsBalanceMode
            break
        default:
            break
        }
        if(settings != nil)
        {
            RuntimeSettingsModel.runtimeSettings = settings
        }
        BarcodeData.barcodeReader = BarcodeData.GetBarcodeReaderInstance()
        BarcodeData.SetRuntimeSettings()
    }
    
    func setUI(){
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.topItem?.title = "";
        self.splitLine.frame = CGRect(x: 0, y: FullScreenSize.height - 39, width: FullScreenSize.width, height: 1)
        self.titleBarcodeScannerX.frame = CGRect(x: 25, y: 122, width: 204.5, height: 17.5)
        self.HistoryBtn.frame = CGRect(x: FullScreenSize.width - 44, y: 58, width: 24, height: 24)
        self.GeneralScanBtn.frame = CGRect(x: 20, y: 196, width: 175, height: 175)
        self.MulBacdBalancecModBtn.frame = CGRect(x: 20, y: 407, width: 175, height: 175)
        self.MulBacdBestConverageBtn.frame = CGRect(x: FullScreenSize.width - 195, y: 301, width: 175, height: 175)
    }
}
