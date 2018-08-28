//
//  LoclzAlgorthmPrortyTableViewController.swift
//  AwesomeBarcode
//
//  Created by Dynamsoft on 09/08/2018.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

import UIKit

class LoclzAlgorthmPrortyTableViewController: UITableViewController {
    
    var mainView: RuntimeSettingsTableViewController!
    let wholeStringArr = ["ConnectedBlock", "Lines", "Statistics", "FullImageAsBarcodeZone"]
    var tableDataArr = [LoclzAlgorthmPrortyStruct]()
    var curDataArr = [String]()
    var runtimeSettings:PublicSettings!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(mainView.runtimeSettings.localizationAlgorithmPriority != "")
        {
            self.curDataArr = mainView.runtimeSettings.localizationAlgorithmPriority.split(separator: ",").map(String.init)
        }
        self.tableDataArr = GetDataArr(curDataArr: self.curDataArr, wholeStringArr: self.wholeStringArr)
        
        self.navigationController?.navigationBar.topItem?.title = ""
        self.tableView!.setEditing(true, animated: false)
        self.tableView!.allowsMultipleSelectionDuringEditing = true
        self.tableView!.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
//        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()

        for i in 0...tableDataArr.count-1 {
            if tableDataArr[i].isChecked
            {
                let t = IndexPath(row: i, section: 0)
                self.tableView.selectRow(at: t, animated: false, scrollPosition: .bottom)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        var cell = tableView.dequeueReusableCell(withIdentifier: "prorityCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "prorityCell")
        }
        cell!.textLabel?.text = self.tableDataArr[indexPath.row].name
        cell!.tintColor = UIColor.lightGray
        cell!.isSelected = self.tableDataArr[indexPath.row].isChecked
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableDataArr[indexPath.row].isChecked = true
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.tableDataArr[indexPath.row].isChecked = false
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.init(rawValue: UITableViewCellEditingStyle.insert.rawValue | UITableViewCellEditingStyle.delete.rawValue)!;
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        let temp = self.tableDataArr[sourceIndexPath.row]
        self.tableDataArr.remove(at: sourceIndexPath.row)
        self.tableDataArr.insert(temp, at: destinationIndexPath.row)
    }
    
    func GetDataArr(curDataArr:[String], wholeStringArr:[String]) -> [LoclzAlgorthmPrortyStruct]
    {
        var resultArr = [LoclzAlgorthmPrortyStruct]()
        for item in curDataArr {
            let element = LoclzAlgorthmPrortyStruct()
            element.name = item
            element.isChecked = true
            resultArr.append(element)
        }
        for item in wholeStringArr{
            var isContained = false
            for jItem in resultArr{
                if(item == jItem.name)
                {
                    isContained = true
                    break
                }
            }
            if(!isContained)
            {
                let element = LoclzAlgorthmPrortyStruct()
                element.name = item
                element.isChecked = false
                resultArr.append(element)
            }
        }
        return resultArr
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        var resultArr = [String]()
        
        for item in self.tableDataArr
        {
            if(item.isChecked)
            {
                let str = String(item.name)
                resultArr.append(str)
            }
        }
        if(resultArr.count>0)
        {
            mainView.runtimeSettings.localizationAlgorithmPriority = LoclzAlgorthmPrortyStruct.GetStringFromArray(array: resultArr)
        }
        else
        {
            mainView.runtimeSettings.localizationAlgorithmPriority = ""
        }
    }
}

class LoclzAlgorthmPrortyStruct: NSObject {
    var name:String!
    var isChecked:Bool!
    
    override init() {
        name = ""
        isChecked = false
    }
    
    init(n:String,isCheck:Bool) {
        name = n
        isChecked = isCheck
    }
    
    static func GetStringFromArray(array:[String]) -> String {
        var result = ""
        for i in 0...array.count - 1
        {
            if(i < array.count - 1)
            {
                result += array[i] + ","
            }
            else
            {
                result += array[i]
            }
        }
        return result
    }
}
