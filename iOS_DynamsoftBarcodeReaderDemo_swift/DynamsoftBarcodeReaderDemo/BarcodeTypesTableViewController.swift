//
//  BarcodeTypesTableViewController.swift
//  DynamsoftBarcodeReaderDemo
//
//  Created by Dynamsoft on 08/07/2018.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

import UIKit

class BarcodeTypesTableViewController: UITableViewController {
    
    var mainView: ScanViewController!
    @IBOutlet var barcodeTypesTableView: UITableView!
    @IBOutlet weak var linearCell: UITableViewCell!
    @IBOutlet weak var qrcodeCell: UITableViewCell!
    @IBOutlet weak var pdf417Cell: UITableViewCell!
    @IBOutlet weak var datamatrixCell: UITableViewCell!
    
    @IBOutlet weak var aztecCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barcodeTypesTableView.setEditing(true, animated: false);
        self.configCellsBackground();
        self.selectCells();
        barcodeTypesTableView.tableFooterView = UIView.init(frame: CGRect.zero);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        if(mainView != nil && mainView!.dbrManager != nil)
        {
            mainView.dbrManager?.isPauseFramesComing = true;
        }
    }
    
    func configCellsBackground(){
        let bgColorView = UIView.init();
        bgColorView.backgroundColor = UIColor.white;
        linearCell.selectedBackgroundView = bgColorView;
        qrcodeCell.selectedBackgroundView = bgColorView;
        pdf417Cell.selectedBackgroundView = bgColorView;
        datamatrixCell.selectedBackgroundView = bgColorView;
        aztecCell.selectedBackgroundView = bgColorView;
    }
    
    func selectCells(){
        let types = (mainView == nil || mainView.dbrManager == nil) ? BarcodeType.ALL.rawValue: mainView.dbrManager?.barcodeFormat;
        if((types! | BarcodeType.ONED.rawValue) == types)
        {
            let indexPath = IndexPath(row: 0, section: 0);
            barcodeTypesTableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.bottom);
        }
        if((types! | BarcodeType.QRCODE.rawValue) == types)
        {
            let indexPath = IndexPath(row: 1, section: 0);
            barcodeTypesTableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.bottom);
        }
        if((types! | BarcodeType.PDF417.rawValue) == types)
        {
            let indexPath = IndexPath(row: 2, section: 0);
            barcodeTypesTableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.bottom);
        }
        if((types! | BarcodeType.DATAMATRIX.rawValue) == types)
        {
            let indexPath = IndexPath(row: 3, section: 0);
            barcodeTypesTableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.bottom);
        }
        if((types! | BarcodeType.AZTEC.rawValue) == types)
        {
            let indexPath = IndexPath(row: 4, section: 0);
            barcodeTypesTableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.bottom);
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //where indexPath.row is the selected cell
        let hasCellSelected = linearCell.isSelected || qrcodeCell.isSelected || pdf417Cell.isSelected || datamatrixCell.isSelected ||
            aztecCell.isSelected;
        if(hasCellSelected == false)
        {
            barcodeTypesTableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.bottom);
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.init(rawValue: UITableViewCellEditingStyle.insert.rawValue | UITableViewCellEditingStyle.delete.rawValue)!;
    }

    override func viewWillDisappear(_ animated: Bool) {
        var types = 0;
        if(linearCell.isSelected)
        {
            types = types | BarcodeType.ONED.rawValue;
        }
        if(qrcodeCell.isSelected)
        {
            types = types | BarcodeType.QRCODE.rawValue;
        }
        if(pdf417Cell.isSelected)
        {
            types = types | BarcodeType.PDF417.rawValue;
        }
        if(datamatrixCell.isSelected)
        {
            types = types | BarcodeType.DATAMATRIX.rawValue;
        }
        if(aztecCell.isSelected)
        {
            types = types | BarcodeType.AZTEC.rawValue;
        }
        if(mainView != nil && mainView!.dbrManager != nil)
        {
            mainView.dbrManager?.setBarcodeFormat(format: types);
        }
        super.viewWillDisappear(animated);
    }
    
}
