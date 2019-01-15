//
//  MDPickPhotoViewController.swift
//  MooDumDum
//
//  Created by Haehyeon Jeong on 2018. 4. 22..
//  Copyright © 2018년 MooDumdum. All rights reserved.
//

import UIKit


class MDPickPhotoViewController: UIViewController {
    var textview : String = ""
    var category : Int = 0
    var photoData : MDPickPhotoSet!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    var isMoreLoading = false
    var pickPhotoIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        content.text = textview
        initNavigationBar()
        registerCell()
        firstLoadImage()
        
    }
    
    
    func initNavigationBar(){
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        UIApplication.shared.statusBarStyle = .default
        
        navigationController?.navigationBar.tintColor = UIColor.black;
        let rightBarButtonItem = UIBarButtonItem(title:"묻기", style:.plain, target:self, action:#selector(writeSubmit))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        
    }
    
    func registerCell(){
        self.photoCollectionView?.register(UINib(nibName: "MDPickPhotoCell", bundle: nil), forCellWithReuseIdentifier: "MDPickPhotoCell")
    }
    
    @objc func writeSubmit(){
        let param : [String : Any] = [
            "category_id" : self.category,
            "description" : textview,
            "image_url" : self.photoData.pickPhotoList[pickPhotoIndex].image_url.absoluteString,
            "color" : self.photoData.pickPhotoList[pickPhotoIndex].font_color
        ]
        
        MDAPIManager.sharedManager.writeSubmit(parameters: param) { (result) -> (Void) in
            
//            self.navigationController!.popToRootViewController(animated: true)
            self.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MDWriteSubmit"), object: nil)
            })
            
            

        }
    }
    
    func firstLoadImage(){
        MDAPIManager.sharedManager.requestWriteBackgroundImageList { (result) -> (Void) in
            self.photoData = MDPickPhotoSet(rawJson: result)
            self.navigationController?.navigationBar.tintColor = UIColor(hexString: self.photoData.pickPhotoList[0].font_color)
            self.content.textColor = UIColor(hexString: self.photoData.pickPhotoList[0].font_color)
            self.backgroundImageView.kf.setImage(with: self.photoData.pickPhotoList[0].image_url)
            self.photoCollectionView.reloadData()
        }
    }
    
    func loadMore(){
        guard photoData != nil else { return }
        guard photoData.nextUrl != nil else { return }
        guard photoData.nextUrl != "" else { return }
        
        MDAPIManager.sharedManager.requestMoreWriteBackgroundImageList(url: photoData.nextUrl!, completion: { (result) -> (Void) in
            self.photoData.loadMore(rawJson: result)
            self.photoCollectionView.reloadData()
            self.isMoreLoading = false
        })
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if isMoreLoading == false {
            let scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y
            if scrollPosition > 0 && scrollPosition < scrollView.contentSize.height*0.2{
                loadMore()
                self.isMoreLoading = true
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}



extension MDPickPhotoViewController : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.pickPhotoIndex = indexPath.row
        navigationController?.navigationBar.tintColor = UIColor(hexString: self.photoData.pickPhotoList[indexPath.row].font_color)
        self.content.textColor = UIColor(hexString: self.photoData.pickPhotoList[indexPath.row].font_color)
        self.backgroundImageView.kf.setImage(with: self.photoData.pickPhotoList[indexPath.row].image_url)
    }
}


extension MDPickPhotoViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard self.photoData != nil else { return 0 }
        return self.photoData.count!
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell  = photoCollectionView?.dequeueReusableCell(withReuseIdentifier: "MDPickPhotoCell", for: indexPath)
        if let myCell = cell as? MDPickPhotoCell {
            myCell.backgroundImageView.kf.setImage(with: self.photoData.pickPhotoList[indexPath.row].image_url)
        }
        return cell!
    }
}


extension MDPickPhotoViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - (2*5) ) / 4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}

