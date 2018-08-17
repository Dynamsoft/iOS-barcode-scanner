//
//  OneDBarcodeTypeTableViewController.swift
//  AwesomeBarcode
//
//  Created by Dynamsoft on 08/08/2018.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

import UIKit

class OneDBarcodeTypeTableViewController: UITableViewController {
    
    var mainView: RuntimeSettingsTableViewController!
    let tableDataArr = [["CODE_39", "CODE_128", "CODE_93", "CODABAR", "ITF", "EAN_13", "EAN_8", "UPC_A", "UPC_E", "INDUSTRIAL_25"]]
    
    var runtimeSettings:PublicSettings!
    var barcodeFormat_code39_btn:UIButton!
    var barcodeFormat_code128_btn:UIButton!
    var barcodeFormat_code93_btn:UIButton!
    var barcodeFormat_codebar_btn:UIButton!
    var barcodeFormat_itf_btn:UIButton!
    var barcodeFormat_ean13_btn:UIButton!
    var barcodeFormat_ean8_btn:UIButton!
    var barcodeFormat_upca_btn:UIButton!
    var barcodeFormat_upce_btn:UIButton!
    var barcodeFormat_industrial25_btn:UIButton!
    //    var buttonArr:[UIButton]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = ""
        self.tableView!.register(UINib(nibName:"SettingTableViewCell", bundle:nil),forCellReuseIdentifier:"settingCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! SettingTableViewCell
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "settingCell") as! SettingTableViewCell
        }
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview();
        }
        cell.selectionStyle = .none
        cell.accessoryType = .none
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byCharWrapping
        cell.textLabel?.font  = UIFont(name: "", size: 9)
        cell.textLabel?.textColor = RuntimeSettingsTableViewController.TextColor;
        cell.textLabel?.text = self.tableDataArr[indexPath.section][indexPath.row]
        if (indexPath.section == 0)
        {
            switch(indexPath.row)
            {
            case 0:
                self.setupBarcodeFormatCODE39(cell:cell)
                break
            case 1:
                self.setupBarcodeFormatCODE128(cell:cell)
                break
            case 2:
                self.setupBarcodeFormatCODE93(cell:cell)
                break
            case 3:
                self.setupBarcodeFormatCODEBAR(cell:cell)
                break
            case 4:
                self.setupBarcodeFormatITF(cell:cell)
                break
            case 5:
                self.setupBarcodeFormatEAN13(cell:cell)
                break
            case 6:
                self.setupBarcodeFormatEAN8(cell:cell)
                break
            case 7:
                self.setupBarcodeFormatUPCA(cell:cell)
                break
            case 8:
                self.setupBarcodeFormatUPCE(cell:cell)
                break
            default:
                self.setupBarcodeFormatINDUSTRIAL25(cell:cell)
                break
            }
        }
        
        return cell
    }
    
    func setupBarcodeFormatCODE39(cell:UITableViewCell)
    {
        let ckBox = self.getCheckBox(cell: cell, rightMargin: -31)
        ckBox.isSelected = (self.runtimeSettings!.barcodeTypeID | BarcodeType.CODE39.rawValue) == self.runtimeSettings!.barcodeTypeID
        self.barcodeFormat_code39_btn = ckBox
    }
    
    func setupBarcodeFormatCODE128(cell:UITableViewCell)
    {
        let ckBox = self.getCheckBox(cell: cell, rightMargin: -31)
        ckBox.isSelected = (self.runtimeSettings!.barcodeTypeID | BarcodeType.CODE128.rawValue) == self.runtimeSettings!.barcodeTypeID
        self.barcodeFormat_code128_btn = ckBox
    }
    
    func setupBarcodeFormatCODE93(cell:UITableViewCell)
    {
        let ckBox = self.getCheckBox(cell: cell, rightMargin: -31)
        ckBox.isSelected = (self.runtimeSettings!.barcodeTypeID | BarcodeType.CODE93.rawValue) == self.runtimeSettings!.barcodeTypeID
        self.barcodeFormat_code93_btn = ckBox
    }
    
    func setupBarcodeFormatCODEBAR(cell:UITableViewCell)
    {
        let ckBox = self.getCheckBox(cell: cell, rightMargin: -31)
        ckBox.isSelected = (self.runtimeSettings!.barcodeTypeID | BarcodeType.CODABAR.rawValue) == self.runtimeSettings!.barcodeTypeID
        self.barcodeFormat_codebar_btn = ckBox
    }
    
    func setupBarcodeFormatITF(cell:UITableViewCell)
    {
        let ckBox = self.getCheckBox(cell: cell, rightMargin: -31)
        ckBox.isSelected = (self.runtimeSettings!.barcodeTypeID | BarcodeType.ITF.rawValue) == self.runtimeSettings!.barcodeTypeID
        self.barcodeFormat_itf_btn = ckBox
    }
    
    func setupBarcodeFormatEAN13(cell:UITableViewCell)
    {
        let ckBox = self.getCheckBox(cell: cell, rightMargin: -31)
        ckBox.isSelected = (self.runtimeSettings!.barcodeTypeID | BarcodeType.EAN13.rawValue) == self.runtimeSettings!.barcodeTypeID
        self.barcodeFormat_ean13_btn = ckBox
    }
    
    func setupBarcodeFormatEAN8(cell:UITableViewCell)
    {
        let ckBox = self.getCheckBox(cell: cell, rightMargin: -31)
        ckBox.isSelected = (self.runtimeSettings!.barcodeTypeID | BarcodeType.EAN8.rawValue) == self.runtimeSettings!.barcodeTypeID
        self.barcodeFormat_ean8_btn = ckBox
    }
    
    func setupBarcodeFormatUPCA(cell:UITableViewCell)
    {
        let ckBox = self.getCheckBox(cell: cell, rightMargin: -31)
        ckBox.isSelected = (self.runtimeSettings!.barcodeTypeID | BarcodeType.UPCA.rawValue) == self.runtimeSettings!.barcodeTypeID
        self.barcodeFormat_upca_btn = ckBox
    }
    
    func setupBarcodeFormatUPCE(cell:UITableViewCell)
    {
        let ckBox = self.getCheckBox(cell: cell, rightMargin: -31)
        ckBox.isSelected = (self.runtimeSettings!.barcodeTypeID | BarcodeType.UPCE.rawValue) == self.runtimeSettings!.barcodeTypeID
        self.barcodeFormat_upce_btn = ckBox
    }
    
    func setupBarcodeFormatINDUSTRIAL25(cell:UITableViewCell)
    {
        let ckBox = self.getCheckBox(cell: cell, rightMargin: -31)
        ckBox.isSelected = (self.runtimeSettings!.barcodeTypeID | BarcodeType.INDUSTRIAL.rawValue) == self.runtimeSettings!.barcodeTypeID
        self.barcodeFormat_industrial25_btn = ckBox
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0)
        {
            switch(indexPath.row)
            {
            case 0:
                self.barcodeFormat_code39_btn.isSelected = !self.barcodeFormat_code39_btn.isSelected
                break
            case 1:
                self.barcodeFormat_code128_btn.isSelected = !self.barcodeFormat_code128_btn.isSelected
                break
            case 2:
                self.barcodeFormat_code93_btn.isSelected = !self.barcodeFormat_code93_btn.isSelected
                break
            case 3:
                self.barcodeFormat_codebar_btn.isSelected = !self.barcodeFormat_codebar_btn.isSelected
                break
            case 4:
                self.barcodeFormat_itf_btn.isSelected = !self.barcodeFormat_itf_btn.isSelected
                break
            case 5:
                self.barcodeFormat_ean13_btn.isSelected = !self.barcodeFormat_ean13_btn.isSelected
                break
            case 6:
                self.barcodeFormat_ean8_btn.isSelected = !self.barcodeFormat_ean8_btn.isSelected
                break
            case 7:
                self.barcodeFormat_upca_btn.isSelected = !self.barcodeFormat_upca_btn.isSelected
                break
            case 8:
                self.barcodeFormat_upce_btn.isSelected = !self.barcodeFormat_upce_btn.isSelected
                break
            default:
                self.barcodeFormat_industrial25_btn.isSelected = !self.barcodeFormat_industrial25_btn.isSelected
                break
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        var types = 0;
        if(self.barcodeFormat_code39_btn.isSelected)
        {
            types = types | BarcodeType.CODE39.rawValue;
        }
        if(self.barcodeFormat_code128_btn.isSelected)
        {
            types = types | BarcodeType.CODE128.rawValue;
        }
        if(self.barcodeFormat_code93_btn.isSelected)
        {
            types = types | BarcodeType.CODE93.rawValue;
        }
        if(self.barcodeFormat_codebar_btn.isSelected)
        {
            types = types | BarcodeType.CODABAR.rawValue;
        }
        if(self.barcodeFormat_itf_btn.isSelected)
        {
            types = types | BarcodeType.ITF.rawValue;
        }
        if(self.barcodeFormat_ean13_btn.isSelected)
        {
            types = types | BarcodeType.EAN13.rawValue;
        }
        if(self.barcodeFormat_ean8_btn.isSelected)
        {
            types = types | BarcodeType.EAN8.rawValue;
        }
        if(self.barcodeFormat_upca_btn.isSelected)
        {
            types = types | BarcodeType.UPCA.rawValue;
        }
        if(self.barcodeFormat_upce_btn.isSelected)
        {
            types = types | BarcodeType.UPCE.rawValue;
        }
        if(self.barcodeFormat_industrial25_btn.isSelected)
        {
            types = types | BarcodeType.INDUSTRIAL.rawValue;
        }
        if(mainView != nil)
        {
            let allOneDTypeInvert = ~BarcodeType.ONED.rawValue;
            mainView.runtimeSettings.barcodeTypeID = mainView.runtimeSettings.barcodeTypeID & allOneDTypeInvert;
            mainView.runtimeSettings.barcodeTypeID = mainView.runtimeSettings.barcodeTypeID | types;
        }
        super.viewWillDisappear(animated);
    }
    
    func getCheckBox(cell:UITableViewCell,rightMargin: CGFloat) ->UIButton
    {
        let bx = UIButton()
        bx.backgroundColor = UIColor.clear
        bx.frame = CGRect(x: 0, y: 0, width: 16, height: 11)
        let img = UIImage(named: "check")
        bx.setImage(img, for: .selected)
        
        let shade = UIView()
        shade.backgroundColor = UIColor.clear
        shade.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        
        let tView = UIView()
        tView.backgroundColor = UIColor.clear
        tView.frame.size = shade.frame.size
        tView.addSubview(bx)
        tView.addSubview(shade)
        cell.contentView.addSubview(tView)
        tView.snp_remakeConstraints { (make) in
            make.centerY.equalTo(cell.contentView)
            make.right.equalTo(rightMargin)
        }
        return bx
    }
    
}
