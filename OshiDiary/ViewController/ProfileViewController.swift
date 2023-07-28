//
//  ProfileViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/07/26.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileCV: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileCV.delegate = self
        profileCV.dataSource = self
        
        // レイアウト設定
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.view.frame.size.width, height: self.profileCV.frame.size.height)
        layout.scrollDirection = .horizontal // 横スクロール
        layout.minimumInteritemSpacing = 0 // 間隔
        layout.minimumLineSpacing = 0 // 行間
        self.profileCV.collectionViewLayout = layout

    }

    
    @IBAction func tapBackBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ProfileCollectionViewCell
        
        cell.nameLbl.text = "TTTTTTT"
        
        return cell
    }
    
}

