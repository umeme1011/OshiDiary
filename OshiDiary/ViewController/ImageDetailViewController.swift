//
//  ImageDetailViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/25.
//

import UIKit

class ImageDetailViewController: UIViewController {
    
    var imageArray: [UIImage] = [UIImage]()
    var selectedNo: Int!
    
    var bkImage:UIImage!
    
    @IBOutlet weak var imageDetailCV: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageDetailCV.dataSource = self

        // レイアウト設定
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.view.frame.size.width, height: self.imageDetailCV.frame.size.height)
        layout.scrollDirection = .horizontal // 横スクロール
        layout.minimumInteritemSpacing = 0 // 間隔
        layout.minimumLineSpacing = 0 // 行間
        self.imageDetailCV.collectionViewLayout = layout
        
        // 自動スクロール時に１枚目の画像がちらつかないように白画像を一時的に設定
        self.bkImage = imageArray[0]
        let whiteImage:UIImage = UIImage(named: "white")!
        imageArray[0] = whiteImage
    }
    
    /**
     閉じるボタン押下
     */
    @IBAction func tapCloseBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // 選択した写真までスクロールして表示
        self.imageDetailCV.isPagingEnabled = false
        self.imageDetailCV.scrollToItem(at: IndexPath(item: selectedNo, section: 0), at: .centeredHorizontally, animated: false)
        self.imageDetailCV.isPagingEnabled = true
        
        // 元の画像を設定し直す
        imageArray[0] = self.bkImage
        self.imageDetailCV.reloadData()
    }
}

extension ImageDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageDetailCollectionViewCell
        
        cell.imageView.image = imageArray[indexPath.row]    // 画像
        cell.numLbl.text = String(indexPath.row + 1) + " / " + String(imageArray.count)     // 枚数
        
        return cell
    }

}
