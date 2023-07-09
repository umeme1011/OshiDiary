//
//  DiarySearchViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/07/09.
//

import UIKit

class DiarySearchViewController: UIViewController {
    
    @IBOutlet var baseView: UIView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var backgroundIV: UIImageView!
    
    var myUD: MyUserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myUD = MyUserDefaults.init()

        self.changeVisual()
        
        // 枠線
        searchTF.layer.borderColor = UIColor(red:0.76, green:0.76, blue:0.76, alpha:1.0).cgColor
        searchTF.layer.borderWidth = 1.0;
        searchTF.layer.cornerRadius = 20.0;
        
        // プレースホルダー
        searchTF.attributedPlaceholder = NSAttributedString(string: "スペースでAND検索",
                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])

    }
    
    @IBAction func tapBackBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func changeVisual() {
        // イメージカラー設定
        baseView.backgroundColor = Const.Color().getImageColor(cd: myUD.getImageColorCd())
        // ランダムに背景画像を設定
        backgroundIV.image = CommonMethod.roadBackgroundImage(oshiId: myUD.getOshiId()).randomElement()
    }
}
