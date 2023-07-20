//
//  ScheduleCalendarViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/26.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic
import RealmSwift

class ScheduleCalendarViewController: UIViewController {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var listTV: UITableView!
    @IBOutlet weak var backgroundIV: UIImageView!
    @IBOutlet weak var headerTF: CustomTextField!
    @IBOutlet weak var noMessageSV: UIStackView!
    
    var backgroundImageArray: [UIImage] = [UIImage]()
    var myUD: MyUserDefaults!
    var oshiId: Int!
    var oshiRealm: Realm!
    var schedules: Results<Schedule>!
    var scheduleDetails: Results<ScheduleDetail>!
    var schedule: Schedule!
    var scheduleDetailDic: Dictionary = Dictionary<String, [ScheduleDetail]>()
    var keyArray: [String] = [String]()
    var selectedDate: Date!
    var currentPage: Date!
    var scheduleDetail: ScheduleDetail!
    var yearMonthPV: UIPickerView = UIPickerView()

    // pickerView用
    var yearArray: [String] = [String]()
    var monthArray: [String] = [String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.delegate = self
        calendar.dataSource = self
        listTV.delegate = self
        listTV.dataSource = self
        yearMonthPV.delegate = self
        yearMonthPV.dataSource = self

        myUD = MyUserDefaults.init()
        oshiId = myUD.getOshiId()

        // ****** カレンダーデザイン
        // 月のフォント
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 16)

        // calendarの曜日部分
        calendar.calendarWeekdayView.weekdayLabels[0].text = "日"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "月"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "火"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "水"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "木"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "金"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "土"
        calendar.calendarWeekdayView.weekdayLabels[0].font = UIFont.boldSystemFont(ofSize: 16)
        calendar.calendarWeekdayView.weekdayLabels[1].font = UIFont.boldSystemFont(ofSize: 16)
        calendar.calendarWeekdayView.weekdayLabels[2].font = UIFont.boldSystemFont(ofSize: 16)
        calendar.calendarWeekdayView.weekdayLabels[3].font = UIFont.boldSystemFont(ofSize: 16)
        calendar.calendarWeekdayView.weekdayLabels[4].font = UIFont.boldSystemFont(ofSize: 16)
        calendar.calendarWeekdayView.weekdayLabels[5].font = UIFont.boldSystemFont(ofSize: 16)
        calendar.calendarWeekdayView.weekdayLabels[6].font = UIFont.boldSystemFont(ofSize: 16)
        calendar.calendarWeekdayView.weekdayLabels[0].textColor = .systemRed
        calendar.calendarWeekdayView.weekdayLabels[1].textColor = .darkGray
        calendar.calendarWeekdayView.weekdayLabels[2].textColor = .darkGray
        calendar.calendarWeekdayView.weekdayLabels[3].textColor = .darkGray
        calendar.calendarWeekdayView.weekdayLabels[4].textColor = .darkGray
        calendar.calendarWeekdayView.weekdayLabels[5].textColor = .darkGray
        calendar.calendarWeekdayView.weekdayLabels[6].textColor = .systemBlue
     
        // カレンダー表示月を格納
        currentPage = calendar.currentPage

        // PickerView用配列作成
        yearArray = Const.Array().getYearArray()
        monthArray = Const.Array.MONTH_ARRAY

        // PickerView初期値
        let yearStr = CommonMethod.dateFormatter(date: calendar.selectedDate ?? Date(), formattKind: Const.DateFormatt.yyyy)
        let monthStr = CommonMethod.dateFormatter(date: calendar.selectedDate ?? Date(), formattKind: Const.DateFormatt.M)
        yearMonthPV.selectRow(yearArray.firstIndex(of: yearStr)!, inComponent: 0, animated: true)
        yearMonthPV.selectRow(monthArray.firstIndex(of: monthStr)!, inComponent: 1, animated: true)

        // カレンダーヘッダに重ねたTextFieldの枠線を消す
        headerTF.borderStyle = .none

        //***********************
        // yearMonthPV toolbar
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        let cancelItem = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(tapCancelBtn))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(title: "決定", style: .plain, target: self, action: #selector(tapDoneBtn))
        toolbar.setItems([cancelItem, spacelItem, doneItem], animated: true)
        headerTF.inputView = yearMonthPV
        headerTF.inputAccessoryView = toolbar

    }
    
    /**
     画面再描画
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.changeVisual()
    }
    
    func changeVisual() {
        // scheduleDetailDic初期化
        scheduleDetailDic.removeAll()
        
        // oshiRealm生成
        oshiId = myUD.getOshiId()
        oshiRealm = CommonMethod.createOshiRealm(oshiId: oshiId)
        
        // 表示月の年月を取得
        let ymString: String = CommonMethod.dateFormatter(date: currentPage, formattKind: Const.DateFormatt.yyyyMM)

        // スケジュールデータ取得
        scheduleDetails = oshiRealm.objects(ScheduleDetail.self)
            .filter("\(ScheduleDetail.Types.ymString.rawValue) = %@", ymString)
            .sorted(byKeyPath: ScheduleDetail.Types.date.rawValue, ascending: true)
        
        // 日付ごとに分類しDictionaryに格納
        if !scheduleDetails.isEmpty {
            var tmpYmdString = ""
            var scheduleDetailArray: [ScheduleDetail] = [ScheduleDetail]()
            for scheduleDetail in scheduleDetails {
                if tmpYmdString == scheduleDetail.ymdString {
                    scheduleDetailArray.append(scheduleDetail)
                } else {
                    if !scheduleDetailArray.isEmpty {
                        scheduleDetailDic[tmpYmdString] = scheduleDetailArray
                        scheduleDetailArray.removeAll()
                    }
                    scheduleDetailArray.append(scheduleDetail)
                }
                tmpYmdString = scheduleDetail.ymdString
            }
            scheduleDetailDic[tmpYmdString] = scheduleDetailArray
        }
        // キー（日付）配列
        keyArray = [String](scheduleDetailDic.keys)
        // キーをソート
        keyArray.sort()

        // listTVリロード（アニメーションつき）
        UIView.transition(with: listTV, duration: 0.1, options: [.transitionCrossDissolve, .curveLinear], animations: {self.listTV.reloadData()})
        // カレンダーリロード
        calendar.reloadData()

        // ランダムに背景画像を設定
        backgroundIV.image = CommonMethod.roadBackgroundImage(oshiId: myUD.getOshiId()).randomElement()

        if !scheduleDetails.isEmpty {
            // スケジュールなしメッセージ非表示
            noMessageSV.isHidden = true
        } else {
            // スケジュールなしメッセージ表示
            noMessageSV.isHidden = false
        }
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

extension ScheduleCalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    /**
     土日や祝日の日の文字色を変える
     */
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        //  現在表示されているページの月とセルの月が異なる場合には nil を戻す
        if Calendar.current.compare(date, to: calendar.currentPage, toGranularity: .month) != .orderedSame {
            return nil
        }
        
        //祝日判定をする（祝日は赤色で表示する）
        if judgeHoliday(date){
            return UIColor.red
        }
        //土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
        let weekday = getWeekIdx(date)
        if weekday == 1 {   //日曜日
            return UIColor.red
        }
        else if weekday == 7 {  //土曜日
            return UIColor.blue
        }
        else {
            return UIColor.darkGray
        }
    }
    
    /**
     祝日判定を行い結果を返すメソッド(True:祝日)
     */
    func judgeHoliday(_ date : Date) -> Bool {
        //祝日判定用のカレンダークラスのインスタンス
        let tmpCalendar = Calendar(identifier: .gregorian)
        // 祝日判定を行う日にちの年、月、日を取得
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        
        // CalculateCalendarLogic()：祝日判定のインスタンスの生成
        let holiday = CalculateCalendarLogic()
        
        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }
    
    /**
     date型 -> 年月日をIntで取得
     */
    func getDay(_ date:Date) -> (Int,Int,Int){
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year,month,day)
    }
    
    /**
     曜日判定(日曜日:1 〜 土曜日:7)
     */
    func getWeekIdx(_ date: Date) -> Int{
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
    
    /**
     イベントある日に点を付ける
     */
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int{
        var ret: Int = 0
        
        // 登録日付と比較するために日付を年月日曜日にフォーマット
        let ymdString: String = CommonMethod.dateFormatter(date: date, formattKind: Const.DateFormatt.yyyyMMdd)
        
        for scheduleDetail in scheduleDetails {
            if scheduleDetail.ymdString == ymdString {
                ret += 1
            }
        }
        return ret
    }

    /**
     セルをタップ
     */
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 選択した日付
        selectedDate = date
        // リストをスクロール
        let ymdStr = CommonMethod.dateFormatter(date: date, formattKind: Const.DateFormatt.yyyyMMdd)
        scroll(dateStr: ymdStr)
    }
    
    /**
     月を変更
     */
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        // 表示月を格納
        currentPage = calendar.currentPage
        // 画面表示更新
        self.changeVisual()
    }

}


extension ScheduleCalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        let ymd: String = CommonMethod.dateFormatter(date: CommonMethod.dateFormatter(str: keyArray[section], formattStr: "yyyyMMdd")
                                                     , formattKind: Const.DateFormatt.yyyyMdW)
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
            
            // タイトル
            // 複数日にまたがる場合は(n/n日目)を追加する
            if schedule.days > 1 {
                let dayStr = String(scheduleDetail.dayNo)
                let daysStr = String(schedule.days)
                cell.titleLbl.text = schedule.title + "(" + dayStr + "/" + daysStr + "日目)"
            } else {
                cell.titleLbl.text = schedule.title
            }

            // 時刻
            // 終日
            if schedule.allDay {
                cell.timeLbl.text = "終日"
            // 時刻指定
            } else {
                // １日
                if schedule.days == 1 {
                    cell.timeLbl.text = CommonMethod.dateFormatter(date: schedule.startDate, formattKind: Const.DateFormatt.Hmm)
                    + "〜" + CommonMethod.dateFormatter(date: schedule.endDate, formattKind: Const.DateFormatt.Hmm)
                // 複数日
                } else {
                    // １日め
                    if scheduleDetail.dayNo == 1 {
                        cell.timeLbl.text = CommonMethod.dateFormatter(date: scheduleDetail.date, formattKind: Const.DateFormatt.Hmm) + "〜"
                    // 最終日
                    } else if scheduleDetail.dayNo == schedule.days {
                        cell.timeLbl.text = "〜" + CommonMethod.dateFormatter(date: scheduleDetail.date, formattKind: Const.DateFormatt.Hmm)
                    // 中間日
                    } else {
                        cell.timeLbl.text = "終日"
                    }
                }
            }
            
            let current = Calendar.current
            cell.dateLbl.text = String(current.component(.day, from: scheduleDetail.date))
            cell.weekLbl.text = CommonMethod.weekFormatter(date: scheduleDetail.date)
            cell.memoLbl.text = schedule.memo
            
            // アイコン
            let iconName = Const.Schedule().getIconName(iconCd: schedule.iconCd, colorCd: schedule.iconColorCd)
            cell.iconIV.image = UIImage(named: iconName)
        }
        
        return cell
    }
    
    /**
     指定の日付までスクロールする
     */
    private func scroll(dateStr: String) {
        if let index = keyArray.firstIndex(of: dateStr) {
            let indexPath = IndexPath(row: 0, section: index)
            listTV.scrollToRow(at: indexPath, at: .top, animated: true)
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
        
        let delete = UIContextualAction(style: .normal,
                                            title: "削除",
                                            handler: { (action: UIContextualAction, view: UIView, success :(Bool) -> Void) in
            
            let alert = UIAlertController(title: "", message: Const.Message.DELTE_CONFIRM_MSG, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "いいえ", style: .default, handler: { (action) -> Void in
                // アラートを閉じる
                alert.dismiss(animated: true)
            })
            let ok = UIAlertAction(title: "はい", style: .default, handler: { (action) -> Void in
                var scheduleDetailArray: [ScheduleDetail] = self.scheduleDetailDic[self.keyArray[indexPath.section]]!
                let scheduleId = scheduleDetailArray[indexPath.row].scheduleId
                
                // スケジュール関連TBL削除
                self.deleteSchedule(oshiRealm: self.oshiRealm, scheduleId: scheduleId)

                // 削除したデータをDicからも削除
                scheduleDetailArray.remove(at: indexPath.row)
                self.scheduleDetailDic[self.keyArray[indexPath.section]] = scheduleDetailArray
                if scheduleDetailArray.isEmpty {
                    self.scheduleDetailDic.removeValue(forKey: self.keyArray[indexPath.section])
                    self.keyArray.remove(at: indexPath.section)
                }
                if self.scheduleDetailDic.isEmpty {
                    // スケジュールなしメッセージ表示
                    self.noMessageSV.isHidden = false
                }

                self.listTV.reloadData()
                self.calendar.reloadData()
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

extension ScheduleCalendarViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // 列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    // 行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var cnt: Int = 0
        switch component {
        case 0:
            cnt = yearArray.count
        case 1:
            cnt = monthArray.count
        default:
            cnt = 0
        }
        return cnt
    }

    // データ
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var item: String = ""
        switch component {
        case 0:
            item = yearArray[row]
        case 1:
            item = monthArray[row]
        default:
            item = ""
        }
        return item
    }
    
    // 幅のサイズ
    func pickerView(_ pickerView: UIPickerView, widthForComponent component:Int) -> CGFloat {
        var ret: CGFloat!
        switch component {
        case 0:
            ret = (UIScreen.main.bounds.size.width-50)/2
        case 1:
            ret = (UIScreen.main.bounds.size.width-50)/2
        default:
            ret = (UIScreen.main.bounds.size.width-50)/2
        }
        return ret
    }

    /// Done button
    @objc func tapDoneBtn() {
        headerTF.endEditing(true)
        let dateStr = yearArray[yearMonthPV.selectedRow(inComponent: 0)]
                + monthArray[yearMonthPV.selectedRow(inComponent: 1)]
        let date = CommonMethod.dateFormatter(str: dateStr, formattStr: "yyyy年M月")
        // 選択した年月を表示
        calendar.select(date, scrollToDate: true)
    }

    /// cancel button
    @objc func tapCancelBtn() {
        headerTF.endEditing(true)
    }
}

extension ScheduleCalendarViewController {
    
    /**
     スケジュール関連TBL削除
     */
    func deleteSchedule(oshiRealm: Realm, scheduleId: Int) {
        
        // スケジュール詳細TBL物理削除
        let scheduleDetails: Results<ScheduleDetail> = oshiRealm.objects(ScheduleDetail.self)
            .filter("\(ScheduleDetail.Types.scheduleId.rawValue) = %@", scheduleId)
        
        if !scheduleDetails.isEmpty {
            do {
                try oshiRealm.write {
                    oshiRealm.delete(scheduleDetails)
                }
            } catch {
                print("スケジュール詳細TBL削除失敗", error)
            }
        }

        // スケジュールTBL物理削除
        if let schedule: Schedule = oshiRealm.objects(Schedule.self)
            .filter("\(Schedule.Types.id.rawValue) = %@", scheduleId).first {
            
            do {
                try oshiRealm.write {
                    oshiRealm.delete(schedule)
                }
            } catch {
                print("スケジュールTBL削除失敗", error)
            }
        }
    }
}
