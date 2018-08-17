//
//  RuntimeSettingsTableViewController.swift
//  AwesomeBarcode
//
//  Created by Dynamsoft on 25/07/2018.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

import UIKit

class RuntimeSettingsTableViewController: UITableViewController,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate{
    static let TextColor  = UIColor(red: 27.999/255.0, green: 27.999/255.0, blue: 27.999/255.0, alpha: 1)
    
    static let TextFieldColor = UIColor(red: 153.003/255.0, green: 153.003/255.0, blue: 153.003/255.0, alpha: 1)
    
    let tableDataArr = [["Template Name:"], ["ONED", "PDF417", "QR_CODE", "DATAMATRIX","AZTEC"], ["Expected Barcodes Count:", "Timeout:", "DeblurLevel:", "Anti-Damage Level:", "Text Filter Mode:", "Region Predetection Mode:", "Scale Down Threshold:", "Colour Image Convert Mode:", "Barcode Invert Mode:", "Gray Equalization Sensitivity:", "Texture Detection Sensitivity:", "Binarization Block Size:", "Localization Algorithm Priority:", "Max Dim of Full Image As Barcode\nZone:", "Max Barcode Count:", "Enable Fill Binary Vacancy:"]]
    
    let deblerLeverArr = ["0","1","2","3","4","5","6","7","8","9"]
    let antiDamageLeverArr = ["0","1","2","3","4","5","6","7","8","9"]
    let colorImgCnvtModeArr = ["Auto","Grayscale"]
    let barcdIvrtModeArr = ["DarkOnLight","LightOnDark"]
    let grayEqualizationSensityArr = ["0","1","2","3","4","5","6","7","8","9"]
    let txtureDtctionSensitivityArr = ["0","1","2","3","4","5"]
    var curDataArr:[String]!
    var pickView:UIPickerView?
    var colorImageConvert:ColourImageConvert!
    var barcdInvertMode:BarcodeInvert!
//    var loclAlgorithmPriority:
    var OneDType = 0
    var templateNameTextField:UITextField!
    var barcodeFormat_pdf417:UIButton!
    var barcodeFormat_qrcode:UIButton!
    var barcodeFormat_datamatrix:UIButton!
    var barcodeFormat_aztec:UIButton!
    var expectedBrcdCountTextField:UITextField!
    var timeoutTextFieldCellTextField:UITextField!
    var deblurLevelCellTextField:UITextField!
    var antidamageLevelCellTextField:UITextField!
    var scaleDownThresholdCellTextField:UITextField!
    var colourImageConvertModeCellTextField:UITextField!
    var textFilterModeCellSwitch:UISwitch!
    var regionPredetectionModeCellSwitch:UISwitch!
    var barcodeInvertModeCellTextField:UITextField!//8
    var grayEqualizationSensitivityCellTextField:UITextField!//9
    var textureDetectionSentitivityCellTextField:UITextField!//10
    var binatizationBlockSizeCellTextField:UITextField!//11
    var maxDimofFullImageAsBarcodeZoneCellTextField:UITextField!//13
    var maxBarcodeCountCellTextField:UITextField!//14
    var enableFillBinaryVacancySwitch:UISwitch!//15
    var selectIndexPath:IndexPath?
    var runtimeSettings:PublicSettings!
    var previewTextTield:UITextField?
    
    
    func initPublicSetting()
    {
        if(runtimeSettings == nil)
        {
            runtimeSettings = RuntimeSettingsModel.runtimeSettings
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITextField.appearance().tintColor = UIColor.gray
        self.tableView!.register(UINib(nibName:"SettingTableViewCell", bundle:nil),forCellReuseIdentifier:"settingCell")
        initPublicSetting()
        self.colorImageConvert = .grayScale
        self.barcdInvertMode = .darkOnLight
        self.title = "Settings"
        NotificationCenter.default
            .addObserver(self,selector: #selector(keyboardWillShow(_:)),
                         name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default
            .addObserver(self,selector: #selector(keyboardWillHide(_:)),
                         name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        print("viewDidLoad_RuntimeSettingvc")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""
        curDataArr = deblerLeverArr
        print("viewWillAppear_RuntimeSettingvc")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear_RuntimeSettingvc")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("deinit_RuntimeSettingvc")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var rowCount = 0
        switch section
        {
        case 0:
            rowCount = 1
            break
        case 1:
            rowCount = 5
            break
        default:
            rowCount = 16
            break
        }
        return rowCount
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height:CGFloat = 0
        switch section
        {
        case 0:
            height = 0
            break
        case 1:
            height = 30
            break
        default:
            height = 16
            break
        }
        return height
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 1)
        {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 30))
            view.backgroundColor = UIColor(red: 243/255.0, green: 243/255.0, blue: 243/255.0, alpha: 1)
            let la = UILabel()
            la.text = "Barcode Format"
            la.font = UIFont(name: "", size: 15)
            la.frame = CGRect(x: 10, y: 9, width: 150, height: 13)
            la.backgroundColor = UIColor.clear
            la.textColor = UIColor(red: 123.999/255.0, green:123.999/255.0, blue:123.999/255.0, alpha:1)
            view.addSubview(la)
            return view
        }
        return nil
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
        cell.textLabel?.textColor = RuntimeSettingsTableViewController.TextColor
        cell.textLabel?.text = self.tableDataArr[indexPath.section][indexPath.row]
        if (indexPath.section == 0)
        {
            self.setupTemplateNameCell(cell: cell)
        }
        else if (indexPath.section == 1)
        {
            switch(indexPath.row)
            {
            case 0:
                cell.accessoryType = .disclosureIndicator
                break
            case 1:
                self.setupBarcodeFormatPDF417(cell:cell)
                break
            case 2:
                self.setupBarcodeFormatQRCODE(cell:cell)
                break
            case 3:
                self.setupBarcodeFormatDATAMATRIX(cell:cell)
                break
            default:
                self.setupBarcodeFormatAZTEC(cell:cell)
                break
            }
        }
        else if(indexPath.section == 2)
        {
            switch(indexPath.row)
            {
            case 0:
                self.setupExpectedBarcodeCountCell(cell:cell)
                break
            case 1:
                self.setupTimeoutCell(cell:cell)
                break
            case 2:
                self.setupDeblurLevelCell(cell:cell)
                break
            case 3:
                self.setupAntidamageLevelCell(cell:cell)
                break
            case 4:
                self.setupTextFilterModeCell(cell:cell)
                break
            case 5:
                self.setupRegionPredetectionModeCell(cell:cell)
                break
            case 6:
                self.setupScaleDownThresholdCell(cell:cell)
                break
            case 7:
                self.setupColourImageConvertModeCell(cell:cell)
                break
            case 8:
                self.setupBarcodeInvertModeCell(cell:cell)
                break
            case 9:
                self.setupGrayEqualizationSensitivityCell(cell:cell)
                break
            case 10:
                self.setupTextureDetectionSentitivityCell(cell:cell)
                break
            case 11:
                self.setupBinatizationBlockSizeCell(cell:cell)
                break
            case 12:
                self.setupLocaliztionAlgoriyhmPriorityCell(cell:cell)
                break
            case 13:
                self.setupMaxDimofFullImageAsBarcodeZoneCell(cell:cell)
                break
            case 14:
                self.setupMaxBarcodeCount(cell:cell)
                break
            default:
                self.setupEnableFillBinaryVacancy(cell:cell)
                break
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectIndexPath = indexPath
        if (indexPath.section == 0)
        {
            self.previewTextTield  = self.templateNameTextField
            self.previewTextTield?.resignFirstResponder()
        }
        else if (indexPath.section == 1)
        {
            self.previewTextTield?.resignFirstResponder()
            switch(indexPath.row)
            {
            case 0:
                self.pushONED()
                break;
            case 1:
                self.barcodeFormat_pdf417.isSelected = !self.barcodeFormat_pdf417.isSelected
                if(self.barcodeFormat_pdf417.isSelected)
                {
                    self.runtimeSettings.barcodeTypeID = self.runtimeSettings.barcodeTypeID | BarcodeType.PDF417.rawValue
                }
                else
                {
                    let temp = ~BarcodeType.PDF417.rawValue
                    self.runtimeSettings.barcodeTypeID = self.runtimeSettings.barcodeTypeID & temp
                }
                break;
            case 2:
                self.barcodeFormat_qrcode.isSelected = !self.barcodeFormat_qrcode.isSelected
                if(self.barcodeFormat_qrcode.isSelected)
                {
                    self.runtimeSettings.barcodeTypeID = self.runtimeSettings.barcodeTypeID | BarcodeType.QRCODE.rawValue
                }
                else
                {
                    let temp = ~BarcodeType.QRCODE.rawValue
                    self.runtimeSettings.barcodeTypeID = self.runtimeSettings.barcodeTypeID & temp
                }
                break;
            case 3:
                self.barcodeFormat_datamatrix.isSelected = !self.barcodeFormat_datamatrix.isSelected
                if(self.barcodeFormat_datamatrix.isSelected)
                {
                    self.runtimeSettings.barcodeTypeID = self.runtimeSettings.barcodeTypeID | BarcodeType.DATAMATRIX.rawValue
                }
                else
                {
                    let temp = ~BarcodeType.DATAMATRIX.rawValue
                    self.runtimeSettings.barcodeTypeID = self.runtimeSettings.barcodeTypeID & temp
                }
                break
            default :
                self.barcodeFormat_aztec.isSelected = !self.barcodeFormat_aztec.isSelected
                if(self.barcodeFormat_aztec.isSelected)
                {
                    self.runtimeSettings.barcodeTypeID = self.runtimeSettings.barcodeTypeID | BarcodeType.ZTEC.rawValue
                }
                else
                {
                    let temp = ~BarcodeType.ZTEC.rawValue
                    self.runtimeSettings.barcodeTypeID = self.runtimeSettings.barcodeTypeID & temp
                }
                break
            }
        }
        else if(indexPath.section == 2)
        {
            if(indexPath.row == 12)
            {
                self.pushLocalizationPriority()
            }
            else
            {
                var textFieldIsSelected = false
                switch(self.selectIndexPath?.row)
                {
                case 0:
                    self.previewTextTield  = self.expectedBrcdCountTextField
                    textFieldIsSelected = true
                    break
                case 1:
                    self.previewTextTield  = self.timeoutTextFieldCellTextField
                    textFieldIsSelected = true
                    break
                case 6:
                    self.previewTextTield = self.scaleDownThresholdCellTextField
                    textFieldIsSelected = true
                    break;
                case 11:
                    self.previewTextTield = self.binatizationBlockSizeCellTextField
                    textFieldIsSelected = true
                    break;
                case 13:
                    self.previewTextTield = self.maxDimofFullImageAsBarcodeZoneCellTextField
                    textFieldIsSelected = true
                    break;
                case 14:
                    self.previewTextTield = self.maxBarcodeCountCellTextField
                    textFieldIsSelected = true
                    break;
                default:
                    textFieldIsSelected = false
                }
                
                if(textFieldIsSelected)
                {
                   self.previewTextTield?.becomeFirstResponder()
                }
                else
                {
                    self.previewTextTield?.resignFirstResponder()
                }
                
                
                curDataArr = nil
                switch(self.selectIndexPath?.row)
                {
                case 2:
                    curDataArr = deblerLeverArr
                    break;
                case 3:
                    curDataArr = antiDamageLeverArr
                    break;
                case 7:
                    curDataArr = colorImgCnvtModeArr
                    break;
                case 8:
                    curDataArr = barcdIvrtModeArr
                    break;
                case 9:
                    curDataArr = grayEqualizationSensityArr
                    break;
                case 10:
                    curDataArr = txtureDtctionSensitivityArr
                    break;
                default:
                    curDataArr = nil
                    break;
                }
                if(curDataArr != nil)
                {
                    BRStringPickerView.showStringPicker(withTitle: tableDataArr[indexPath.section][indexPath.row], dataSource: curDataArr, defaultSelValue: curDataArr[0]) {
                        (selectValue) in
                        self.SetTextField(indexPath: indexPath,val:selectValue as! String)
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if(RuntimeSettingsModel.settingScene == SettingScene.GeneralScan)
        {
            let settingMode = RuntimeSettingsModel(setting: self.runtimeSettings)
            NSKeyedArchiver.archiveRootObject(settingMode, toFile: RuntimeSettingsModel.ArchiveURL.path)
        }
        RuntimeSettingsModel.runtimeSettings = self.runtimeSettings
        self.previewTextTield?.resignFirstResponder()
        BarcodeData.barcodeReader = BarcodeData.GetBarcodeReaderInstance()
        BarcodeData.SetRuntimeSettings()
        
        do
        {
            let names =  BarcodeData.barcodeReader.allParameterTemplateNames()
            let settings = try BarcodeData.barcodeReader.getRuntimeSettings()
            print(settings.antiDamageLevel)
            print(settings.barcodeTypeID)
            print(settings.barcodeInvert)
            print(settings.binarizationBlockSize)
            print(settings.colourImageConvert)
            print(settings.deblurLevel)
            print(settings.enableFillBinaryVacancy)
            print(settings.expectedBarcodeCount)
            print(settings.grayEqualizationSensitivity)
            print(settings.localizationAlgorithmPriority)
            print(settings.maxBarcodeCount)
            print(settings.maxDimOfFullImageAsBarcodeZone)
            print(settings.regionPredetection)
            print(settings.scaleDownThreshold)
            print(settings.textFilter)
            print(settings.textureDetectionSensitivity)
            print(settings.timeout)
            
        }
        catch{
            print(error);
        }

        print("viewWillDisappear_RuntimeSettingvc")
        super.viewWillAppear(animated)
    }
    
    func pushONED()
    {
        self.performSegue(withIdentifier: "ShowOneDTypeView", sender: self.runtimeSettings)
    }
    
    func pushLocalizationPriority()
    {
        self.performSegue(withIdentifier: "showLocAlgorithmPriorty", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "ShowOneDTypeView"{
        let controller = segue.destination as! OneDBarcodeTypeTableViewController
            controller.mainView = self
            controller.runtimeSettings = sender as! PublicSettings
        }
        else if segue.identifier == "showLocAlgorithmPriorty"{
            let controller = segue.destination as! LoclzAlgorthmPrortyTableViewController
            controller.mainView = self
        }
    }
    
    func setupTemplateNameCell(cell:UITableViewCell)
    {
        let tmpNameTextField = self.getTextField(cell: cell, rightMargin: -21)
        tmpNameTextField.tag = 21
        tmpNameTextField.text = self.runtimeSettings.name
        self.templateNameTextField = tmpNameTextField
    }
    
    func setupBarcodeFormatPDF417(cell:UITableViewCell)
    {
        let ckBox = self.getCheckBox(cell: cell, rightMargin: -31)
        ckBox.isSelected = (self.runtimeSettings!.barcodeTypeID | BarcodeType.PDF417.rawValue) == self.runtimeSettings!.barcodeTypeID
        self.barcodeFormat_pdf417 = ckBox
    }
    
    func setupBarcodeFormatQRCODE(cell:UITableViewCell)
    {
        let ckBox = self.getCheckBox(cell: cell, rightMargin: -31)
        ckBox.isSelected = (self.runtimeSettings!.barcodeTypeID | BarcodeType.QRCODE.rawValue) == self.runtimeSettings!.barcodeTypeID
        self.barcodeFormat_qrcode = ckBox
    }
    
    func setupBarcodeFormatDATAMATRIX(cell:UITableViewCell)
    {
        let ckBox = self.getCheckBox(cell: cell, rightMargin: -31)
        ckBox.isSelected = (self.runtimeSettings!.barcodeTypeID | BarcodeType.DATAMATRIX.rawValue) == self.runtimeSettings!.barcodeTypeID
        self.barcodeFormat_datamatrix = ckBox
    }
    
    func setupBarcodeFormatAZTEC(cell:UITableViewCell)
    {
        let ckBox = self.getCheckBox(cell: cell, rightMargin: -31)
        ckBox.isSelected = (self.runtimeSettings!.barcodeTypeID | BarcodeType.ZTEC.rawValue) == self.runtimeSettings!.barcodeTypeID
        self.barcodeFormat_aztec = ckBox
    }

    func setupExpectedBarcodeCountCell(cell:UITableViewCell)
    {//0
        let expBrcdCountField = self.getTextField(cell: cell, rightMargin: -31)
        expBrcdCountField.tag = 0
        expBrcdCountField.text = String(self.runtimeSettings.expectedBarcodeCount)
        expBrcdCountField.keyboardType = .numberPad
        self.expectedBrcdCountTextField = expBrcdCountField
    }
    
    func setupTimeoutCell(cell:UITableViewCell)
    {//1
        let timeoutTF = self.getTextField(cell: cell, rightMargin: -31)
        timeoutTF.tag = 1
        timeoutTF.text = String(self.runtimeSettings.timeout)
        timeoutTF.keyboardType = .numberPad
        self.timeoutTextFieldCellTextField = timeoutTF
    }
    
    func setupDeblurLevelCell(cell:UITableViewCell)
    {//2
        let tf = self.getTextField(cell: cell, rightMargin: -48)
        tf.tag = 2
        tf.text = String(self.runtimeSettings.deblurLevel)
        tf.isEnabled = false
        self.deblurLevelCellTextField = tf
        cell.contentView.addSubview(deblurLevelCellTextField)
        addSelectDownImageView(cell: cell, rightMargin: -31)
    }
    
    func setupAntidamageLevelCell(cell:UITableViewCell)
    {//3
        let tf = self.getTextField(cell: cell, rightMargin: -48)
        tf.tag = 3
        tf.text = String(self.runtimeSettings.antiDamageLevel)
        tf.isEnabled = false
        self.antidamageLevelCellTextField = tf
        cell.contentView.addSubview(antidamageLevelCellTextField)
        addSelectDownImageView(cell: cell, rightMargin: -31)
    }
    
    func setupTextFilterModeCell(cell:UITableViewCell)
    {//4
        let sw = self.getSwitch(cell: cell, rightMargin: -31)
        sw.addTarget(self, action: #selector(textFilterModeSwitchChangeVal), for: .valueChanged)
        sw.tag = 4
        sw.isOn = self.runtimeSettings.textFilter == .enable
        self.textFilterModeCellSwitch = sw
    }
    
    func setupRegionPredetectionModeCell(cell:UITableViewCell)
    {//5
        let sw = self.getSwitch(cell: cell, rightMargin: -31)
        sw.tag = 5
        sw.isOn = self.runtimeSettings.regionPredetection == .enable
        sw.addTarget(self, action: #selector(regionPredetectioneModeSwitchChangeVal), for: .valueChanged)
        self.regionPredetectionModeCellSwitch = sw
    }
    
    func setupScaleDownThresholdCell(cell:UITableViewCell)
    {//6
        let tf = self.getTextField(cell: cell, rightMargin: -31)
        tf.tag = 6
        tf.text = String(self.runtimeSettings.scaleDownThreshold)
        tf.keyboardType = .numberPad
        self.scaleDownThresholdCellTextField = tf
    }

    func setupColourImageConvertModeCell(cell:UITableViewCell)
    {//7
        let tf = self.getTextField(cell: cell, rightMargin: -48)
        tf.tag = 7
        tf.text = GetColorImgConvertModeString(mode: self.runtimeSettings.colourImageConvert)
        tf.isEnabled = false
        self.colourImageConvertModeCellTextField = tf
        addSelectDownImageView(cell: cell, rightMargin: -31)
    }

    func setupBarcodeInvertModeCell(cell:UITableViewCell)
    {//8
        let tf = self.getTextField(cell: cell, rightMargin: -48)
        tf.tag = 8
        tf.text = GetBarcodeInvertModeString(mode: self.runtimeSettings.barcodeInvert)
        tf.isEnabled = false
        self.barcodeInvertModeCellTextField = tf
        addSelectDownImageView(cell: cell, rightMargin: -31)
    }
    func setupGrayEqualizationSensitivityCell(cell:UITableViewCell)
    {//9
        let tf = self.getTextField(cell: cell, rightMargin: -48)
        tf.tag = 9
        tf.text = String(self.runtimeSettings.textureDetectionSensitivity)
        tf.isEnabled = false
        self.grayEqualizationSensitivityCellTextField = tf
        addSelectDownImageView(cell: cell, rightMargin: -31)
    }
    func setupTextureDetectionSentitivityCell(cell:UITableViewCell)
    {//10
        let tf = self.getTextField(cell: cell, rightMargin: -48)
        tf.tag = 10
        tf.text = String(self.runtimeSettings.textureDetectionSensitivity)
        tf.isEnabled = false
        self.textureDetectionSentitivityCellTextField = tf
        addSelectDownImageView(cell: cell, rightMargin: -31)
    }
    func setupBinatizationBlockSizeCell(cell:UITableViewCell)
    {//11
        let tf = self.getTextField(cell: cell, rightMargin: -31)
        tf.tag = 11
        tf.text = String(self.runtimeSettings.binarizationBlockSize)
        tf.keyboardType = .numberPad
        self.binatizationBlockSizeCellTextField = tf
    }
    func setupLocaliztionAlgoriyhmPriorityCell(cell:UITableViewCell)
    {//12
        cell.accessoryType = .disclosureIndicator
       
    }
    func setupMaxDimofFullImageAsBarcodeZoneCell(cell:UITableViewCell)
    {//13
        let tf = self.getTextField(cell: cell, rightMargin: -31)
        tf.tag = 13
        tf.text = String(self.runtimeSettings.maxDimOfFullImageAsBarcodeZone)
        tf.keyboardType = .numberPad
        self.maxDimofFullImageAsBarcodeZoneCellTextField = tf
    }
    
    func setupMaxBarcodeCount(cell:UITableViewCell)
    {//14
        let tf = self.getTextField(cell: cell, rightMargin: -31
        )
        tf.tag = 14
        tf.text = String(self.runtimeSettings.maxBarcodeCount)
        tf.keyboardType = .numberPad
        self.maxBarcodeCountCellTextField = tf
    }
    
    func setupEnableFillBinaryVacancy(cell:UITableViewCell)
    {//15
        let sw = self.getSwitch(cell: cell, rightMargin: -31)
        sw.tag = 15
        sw.isOn = self.runtimeSettings.enableFillBinaryVacancy == 1 ? true : false
        sw.addTarget(self, action: #selector(enableEillBinaryVacancySwitchChangeVal), for: .valueChanged)
        self.enableFillBinaryVacancySwitch = sw
    }
    
    func getTextField(cell:UITableViewCell, rightMargin: CGFloat) -> UITextField
    {
        let textField = UITextField()
        textField.backgroundColor = UIColor.clear
        textField.textColor = RuntimeSettingsTableViewController.TextFieldColor
        textField.font = UIFont(name: "", size: 9)
        textField.textAlignment = .right
        textField.keyboardType = .default
        textField.returnKeyType = .done
        textField.delegate = self
        cell.contentView.addSubview(textField)
        textField.snp_makeConstraints { (make) in
            make.centerY.equalTo(cell.contentView)
            make.right.equalTo(rightMargin)
            make.height.equalTo(40)
        }
        return textField
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
    
    func addSelectDownImageView(cell:UITableViewCell, rightMargin:CGFloat)
    {
        let imageview = UIImageView()
        imageview.backgroundColor = UIColor.clear
        imageview.image = UIImage(named: "select_down")
        imageview.frame.size = CGSize(width: 9, height: 5)
        cell.contentView.addSubview(imageview)
        imageview.snp_remakeConstraints { (make) in
            make.centerY.equalTo(cell.contentView)
            make.right.equalTo(rightMargin)
        }
//        imageview.isUserInteractionEnabled = true
//        let mytap = UITapGestureRecognizer(target: self, action: #selector(didTapSelectDownImageView))
//        imageview.addGestureRecognizer(mytap)
    }
    
    func getSwitch(cell:UITableViewCell, rightMargin:CGFloat) -> UISwitch
    {
        let swtch = UISwitch()
        swtch.frame.size = CGSize(width: 52, height: 32)
        cell.contentView.addSubview(swtch)
        swtch.snp_remakeConstraints { (make) in
            make.centerY.equalTo(cell.contentView)
            make.right.equalTo(rightMargin)
        }
        return swtch
    }
    
    func GetColorImgConvertModeString(mode:ColourImageConvert) -> String {
        return mode == .auto ? "Auto" : "Grayscale"
    }
    
    func GetColorImgConvertModeVal(str:String) -> ColourImageConvert {
        return str == "Auto" ? .auto : .grayScale
    }
    
    func GetBarcodeInvertModeString(mode:BarcodeInvert) -> String {
        return mode == .darkOnLight ? "DarkOnLight" : "LightOnDark"
    }
    
    func GetBarcodeInvertModeVal(str:String) -> BarcodeInvert {
        return str == "DarkOnLight" ? .darkOnLight : .lightOnDark
    }
 
    @objc func textFilterModeSwitchChangeVal()
    {
        self.runtimeSettings.textFilter = self.textFilterModeCellSwitch.isOn ? .enable : .disable
    }
    
    @objc func regionPredetectioneModeSwitchChangeVal()
    {
        self.runtimeSettings?.regionPredetection = self.regionPredetectionModeCellSwitch.isOn ? .enable : .disable
    }
    
    @objc func enableEillBinaryVacancySwitchChangeVal()
    {
        self.runtimeSettings?.enableFillBinaryVacancy = self.enableFillBinaryVacancySwitch.isOn ? 1 : 0
    }

    func SetTextField(indexPath:IndexPath,val:String)
    {
        if(indexPath.section == 2)
        {
            switch(self.selectIndexPath?.row)
            {
            case 2:
                deblurLevelCellTextField.text = val
                self.runtimeSettings.deblurLevel = Int(val)!
                break;
            case 3:
                antidamageLevelCellTextField.text = val
                self.runtimeSettings.antiDamageLevel = Int(val)!
                break;
            case 7:
                colourImageConvertModeCellTextField.text = val
                self.runtimeSettings.colourImageConvert = GetColorImgConvertModeVal(str: val)
                break;
            case 8:
                barcodeInvertModeCellTextField.text = val
                self.runtimeSettings.barcodeInvert = GetBarcodeInvertModeVal(str: val)
                break;
            case 9:
                grayEqualizationSensitivityCellTextField.text = val
                break;
            case 10:
                textureDetectionSentitivityCellTextField.text = val
                break;
            default:
                break;
            }
        }
    }
    
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if (scrollView == self.tableView) {
//            let sectionHeaderHeight:CGFloat = 36;
//            if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0)
//            {
//                scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//            }
//            else if (scrollView.contentOffset.y >= sectionHeaderHeight)
//            {
//                scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//            }
//        }
//    }
    
}

extension RuntimeSettingsTableViewController
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let currentText = textField.text ?? ""
        var currentString = (currentText as NSString).replacingCharacters(in: range, with: string)
        if(currentString == "" && textField.tag != 21)
        {
            textField.text = "0"
            currentString = "0"
        }
        switch textField.tag {
        case 21:
            self.runtimeSettings.name = currentString
            let maxLength = 20
            if(currentString.count > maxLength){
                return false
            }
            break
        case 0:
            self.runtimeSettings.expectedBarcodeCount = Int(currentString)!
            let maxLength = 7
            if(currentString.count > maxLength){
                return false
            }
            break
        case 1:
            self.runtimeSettings.timeout = Int(currentString)!
            let maxLength = 7
            if(currentString.count > maxLength){
                return false
            }
            break
        case 6:
            self.runtimeSettings.scaleDownThreshold = Int(currentString)!
            let maxLength = 7
            if(currentString.count > maxLength){
                return false
            }
            break
        case 11:
            self.runtimeSettings.binarizationBlockSize = Int(currentString)!
            let maxLength = 4
            if(currentString.count > maxLength){
                return false
            }
            break
        case 13:
            self.runtimeSettings.maxDimOfFullImageAsBarcodeZone = Int(currentString)!
            let maxLength = 6
            if(currentString.count > maxLength){
                return false
            }
            break
        case 14:
            self.runtimeSettings.binarizationBlockSize = Int(currentString)!
            let maxLength = 11
            if(currentString.count > maxLength){
                return false
            }
            break
        default:
            break
        }
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.previewTextTield = textField
        return  true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.previewTextTield?.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {

        let info = notification.userInfo!
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        let responderTextField = self.previewTextTield!
        
        var deltaH:CGFloat = 0
        let textFieldMaxY = responderTextField.convert(responderTextField.frame, to: view).maxY
        if(textFieldMaxY > self.view.frame.size.height)
        {
            deltaH = textFieldMaxY - self.view.frame.size.height
        }
        
        let distanceToKeyboard = keyboardFrame!.origin.y - responderTextField.convert(responderTextField.frame, to: view).maxY + deltaH
        if distanceToKeyboard < 0 {
            view.frame.origin.y = distanceToKeyboard
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
}

extension RuntimeSettingsTableViewController
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.curDataArr!.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.curDataArr![row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(self.selectIndexPath?.section == 2)
        {
            switch(self.selectIndexPath?.row)
            {
            case 2:
                self.deblurLevelCellTextField.text = curDataArr[row]
                self.runtimeSettings.deblurLevel = Int(curDataArr[row])!
                break
            case 3:
                self.antidamageLevelCellTextField.text = curDataArr[row]
                self.runtimeSettings.antiDamageLevel = Int(curDataArr[row])!
                break
            case 7:
                self.colourImageConvertModeCellTextField.text = curDataArr[row]
                self.colorImageConvert = (row == 0) ? .grayScale : .auto
                self.runtimeSettings.colourImageConvert = colorImageConvert
                break;
            case 8:
                self.barcodeInvertModeCellTextField.text = curDataArr[row]
                self.barcdInvertMode = (row == 0) ? .darkOnLight : .lightOnDark
                self.runtimeSettings.barcodeInvert = barcdInvertMode
                break;
            case 9:
                self.grayEqualizationSensitivityCellTextField.text  = curDataArr[row]
                self.runtimeSettings.grayEqualizationSensitivity = Int(curDataArr[row])!
                break;
            case 10:
                self.textureDetectionSentitivityCellTextField.text = curDataArr[row]
                self.runtimeSettings.textureDetectionSensitivity = Int(curDataArr[row])!
                break;
            default:
                break;
            }
        }
    }
}

extension RuntimeSettingsTableViewController{
    override func navigationShouldPopOnBackButton() -> Bool {
        if (self.runtimeSettings.barcodeTypeID != 0) {
            return true
        }
        else{
            let alertController = UIAlertController(title: nil, message: "Please select at least one code type!", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default) { (_) in
            }
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
            return false
        }
    }
}
