//
//  ScheduleListViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/28.
//

import UIKit
import RealmSwift

class ScheduleListViewController: UIViewController {
    
    @IBOutlet weak var listTV: UITableView!
    @IBOutlet weak var backgroundIV: UIImageView!
    @IBOutlet weak var noMessageSV: UIStackView!
    
    var backgroundImageArray: [UIImage] = [UIImage]()
    var myUD: MyUserDefaults!
    var oshiId: Int!
    var oshiRealm: Realm!
    var scheduleDetailDic: Dictionary = Dictionary<String, [ScheduleDetail]>()
    var keyArray: [String] = [String]()
    var scheduleDetail: ScheduleDetail!
    var pageNumber = 1
    var pageSize = 10
    var scheduleDetails: Results<ScheduleDetail>!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTV.delegate = self
        listTV.dataSource = self
        
        myUD = MyUserDefaults.init()
        oshiId = myUD.getOshiId()

        // oshiRealm生成
        oshiId = myUD.getOshiId()
        oshiRealm = CommonMethod.createOshiRealm(oshiId: oshiId)
    }
    
    /**
     画面再描画
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.changeVisual()
    }
    
    /**
     画面表示生成
     */
    func changeVisual() {
        // diaryDic初期化
        scheduleDetailDic.removeAll()
        // ページNo初期化
        pageNumber = 1

        // 日記データ取得
        let calendar = Calendar(identifier: .gregorian)
        let tmp = calendar.dateComponents([.year, .month], from: Date())
        let firstDay = calendar.date(from: tmp)!
        scheduleDetails = oshiRealm.objects(ScheduleDetail.self)
            .filter("\(ScheduleDetail.Types.date.rawValue) >= %@", firstDay)
            .sorted(byKeyPath: ScheduleDetail.Types.date.rawValue, ascending: true)

        if !scheduleDetails.isEmpty {
            // 日記なしメッセージ非表示
            noMessageSV.isHidden = true
        } else {
            // 日記なしメッセージ表示
            noMessageSV.isHidden = false
        }
        
        // ページごとにデータ設定
        setScheduleDetailDic()

        // ランダムに背景画像を設定
        backgroundIV.image = CommonMethod.roadBackgroundImage(oshiId: myUD.getOshiId()).randomElement()
    }
    
    /**
     データ渡し
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 編集画面
        if segue.identifier == "toScheduleEdit" {
            let vc: ScheduleEditViewController = segue.destination as! ScheduleEditViewController
            vc.scheduleDetail = scheduleDetail
            vc.isNew = false
            vc.selectedDate = scheduleDetail.date
        }
    }
}

extension ScheduleListViewController: UITableViewDelegate, UITableViewDataSource {
    
    /**
     セクション数
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return keyArray.count
    }
    
    /**
     セクション内容
     */
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UIView = UIView()
        let label: UILabel = UILabel()
        
        // 表示用年月日生成
        let ymd: String = CommonMethod.dateFormatter(date: CommonMethod.dateFormatter(str: keyArray[section], formattStr: "yyyyMM")
                                                     , formattKind: Const.DateFormatt.yyyyM)
        label.text = ymd

        // Viewデザイン
        let screenWidth:CGFloat = listTV.frame.size.width
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 0.0
        view.frame = CGRect(x:0, y:0, width:screenWidth, height:25)
        view.backgroundColor = Const.ImageColor().getImageColor(cd: myUD.getImageColorCd())
        // labelデザイン
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 13)
        label.frame = CGRect(x:10, y:0, width:screenWidth-10, height:25)
        label.textColor = UIColor.darkGray
        
        view.addSubview(label)
        
        // セクションのビューに対応する番号を設定する
        view.tag = section
        
        return view
    }

    /**
     セクション高さ
     */
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    /**
     セル数
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleDetailDic[keyArray[section]]?.count ?? 0
    }

    /**
     セル内容
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:  "cell", for:indexPath as IndexPath)
            as! ListTableViewCell

        // キーをもとにScheduleDetailを取得
        let scheduleDetailArray: [ScheduleDetail] = scheduleDetailDic[keyArray[indexPath.section]]!
        
        if indexPath.row < scheduleDetailArray.count {
            let scheduleDetail: ScheduleDetail = scheduleDetailArray[indexPath.row]
            
            // スケジュールIDをもとにスケジュールTBLを取得
            let schedule: Schedule = oshiRealm.objects(Schedule.self)
                .filter("\(Schedule.Types.id.rawValue) = %@", scheduleDetail.scheduleId).first!

            // 日付
            let current = Calendar.current
            cell.dateLbl.text = String(current.component(.day, from: scheduleDetail.date))
            // 週
            cell.weekLbl.text = CommonMethod.weekFormatter(date: scheduleDetail.date)
            // アイコン
            let iconName = Const.Schedule().getIconName(iconCd: schedule.iconCd, colorCd: schedule.iconColorCd)
            cell.iconIV.image = UIImage(named: iconName)
            // タイトル
            cell.titleLbl.text = ScheduleCalendarViewController().getDispTileStr(schedule: schedule, scheduleDetail: scheduleDetail)
            // 時刻
            cell.timeLbl.text = ScheduleCalendarViewController().getDispTimeStr(schedule: schedule, scheduleDetail: scheduleDetail)
            // メモ
            cell.memoLbl.text = schedule.memo
        }
        return cell
    }

    /**
     スクロール時
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // すべて表示されたら実施しない
        if scheduleDetails.count > pageSize * pageNumber {
            let scrollPosY = scrollView.contentOffset.y //スクロール位置
            let maxOffsetY = scrollView.contentSize.height - scrollView.frame.size.height //スクロール領域の高さからスクロール画面の高さを引いた値
            let distanceToBottom = maxOffsetY - scrollPosY //スクロール領域下部までの距離

            //スクロール領域下部に近づいたら追加で記事を取得する
            if distanceToBottom < 200 {
                pageNumber += 1
                setScheduleDetailDic()
            }
        }
    }

    /**
     セルがタップされた時の処理
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // タップしたセルを取得
        if let cell: UITableViewCell = listTV.cellForRow(at: indexPath) {
            // 選択状態を解除
            cell.isSelected = false
        }
        // 編集画面へ遷移
        scheduleDetail = scheduleDetailDic[keyArray[indexPath.section]]![indexPath.row]
        performSegue(withIdentifier: "toScheduleEdit", sender: nil)
    }

    /**
     右から左へスワイプ
     */
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let scheduleDetailArray: [ScheduleDetail] = self.scheduleDetailDic[self.keyArray[indexPath.section]]!
        let scheduleId = scheduleDetailArray[indexPath.row].scheduleId
        let schedule: Schedule = oshiRealm.objects(Schedule.self)
            .filter("\(Schedule.Types.id.rawValue) = %@", scheduleId).first!
        let repeatCd = schedule.repeatCd

        // 繰り返しあり
        if repeatCd != Const.Schedule.repeatCd.NO_REPEAT {
            let delete = UIContextualAction(style: .normal,
                                            title: "削除",
                                            handler: { (action: UIContextualAction, view: UIView, success :(Bool) -> Void) in

                let alert = UIAlertController(title: "", message: Const.Message.DELTE_CONFIRM_MSG, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "いいえ", style: .default, handler: { (action) -> Void in
                    // アラートを閉じる
                    alert.dismiss(animated: true)
                })
                let ok_one = UIAlertAction(title: "この予定のみ", style: .default, handler: { (action) -> Void in
                    
                    // スケジュール関連TBL削除
                    ScheduleCalendarViewController().deleteSchedule(oshiRealm: self.oshiRealm, scheduleId: scheduleId, isAll: false)
                    // データ再取得、再表示
                    self.changeVisual()
                })
                let ok_all = UIAlertAction(title: "すべての予定", style: .default, handler: { (action) -> Void in
                    
                    // スケジュール関連TBL削除
                    ScheduleCalendarViewController().deleteSchedule(oshiRealm: self.oshiRealm, scheduleId: scheduleId, isAll: true)
                    // データ再取得、再表示
                    self.changeVisual()
                })
                alert.addAction(cancel)
                alert.addAction(ok_one)
                alert.addAction(ok_all)
                self.present(alert, animated: true, completion: nil)
                success(true)
            })
            delete.backgroundColor = UIColor.systemRed
            return UISwipeActionsConfiguration(actions: [delete])
            
        // 繰り返しなし
        } else {
            let delete = UIContextualAction(style: .normal,
                                            title: "削除",
                                            handler: { (action: UIContextualAction, view: UIView, success :(Bool) -> Void) in
                
                let alert = UIAlertController(title: "", message: Const.Message.DELTE_CONFIRM_MSG, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "いいえ", style: .default, handler: { (action) -> Void in
                    // アラートを閉じる
                    alert.dismiss(animated: true)
                })
                let ok = UIAlertAction(title: "はい", style: .default, handler: { (action) -> Void in
                    
                    // スケジュール関連TBL削除
                    ScheduleCalendarViewController().deleteSchedule(oshiRealm: self.oshiRealm, scheduleId: scheduleId, isAll: false)
                    // データ再取得、再表示
                    self.changeVisual()
                })
                alert.addAction(cancel)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                success(true)
            })
            delete.backgroundColor = UIColor.systemRed
            return UISwipeActionsConfiguration(actions: [delete])
        }
    }
}

extension ScheduleListViewController {
    
    /**
     ページごとにデータ設定
     */
    private func setScheduleDetailDic() {
        
        // 次ページのデータを取得
        var scheduleDetailOffsetArray: [ScheduleDetail] = [ScheduleDetail]()
        for offset in (pageSize * (pageNumber - 1))..<(pageSize * pageNumber) {
            if offset < scheduleDetails.count {
                scheduleDetailOffsetArray.append(scheduleDetails[offset])
            }
        }
    
        // 年月ごとに分類しDictionaryに追加
        var tmpMonth = ""
        var scheduleDetailArray: [ScheduleDetail] = [ScheduleDetail]()
        for scheduleDetail in scheduleDetailOffsetArray {
            if tmpMonth == scheduleDetail.ymString {
                scheduleDetailArray.append(scheduleDetail)
            } else {
                if !scheduleDetailArray.isEmpty {
                    if scheduleDetailDic[tmpMonth] != nil {
                        scheduleDetailDic[tmpMonth]! += scheduleDetailArray
                    } else {
                        scheduleDetailDic[tmpMonth] = scheduleDetailArray
                    }
                    scheduleDetailArray.removeAll()
                }
                scheduleDetailArray.append(scheduleDetail)
            }
            tmpMonth = scheduleDetail.ymString
        }
        if tmpMonth != "" {
            if scheduleDetailDic[tmpMonth] != nil {
                scheduleDetailDic[tmpMonth]! += scheduleDetailArray
            } else {
                scheduleDetailDic[tmpMonth] = scheduleDetailArray
            }
        }

        // キー（日付）配列
        keyArray = [String](scheduleDetailDic.keys)
        // キーをソート（年月昇順）
        keyArray.sort { $0 < $1 }
        
        // listTVリロード
        listTV.reloadData()
    }
}
