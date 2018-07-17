//
//  ViewController.swift
//  AwesomeBarcode
//
//  Created by Dynamsoft on 2018/5/29.
//  Copyright © 2018年 Dynamsoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var scenesCollection: UICollectionView!
    
    @IBOutlet weak var album: UIButton!
    var imagePicker:UIImagePickerController!
    var startRecognitionDate:NSDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        scenesCollection.dataSource = self
        scenesCollection.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Segue from \(segue.source) to \(segue.destination)")
    }
    
    @IBAction func ClickAlbum(_ sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        do
        {
            imagePicker.dismiss(animated: true, completion: nil)
            let img:UIImage = info[UIImagePickerControllerEditedImage]as! UIImage
            startRecognitionDate = NSDate()
            let results = try barcodeReader.decode(img, withTemplate: "")
            self.onReadImageComplete(readResults: results);
        }
        catch{
            print(error);
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func GetResultText(id:Int, textResult:TextResult) -> String {
        var left:CGFloat = CGFloat(Float.greatestFiniteMagnitude)
        var top:CGFloat = CGFloat(Float.greatestFiniteMagnitude)
        var right:CGFloat = 0;
        var bottom:CGFloat = 0;
        for element in (textResult.localizationResult?.resultPoints!)! {
            let resultPoint =  element as! CGPoint;
            left = left < resultPoint.x ? left : resultPoint.x;
            top = top < resultPoint.y ? top : resultPoint.y;
            right = right > resultPoint.x ? right : resultPoint.x;
            bottom = bottom > resultPoint.y ? bottom : resultPoint.y
        }
        return String(format:"\nresult%d:\n\nType: %@\n\nValue: %@\n\nRegion: {Left: %.f, Top: %.f, Right: %.f, Bottom: %.f}\n\n", id + 1, textResult.barcodeFormat.description, textResult.barcodeText != nil ? textResult.barcodeText! : "null", left, top, right, bottom)
    }
    
    func onReadImageComplete(readResults:[TextResult])
    {
        let timeInterval = (startRecognitionDate?.timeIntervalSinceNow)! * -1;
        var msgText = "";
        if(readResults.count == 0)
        {
            msgText = "\nno barcode found\n\n";
        }
        else
        {
            for i in  0...(readResults.count-1)
            {
                let barcode = readResults[i]
                msgText = msgText + GetResultText(id:i,textResult: barcode);
            }
        }
        msgText = msgText + String(format: "Interval: %.03f seconds\n\n", timeInterval)
        let ac = UIAlertController(title: "Result", message: msgText, preferredStyle: .alert)
        self.customizeAC(ac:ac);
        let okButton = UIAlertAction(title: "OK", style: .default, handler: {
            action in
        })
        ac.addAction(okButton)
        self.present(ac, animated: true, completion: nil)
    }
    
    func customizeAC(ac: UIAlertController){
        let subView1 = ac.view.subviews[0] as UIView;
        let subView2 = subView1.subviews[0] as UIView;
        let subView3 = subView2.subviews[0] as UIView;
        let subView4 = subView3.subviews[0] as UIView;
        let subView5 = subView4.subviews[0] as UIView;
        let titleLab = subView5.subviews[0] as! UILabel;
        let messageLab = subView5.subviews[1] as! UILabel;
        titleLab.textAlignment = NSTextAlignment.left;
        messageLab.textAlignment = NSTextAlignment.left;
    }
    
}


// MARK: UICollectionViewDataSource
extension ViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reusableCell", for: indexPath) as? MyCollectionViewCell
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Select item at \(indexPath.row)")
    }
    
}
