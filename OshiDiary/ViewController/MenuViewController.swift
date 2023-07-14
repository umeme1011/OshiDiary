//
//  MenuViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/26.
//

import UIKit
import RealmSwift

class MenuViewController: UIViewController {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    var myUD: MyUserDefaults!
    var oshiId: Int!
    var commonRealm: Realm!

    override func viewDidLoad() {
        super.viewDidLoad()

        myUD = MyUserDefaults.init()
        oshiId = myUD.getOshiId()
        commonRealm = CommonMethod.createCommonRealm()

        self.changeVisual()
    }
    
    /**
     画面再表示時
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.changeVisual()
    }
    
    @IBAction func swipeLeft(_ sender: Any) {
        
        // 前画面のデザイン反映
        switch myUD.getLastShowScreen() {
        case Const.ScreenName.SCHEDULE_CALENDAR:
            let vc: ScheduleCalendarOverViewControlle = self.presentingViewController as! ScheduleCalendarOverViewControlle
            vc.changeVisual()
            let vc2: ScheduleCalendarViewController = vc.children[0] as! ScheduleCalendarViewController
            vc2.changeVisual()
            vc2.listTV.reloadData()
        case Const.ScreenName.SCHEDULE_LIST:
            let vc: ScheduleListOverViewController = self.presentingViewController as! ScheduleListOverViewController
            vc.changeVisual()
            let vc2: ScheduleListViewController = vc.children[0] as! ScheduleListViewController
            vc2.changeVisual()
            vc2.listTV.reloadData()
        case Const.ScreenName.DIALY_CALENDAR:
            let vc: DiaryCalendarOverViewController = self.presentingViewController as! DiaryCalendarOverViewController
            vc.changeVisual()
            let vc2: DiaryCalendarViewController = vc.children[0] as! DiaryCalendarViewController
            vc2.changeVisual()
            vc2.listTV.reloadData()
        case Const.ScreenName.DIALY_LIST:
            let vc: DiaryListOverViewController = self.presentingViewController as! DiaryListOverViewController
            vc.changeVisual()
            let vc2: DiaryListViewController = vc.children[0] as! DiaryListViewController
            vc2.changeVisual()
            vc2.listTV.reloadData()
        default:
            let vc: ScheduleCalendarOverViewControlle = self.presentingViewController as! ScheduleCalendarOverViewControlle
            vc.changeVisual()
            let vc2: ScheduleCalendarViewController = vc.children[0] as! ScheduleCalendarViewController
            vc2.changeVisual()
            vc2.listTV.reloadData()
        }
        
        self.dismiss(animated: true)
    }
    
    func changeVisual() {
        
        if let oshiSetting: OshiSetting = commonRealm.objects(OshiSetting.self)
            .filter("\(OshiSetting.Types.id.rawValue) = %@", myUD.getOshiId()).first {
            // 名前設定
            nameLbl.text = oshiSetting.name
            // イメージカラー設定
            baseView.backgroundColor = Const.ImageColor().getImageColor(cd: myUD.getImageColorCd())
            // アイコン画像設定
            iconIV.image = CommonMethod.roadIconImage(oshiId: myUD.getOshiId())
        }
    }
}
