//
//  ScheduleSearchViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/07/20.
//

import UIKit
import RealmSwift

class ScheduleSearchViewController: UIViewController {
    
    @IBOutlet var baseView: UIView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var backgroundIV: UIImageView!
    @IBOutlet weak var listTV: UITableView!
    @IBOutlet weak var noMessageSV: UIStackView!
    
    var myUD: MyUserDefaults!
    var oshiRealm: Realm!
    var oshiId: Int!
    var scheduleDetailDic: Dictionary = Dictionary<String, [ScheduleDetail]>()
    var keyArray: [String] = [String]()
    var scheduleDetail: ScheduleDetail!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTF.delegate = self
        listTV.delegate = self
        listTV.dataSource = self

        myUD = MyUserDefaults.init()
        oshiId = myUD.getOshiId()

        // 枠線
        searchTF.layer.borderColor = UIColor(red:0.76, green:0.76, blue:0.76, alpha:1.0).cgColor
        searchTF.layer.borderWidth = 1.0;
        searchTF.layer.cornerRadius = 17.5;
        
        // プレースホルダー
        searchTF.attributedPlaceholder = NSAttributedString(string: "スペースでAND検索",
                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])

        // データなしメッセージ非表示
        noMessageSV.isHidden = true
    }
    
    /**
     画面再描画
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.changeVisual()
    }
    
    func changeVisual() {
        // スケジュール検索
        searchSchedule()
        // イメージカラー設定
        baseView.backgroundColor = Const.ImageColor().getImageColor(cd: myUD.getImageColorCd())
        // ランダムに背景画像を設定
        backgroundIV.image = CommonMethod.roadBackgroundImage(oshiId: myUD.getOshiId()).randomElement()
    }

    /**
     戻るボタン押下
     */
    @IBAction func tapBackBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    /**
     データ渡し
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 編集画面にデータを渡す
        if segue.identifier == "toScheduleEdit" {
            let vc: ScheduleEditViewController = segue.destination as! ScheduleEditViewController
            vc.scheduleDetail = scheduleDetail
            vc.isNew = false
            vc.selectedDate = scheduleDetail.date
        }
    }
}

extension ScheduleSearchViewController: UITextFieldDelegate {
    /**
     キーボードEnter押下
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // スケジュール検索
        searchSchedule()

        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }

}

extension ScheduleSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        
        let delete = UIContextualAction(style: .normal,
                                            title: "削除",
                                            handler: { (action: UIContextualAction, view: UIView, success :(Bool) -> Void) in
            
            let alert = UIAlertController(title: "", message: Const.Message.DELTE_CONFIRM_MSG, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "いいえ", style: .default, handler: { (action) -> Void in
                // アラートを閉じる
                alert.dismiss(animated: true)
            })
            let ok = UIAlertAction(title: "はい", style: .default, handler: { (action) -> Void in
                let scheduleDetailArray: [ScheduleDetail] = self.scheduleDetailDic[self.keyArray[indexPath.section]]!
                let scheduleId = scheduleDetailArray[indexPath.row].scheduleId
                
                // スケジュール関連TBL削除
                ScheduleCalendarViewController().deleteSchedule(oshiRealm: self.oshiRealm, scheduleId: scheduleId)
                // スケジュール再検索
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

extension ScheduleSearchViewController {
    
    /**
     スケジュール検索
     */
    private func searchSchedule() {
        // Dic初期化
        scheduleDetailDic.removeAll()
        
        // 検索文字列を取得、空白で分割
        let textArray: [String] = CommonMethod.getSearchWord(text: searchTF.text ?? "")
        
        // oshiRealm生成
        oshiRealm = CommonMethod.createOshiRealm(oshiId: oshiId)
        // スケジュールTBL検索
        var predicates: [NSPredicate] = [NSPredicate]()
        for text in textArray {
            let predicate = NSPredicate(format: "\(Schedule.Types.title.rawValue) CONTAINS[c] %@ OR \(Schedule.Types.memo.rawValue) CONTAINS[c] %@", text.trimmingCharacters(in: .whitespaces), text.trimmingCharacters(in: .whitespaces))
            predicates.append(predicate)
        }
        let schedules = oshiRealm.objects(Schedule.self).filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
        
        // スケジュール詳細TBL取得
        predicates = [NSPredicate]()
        for schedule in schedules {
            let predicate = NSPredicate(format: "\(ScheduleDetail.Types.scheduleId.rawValue) = %@", NSNumber(value: schedule.id))
            predicates.append(predicate)
        }
        let scheduleDetails = oshiRealm.objects(ScheduleDetail.self).filter(NSCompoundPredicate(orPredicateWithSubpredicates: predicates))
            .sorted(byKeyPath: ScheduleDetail.Types.date.rawValue, ascending: false)

        // 結果を年月で分類しDicに格納
        if !scheduleDetails.isEmpty {
            var tmpYmString = ""
            var scheduleDetailArray: [ScheduleDetail] = [ScheduleDetail]()
            for scheduleDetail in scheduleDetails {
                if tmpYmString == scheduleDetail.ymString {
                    scheduleDetailArray.append(scheduleDetail)
                } else {
                    if !scheduleDetailArray.isEmpty {
                        scheduleDetailDic[tmpYmString] = scheduleDetailArray
                        scheduleDetailArray.removeAll()
                    }
                    scheduleDetailArray.append(scheduleDetail)
                }
                tmpYmString = scheduleDetail.ymString
            }
            scheduleDetailDic[tmpYmString] = scheduleDetailArray
        }
        // キー（日付）配列
        keyArray = [String](scheduleDetailDic.keys)
        // キーをソート（年月降順）
        keyArray.sort { $0 > $1 }
        // TVリロード
        listTV.reloadData()
        
        if !scheduleDetails.isEmpty {
            // 日記なしメッセージ非表示
            noMessageSV.isHidden = true
        } else {
            // 日記なしメッセージ表示
            noMessageSV.isHidden = false
        }
    }
}
