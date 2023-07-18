//
//  ScheduleCalendarOverViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/27.
//

import UIKit

class ScheduleCalendarOverViewControlle: UIViewController {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var iconIV: UIImageView!
    
    var myUD: MyUserDefaults!
    var oshiId: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myUD = MyUserDefaults.init()
        oshiId = myUD.getOshiId()
        // 最終表示画面設定
        myUD.setLastShowScreen(screen: Const.ScreenName.SCHEDULE_CALENDAR)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeVisual()
    }

    func changeVisual() {
        // イメージカラー設定
        baseView.backgroundColor = Const.ImageColor().getImageColor(cd: myUD.getImageColorCd())
        // アイコン画像設定
        iconIV.image = CommonMethod.roadIconImage(oshiId: myUD.getOshiId())
    }
    
    /**
     データ渡し
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 編集画面にデータを渡す（新規）
        if segue.identifier == "toScheduleEditNew" {
            let vc: ScheduleCalendarViewController = self.children[0] as! ScheduleCalendarViewController
            let selectedDate = vc.selectedDate
            let vc2: ScheduleEditViewController = segue.destination as! ScheduleEditViewController
            vc2.isNew = true
            vc2.selectedDate = selectedDate ?? Date()
        }
    }

}

