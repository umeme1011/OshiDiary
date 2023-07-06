//
//  DiaryCalendarViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/21.
//

import UIKit

class DiaryCalendarOverViewController: UIViewController {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var iconIV: UIImageView!
    
    var myUD: MyUserDefaults!
    var oshiId: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myUD = MyUserDefaults.init()
        oshiId = myUD.getOshiId()
        // 最終表示画面設定
        myUD.setLastShowScreen(screen: Const.ScreenName.DIALY_CALENDAR)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.changeVisual()
    }
    
    @IBAction func tapNewBtn(_ sender: Any) {
    }
    
    func changeVisual() {
        // イメージカラー設定
        baseView.backgroundColor = Const.Color().getImageColor(cd: myUD.getImageColorCd())
        // アイコン画像設定
        iconIV.image = CommonMethod.roadIconImage(oshiId: myUD.getOshiId())
    }
    
}
