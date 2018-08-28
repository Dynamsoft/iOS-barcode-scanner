//
//  HistoryTableViewController.swift
//  AwesomeBarcode
//
//  Created by Dynamsoft on 2018/7/3.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {

    var localBarcode: [BarcodeData]?
    var selectedRow: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView!.register(UINib(nibName:"HistoryTableViewCell", bundle:nil),forCellReuseIdentifier:"historyCell")
        self.tableView!.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "History"
        localBarcode = NSKeyedUnarchiver.unarchiveObject(withFile: BarcodeData.ArchiveURL.path) as? [BarcodeData]
        localBarcode = localBarcode?.reversed()
        
        self.navigationController?.navigationBar.backgroundColor = Common.whiteColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.backgroundColor = Common.grayColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = localBarcode?.count else { return 0 }
        return count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 111
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryTableViewCell
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let datestr = dformatter.string(from: localBarcode![indexPath.row].decodeDate)
        
        
        var filename:String = localBarcode![indexPath.row].imagePath.absoluteString.split(separator: "/").map(String.init).last!
        filename = filename.split(separator: ".").map(String.init).first!
        cell.nameLabel.text = filename
        cell.timeLabel.text = datestr.description
        cell.previewImage.image = thumbnailImageFromPath(localBarcode![indexPath.row].imagePath)
        cell.imageView?.contentMode = .scaleAspectFit
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedRow = indexPath.row
        let secondView = QuickLookViewController()
        secondView.index = selectedRow
        self.navigationController?.pushViewController(secondView , animated: true)
        return indexPath
    }
    
    func thumbnailImageFromPath(_ path: URL) -> UIImage? {
        var image = UIImage(contentsOfFile: path.path)
//        var imageSize = CGSize(width: 60, height: 60)
//        if image!.size.width > image!.size.height {
//            imageSize.height = 60 * image!.size.height / image!.size.width
//        } else {
//            imageSize.width = 60 * image!.size.width / image!.size.height
//        }
//        DispatchQueue.global(qos: .default).async {
//            UIGraphicsBeginImageContext(imageSize)
//            let imageRect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
//            image?.draw(in: imageRect)
//            image = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//        }
        return image
    }
    
    
    
    func fileSizeOfCache()-> Int {
        let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        let fileArr = FileManager.default.subpaths(atPath: cachePath!)
        var size = 0
        for file in fileArr! {

            let path = (cachePath! as NSString).appending("/\(file)")

            let floder = try! FileManager.default.attributesOfItem(atPath: path)

            for (abc, bcd) in floder {

                if abc == FileAttributeKey.size {
                    
                    size += (bcd as AnyObject).integerValue
                }
            }
        }
        let mm = size / 1024 / 1024
        
        return mm
        
    }
    
    func clearCache() {
        let cachePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fileArr = FileManager.default.subpaths(atPath: cachePath)
        for file in fileArr! {
            if file == "runtime.settings"
            {
                continue
            }
            let path = (cachePath as NSString).appending("/\(file)")
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                }
            }
        }
    }

    func doDelete()
    {
        self.clearCache()
        localBarcode = NSKeyedUnarchiver.unarchiveObject(withFile: BarcodeData.ArchiveURL.path) as? [BarcodeData]
        self.tableView.reloadData()
    }
    
    func confirmDelete()
    {
        let alertCntrllr = UIAlertController(title: "Clear History", message: "Are you sure you want to clear the history list?", preferredStyle: .alert)
        let cancelActn = UIAlertAction(title: "CANCEL", style: .cancel)
        alertCntrllr.addAction(cancelActn)
        let alrtActn = UIAlertAction(title: "OK", style: .default){ (UIAlertAction) in
            self.doDelete()
        }
        alertCntrllr.addAction(alrtActn)
        self.present(alertCntrllr, animated: true, completion: nil)
    }

    @IBAction func clearHistory(_ sender: Any)
    {
        let alertController = UIAlertController(title: nil, message: "Clear the history list?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        let alertAction = UIAlertAction(title: "Delete", style: .destructive){ (UIAlertAction) in
            self.confirmDelete()
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
