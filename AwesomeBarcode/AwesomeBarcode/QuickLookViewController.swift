//
//  ImagePreviewVC
//  AwesomeBarcode
//
//  Created by Dynamsoft on 2018/7/3.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

import UIKit

class QuickLookViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    var index:Int!
    var collectionView:UICollectionView!
    var collectionViewLayout: UICollectionViewFlowLayout!
    var pageControl : UIPageControl!
    static var cntntViewHeight:CGFloat = 361.0
    var nvgHeight:CGFloat!
    var cntntView: UIView!
    var resultTableView:UITableView!
    var localBarcode: [BarcodeData]?
    var singleImgMode:Bool = false
    var singleImg:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(localBarcode == nil)
        {
            self.localBarcode = NSKeyedUnarchiver.unarchiveObject(withFile: BarcodeData.ArchiveURL.path) as? [BarcodeData]
            self.localBarcode = self.localBarcode?.reversed()
        }
        if(localBarcode!.count == 1 && localBarcode![0].barcodeLocations.count == 0)
        {
            localBarcode = nil
        }
        
        self.cntntView = UIView()
        let statusRect = UIApplication.shared.statusBarFrame
        let navRect = self.navigationController!.navigationBar.frame;
        nvgHeight = statusRect.height + navRect.height
        self.cntntView.frame = CGRect(x: 0, y: nvgHeight, width: UIScreen.main.bounds.width, height: QuickLookViewController.cntntViewHeight)
        self.cntntView.backgroundColor = UIColor(red: 79.0027/255.0, green: 81.0027/255.0, blue: 85.9987/255.0, alpha: 1)
        self.view.addSubview(self.cntntView!)
        self.resultTableView = UITableView()
        self.resultTableView.frame = CGRect(x: 0, y: cntntView.bounds.height + nvgHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.cntntView.bounds.height - nvgHeight)
        self.resultTableView.dataSource = self
        self.resultTableView.delegate = self
        self.resultTableView.register(UINib(nibName:"histroyDetailTableViewCell", bundle:nil),forCellReuseIdentifier:"historyResultsCell")
        self.view.addSubview(resultTableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.scrollDirection = .horizontal
        let rect = CGRect(x: 0, y: nvgHeight, width: self.view.bounds.width, height: self.view.bounds.height - nvgHeight)
        collectionView = UICollectionView(frame: rect,
                                          collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = UIColor(red: 79.0027/255.0, green: 81.0027/255.0, blue: 85.9987/255.0, alpha: 1)
        collectionView.register(ImagePreviewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.view.addSubview(collectionView)

        if(self.localBarcode != nil)
        {
            let indexPath = IndexPath(item: index, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
            
        }
        pageControl = UIPageControl()
        pageControl.center = CGPoint(x: UIScreen.main.bounds.width/2,
                                     y: self.cntntView.bounds.height - 20)
        pageControl.isUserInteractionEnabled = false
        pageControl.numberOfPages = 0
        if(self.localBarcode != nil)
        {
            pageControl.numberOfPages = (localBarcode?.count)!
        }
        pageControl.currentPage = index
        self.cntntView.addSubview(self.pageControl)
        collectionView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: QuickLookViewController.cntntViewHeight)
        collectionView.collectionViewLayout.invalidateLayout()
        

        self.navigationController?.navigationBar.backgroundColor = Common.whiteColor
        self.navigationController?.navigationBar.topItem?.title = "";
        
//        let leftBtn = UIBarButtonItem(barButtonSystemItem: "", target: self, action: .normal, action: @selector(onShare))
//        let leftBtn = UIBarButtonItem(image: <#T##UIImage?#>, style: .normal, target: self, action: @selector())

        let img = UIImage(named: "icon_Upload")
        let item3 = UIBarButtonItem(image: img, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.onShare))
        self.navigationItem.rightBarButtonItem = item3
        self.title = "Barcode Details"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.resultTableView.reloadData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.backgroundColor = Common.grayColor
        
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let indexPath2 = IndexPath(item: self.pageControl.currentPage, section: 0)
        if(self.localBarcode != nil)
        {
            collectionView.scrollToItem(at: indexPath2, at: .left, animated: false)
        }
        pageControl.center = CGPoint(x: UIScreen.main.bounds.width/2,
                                     y:QuickLookViewController.cntntViewHeight + nvgHeight  - 20)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func onShare()
    {
        let originImage = getScreenShot()
        let activityVC = UIActivityViewController(activityItems: [originImage], applicationActivities: nil)
        activityVC.completionWithItemsHandler = { (_, _, _, _) in
            self.onCancel()
        }
        present(activityVC, animated: true, completion: nil)
    }
    
    func getScreenShot() -> UIImage{
        let windown = UIApplication.shared.keyWindow
        UIGraphicsBeginImageContextWithOptions((windown?.bounds.size)!, true, UIScreen.main.scale)
        windown?.drawHierarchy(in: (windown?.bounds)!, afterScreenUpdates: false)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }

    func onCancel() {
    }
}

extension QuickLookViewController:UICollectionViewDelegate, UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                                          for: indexPath) as! ImagePreviewCell
            if(singleImgMode)
            {
                cell.imageView.image = singleImg
            }
            else
            {
                let barcode = localBarcode![indexPath.row]
                let originImage = UIImage(contentsOfFile: barcode.imagePath.path)
                if(originImage != nil)
                {
                    var barcodesLoc = barcode.barcodeLocations
                    if barcode.coordinateNeedRotate == "true"
                    {
                        for i in 0 ..< barcode.barcodeLocations.count{
                            barcodesLoc[i] = CaptureViewController.pixelPointsFromResult(barcode.barcodeLocations[i], in: originImage!.size)
                        }
                    }
                    

                    let image = BarcodeMaskView.mixImage(originImage!, with: barcodesLoc)
                    cell.imageView.image = image
                }
            }
            return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        var result = 0
        if(localBarcode != nil)
        {
            result = localBarcode!.count
        }
        
        return result
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height:QuickLookViewController.cntntViewHeight )
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let cell = cell as? ImagePreviewCell{
            cell.imageWidth = UIScreen.main.bounds.width
            cell.imageHeight = QuickLookViewController.cntntViewHeight
            cell.resetSize()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let visibleCell = collectionView.visibleCells[0]
        let idx = collectionView.indexPath(for: visibleCell)!.item
        self.pageControl.currentPage = idx
        self.index = idx
        self.resultTableView.reloadData()
    }
}

extension QuickLookViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = self.localBarcode?[index].barcodeTexts.count else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "historyResultsCell", for: indexPath)) as! histroyDetailTableViewCell
        cell.cellNum.text = String(indexPath.row + 1)
        let text = (self.localBarcode?[index].barcodeTexts[indexPath.row])!
        let format = (self.localBarcode?[index].barcodeTypes[indexPath.row])!
        cell.txtLabel.text = "Text: \(text)"
        cell.formatLabel.text = "Format: \(format)"
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.resultTableView.bounds.width, height: 30))
        view.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
        let imageView = UIImageView(frame: CGRect(x:20,y:10,width:11,height:11))
        imageView.image = UIImage(named: "icon_clock")
        view.addSubview(imageView)
        let label = UILabel(frame: CGRect(x: 60, y: 10, width: 222, height: 13))
        label.font = UIFont.systemFont(ofSize: 10)
        label.text = "Total time Spent: \(self.localBarcode?[index].decodeTime ?? "0")ms"
        view.addSubview(label)
        
        let labelQty = UILabel(frame: CGRect(x: self.resultTableView.bounds.width - 62, y: 10, width: 50, height: 13))
        labelQty.font = UIFont.systemFont(ofSize: 10)
        var count = 0
        if(self.localBarcode != nil)
        {
            count = self.localBarcode![index].barcodeLocations.count
        }
        labelQty.text = "QTY:\(String(count))"
        view.addSubview(labelQty)
        
        return view
    }
}


