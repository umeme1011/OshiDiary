//
//  DiaryListOverViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/22.
//

import UIKit
import FSCalendar

class DiaryListOverViewController: UIViewController {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var iconIV: UIImageView!
    
    var myUD: MyUserDefaults!
    var oshiId: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myUD = MyUserDefaults.init()
        oshiId = myUD.getOshiId()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // イメージカラー設定
        baseView.backgroundColor = Const.Color().getImageColor(cd: myUD.getImageColorCd())
        
        // アイコン画像設定
        iconIV.image = CommonMethod.roadIconImage(oshiId: oshiId)
    }

    @IBAction func tapBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
