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
    
    /**
     データ渡し
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 編集画面にデータを渡す（新規）
        if segue.identifier == "toDiaryEditNew" {
            let vc: DiaryCalendarViewController = self.children[0] as! DiaryCalendarViewController
            let selectedDate = vc.selectedDate
            let vc2: DiaryEditViewController = segue.destination as! DiaryEditViewController
            vc2.isNew = true
            vc2.selectedDate = selectedDate ?? Date()
        }
    }

    @IBAction func tapNewBtn(_ sender: Any) {
    }
    
    /**
     今日ボタン押下
     */
    @IBAction func tapTodayBtn(_ sender: Any) {
        let today = Date()
        let vc: DiaryCalendarViewController = self.children[0] as! DiaryCalendarViewController
        vc.calendar.select(today, scrollToDate: true)
        vc.selectedDate = today
        
        // 今日のデータまでスクロール
        let ymdStr = CommonMethod.dateFormatter(date: today, formattKind: Const.DateFormatt.yyyyMMdd)
        if let index = vc.keyArray.firstIndex(of: ymdStr) {
            let indexPath = IndexPath(row: 0, section: index)
            vc.listTV.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    func changeVisual() {
        // イメージカラー設定
        baseView.backgroundColor = Const.ImageColor().getImageColor(cd: myUD.getImageColorCd())
        // アイコン画像設定
        iconIV.image = CommonMethod.roadIconImage(oshiId: myUD.getOshiId())
    }
    
}
