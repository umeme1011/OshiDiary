//
//  ScheduleEditViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/27.
//

import UIKit
import RealmSwift

class ScheduleEditViewController: UIViewController {
    
    @IBOutlet weak var baseView: UIView!
    
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var contentsViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var startDateTF: UITextField!
    @IBOutlet weak var startTimeTF: UITextField!
    @IBOutlet weak var endDateTF: UITextField!
    @IBOutlet weak var endTimeTF: UITextField!
    @IBOutlet weak var repeatTF: UITextField!
    @IBOutlet weak var memoTV: UITextView!
    @IBOutlet weak var placeHolderLbl: UILabel!
    @IBOutlet weak var editAndSaveBtn: UIButton!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var memoBtn: UIButton!
    @IBOutlet weak var headerLbl: UILabel!
    
    @IBOutlet weak var iconIV1: UIImageView!
    @IBOutlet weak var iconIV2: UIImageView!
    @IBOutlet weak var iconIV3: UIImageView!
    @IBOutlet weak var colorBtn1: UIButton!
    @IBOutlet weak var colorBtn2: UIButton!
    @IBOutlet weak var colorBtn3: UIButton!
    @IBOutlet weak var allDaySwitch: UISwitch!
    
    var myUD: MyUserDefaults!
    var datePV: UIPickerView = UIPickerView()
    var timePV: UIPickerView = UIPickerView()
    var repeatPV: UIPickerView = UIPickerView()
    var selectedDate: Date = Date()
    var isNew: Bool = true
    var isEdit: Bool = false
    var oshiId: Int!
    var oshiRealm: Realm!
    var scheduleId: Int!
    var scheduleDetail: ScheduleDetail!
    var schedule: Schedule!

    // pickerView用
    var yearArray: [String] = [String]()
    var monthArray: [String] = [String]()
    var dayArray: [String] = [String]()
    var hourArray: [String] = [String]()
    var minutsArray: [String] = [String]()
    var repeatArray: [String] = [String]()

    // Schedule登録用
    var iconCd: Int!
    var iconColorCd: Int!
    var allDay: Bool = true
    var startDate: Date = Date()
    var endDate: Date = Date()
    var repeatCd: Int = 0
    
    let ICON_SELECTED_COLOR = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoTV.delegate = self
        datePV.delegate = self
        datePV.dataSource = self
        timePV.delegate = self
        timePV.dataSource = self
        repeatPV.delegate = self
        repeatPV.dataSource = self
        
        myUD = MyUserDefaults.init()
        oshiId = myUD.getOshiId()
        oshiRealm = CommonMethod.createOshiRealm(oshiId: oshiId)

        // pickerView用配列作成
        yearArray = Const.Array().getYearArray()
        monthArray = Const.Array.MONTH_ARRAY
        dayArray = Const.Array.DAY_ARRAY
        hourArray = Const.Array.HOUR_ARRAY
        minutsArray = Const.Array().getMinutsArrayPerFive()
        repeatArray = Const.Array.REPEAT_ARRAY
        
        // イメージカラー設定
        baseView.backgroundColor = Const.ImageColor().getImageColor(cd: myUD.getImageColorCd())

        // 枠線
        titleTF.layer.borderColor  = UIColor(red:0.76, green:0.76, blue:0.76, alpha:1.0).cgColor
        titleTF.layer.cornerRadius = 5.0
        startDateTF.borderStyle = .none
        startTimeTF.borderStyle = .none
        endDateTF.borderStyle = .none
        endTimeTF.borderStyle = .none
        repeatTF.borderStyle = .none
        memoTV.layer.borderColor = UIColor(red:0.76, green:0.76, blue:0.76, alpha:1.0).cgColor
        memoTV.layer.cornerRadius = 5.0
        
        //***********************
        // startDateTF toolbar
        let startDateToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        let startDateCancelItem = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(tapStartDateCancelBtn))
        let startDateSpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let startDateDoneItem = UIBarButtonItem(title: "決定", style: .plain, target: self, action: #selector(tapStartDateDoneBtn))
        startDateToolbar.setItems([startDateCancelItem, startDateSpacelItem, startDateDoneItem], animated: true)
        startDateTF.inputView = datePV
        startDateTF.inputAccessoryView = startDateToolbar

        //***********************
        // endDateTF toolbar
        let endDateToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        let endDateCancelItem = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(tapEndDateCancelBtn))
        let endDateSpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let endDateDoneItem = UIBarButtonItem(title: "決定", style: .plain, target: self, action: #selector(tapEndDateDoneBtn))
        endDateToolbar.setItems([endDateCancelItem, endDateSpacelItem, endDateDoneItem], animated: true)
        endDateTF.inputView = datePV
        endDateTF.inputAccessoryView = endDateToolbar

        //***********************
        // startTimeTF toolbar
        let startTimeToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        let startTimeCancelItem = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(tapStartTimeCancelBtn))
        let startTimeSpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let startTimeDoneItem = UIBarButtonItem(title: "決定", style: .plain, target: self, action: #selector(tapStartTimeDoneBtn))
        startTimeToolbar.setItems([startTimeCancelItem, startTimeSpacelItem, startTimeDoneItem], animated: true)
        startTimeTF.inputView = timePV
        startTimeTF.inputAccessoryView = startTimeToolbar

        //***********************
        // endTimeTF toolbar
        let endTimeToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        let endTimeCancelItem = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(tapEndTimeCancelBtn))
        let endTimeSpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let endTimeDoneItem = UIBarButtonItem(title: "決定", style: .plain, target: self, action: #selector(tapEndTimeDoneBtn))
        endTimeToolbar.setItems([endTimeCancelItem, endTimeSpacelItem, endTimeDoneItem], animated: true)
        endTimeTF.inputView = timePV
        endTimeTF.inputAccessoryView = endTimeToolbar

        //***********************
        // repeatTF toolbar
        let repeatToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        let repeatCancelItem = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(tapRepeatCancelBtn))
        let repeatSpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let repeatDoneItem = UIBarButtonItem(title: "決定", style: .plain, target: self, action: #selector(tapRepeatDoneBtn))
        repeatToolbar.setItems([repeatCancelItem, repeatSpacelItem, repeatDoneItem], animated: true)
        repeatTF.inputView = repeatPV
        repeatTF.inputAccessoryView = repeatToolbar

        // 新規作成
        if isNew {
            // プレースホルダー
            titleTF.attributedPlaceholder = NSAttributedString(string: "タイトルを記入",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])

            // 年月日初期値
            startDateTF.text = CommonMethod.dateFormatter(date: selectedDate, formattKind: Const.DateFormatt.yyyyMdW)
            endDateTF.text = CommonMethod.dateFormatter(date: selectedDate, formattKind: Const.DateFormatt.yyyyMdW)
            
            // 時刻初期値 0:00
            let calendar = Calendar(identifier: .gregorian)
            let tmp = calendar.dateComponents([.year, .month, .day], from: selectedDate)
            let date = calendar.date(from: tmp)
            startDate = date ?? Date()
            endDate = date ?? Date()
            startTimeTF.text = "0:00"
            endTimeTF.text = "0:00"
            
            // PickerView初期値
            let yearStr = CommonMethod.dateFormatter(date: selectedDate, formattKind: Const.DateFormatt.yyyy)
            let monthStr = CommonMethod.dateFormatter(date: selectedDate, formattKind: Const.DateFormatt.M)
            let dayStr = CommonMethod.dateFormatter(date: selectedDate, formattKind: Const.DateFormatt.d)
            let hourStr = "0"
            let minutsStr = "00"
            datePV.selectRow(yearArray.firstIndex(of: yearStr)!, inComponent: 0, animated: true)
            datePV.selectRow(monthArray.firstIndex(of: monthStr)!, inComponent: 1, animated: true)
            datePV.selectRow(dayArray.firstIndex(of: dayStr)!, inComponent: 2, animated: true)
            timePV.selectRow(hourArray.firstIndex(of: hourStr)!, inComponent: 0, animated: true)
            timePV.selectRow(minutsArray.firstIndex(of: minutsStr)!, inComponent: 2, animated: true)

            // 時刻非表示
            startTimeTF.isHidden = true
            endTimeTF.isHidden = true
            // アイコン初期値選択
            iconCd = Const.Schedule.iconCd.BIRTHDAY
            selectIcon(iconCd: iconCd)
            // アイコンカラー初期値選択
            iconColorCd = Const.Schedule.colorCd.GRAY
            selectIconColor(iconColorCd: iconColorCd)
            // 繰り返し初期値
            repeatTF.text = repeatArray.first
            repeatPV.selectRow(0, inComponent: 0, animated: true)
            
            // 編集フラグ
            isEdit = true
            // 保存ボタン画像にする
            editAndSaveBtn.setImage(UIImage(systemName: "checkmark"), for: .normal)
            // ヘッダ文言設定
            headerLbl.text = "新規作成"
            // 枠線
            titleTF.layer.borderWidth = 1
            memoTV.layer.borderWidth = 1

        // 既存編集
        } else {
            // スケジュールID
            scheduleId = scheduleDetail.scheduleId
            
            // スケジュールTBL取得
            schedule = oshiRealm.objects(Schedule.self)
                .filter("\(Schedule.Types.id.rawValue) = %@", scheduleId!).first!
            
            // 開始、終了日時
            startDate = schedule.startDate
            endDate = schedule.endDate
            
            // タイトル
            titleTF.text = schedule.title

            // アイコン
            iconCd = schedule.iconCd
            selectIcon(iconCd: iconCd)
            // アイコンカラー
            iconColorCd = schedule.iconColorCd
            selectIconColor(iconColorCd: iconColorCd)
            // 終日
            allDay = schedule.allDay
            allDaySwitch.isOn = schedule.allDay
            
            // 年月日
            startDateTF.text = CommonMethod.dateFormatter(date: schedule.startDate, formattKind: Const.DateFormatt.yyyyMdW)
            endDateTF.text = CommonMethod.dateFormatter(date: schedule.endDate, formattKind: Const.DateFormatt.yyyyMdW)
            // 時刻
            if !schedule.allDay {
                startTimeTF.text = CommonMethod.dateFormatter(date: schedule.startDate, formattKind: Const.DateFormatt.Hmm)
                endTimeTF.text = CommonMethod.dateFormatter(date: schedule.endDate, formattKind: Const.DateFormatt.Hmm)
            } else {
                startTimeTF.text = "0:00"
                endTimeTF.text = "0:00"
                // 非表示
                startTimeTF.isHidden = true
                endTimeTF.isHidden = true
            }
            
            // PickerView初期値
            let yearStr = CommonMethod.dateFormatter(date: schedule.startDate, formattKind: Const.DateFormatt.yyyy)
            let monthStr = CommonMethod.dateFormatter(date: schedule.startDate, formattKind: Const.DateFormatt.M)
            let dayStr = CommonMethod.dateFormatter(date: schedule.startDate, formattKind: Const.DateFormatt.d)
            let hourStr = "0"
            let minutsStr = "00"
            datePV.selectRow(yearArray.firstIndex(of: yearStr)!, inComponent: 0, animated: true)
            datePV.selectRow(monthArray.firstIndex(of: monthStr)!, inComponent: 1, animated: true)
            datePV.selectRow(dayArray.firstIndex(of: dayStr)!, inComponent: 2, animated: true)
            timePV.selectRow(hourArray.firstIndex(of: hourStr)!, inComponent: 0, animated: true)
            timePV.selectRow(minutsArray.firstIndex(of: minutsStr)!, inComponent: 2, animated: true)

            // 繰り返し
            repeatCd = schedule.repeatCd
            repeatTF.text = repeatArray[schedule.repeatCd]
            repeatPV.selectRow(schedule.repeatCd, inComponent: 0, animated: true)

            // メモ
            memoTV.text = schedule.memo
            placeHolderLbl.isHidden = true
            
            // 初期表示は編集不可
            coverView.isHidden = false
            memoBtn.isHidden = true
            // ヘッダ文言設定
            headerLbl.text = "参照"
            // 枠線
            titleTF.layer.borderWidth = 0
            memoTV.layer.borderWidth = 0
        }
    }
    
    /**
     戻るボタン押下
     */
    @IBAction func tapCancelBtn(_ sender: Any) {
        
        if !isEdit {
            self.dismiss(animated: true)
            
        // 編集状態は確認アラームを表示
        } else {
            let alert = UIAlertController(title: "", message: Const.Message.EDIT_BACK_CONFIRM_MSG, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "いいえ", style: .default, handler: { (action) -> Void in
                // アラートを閉じる
                alert.dismiss(animated: true)
            })
            let ok = UIAlertAction(title: "はい", style: .default, handler: { (action) -> Void in
                // 画面を閉じる
                self.dismiss(animated: true)
            })
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func tapIconBtn1(_ sender: Any) {
        iconCd = Const.Schedule.iconCd.BIRTHDAY
        selectIcon(iconCd: Const.Schedule.iconCd.BIRTHDAY)
    }
    @IBAction func tapIconBtn2(_ sender: Any) {
        iconCd = Const.Schedule.iconCd.PRESENT
        selectIcon(iconCd: Const.Schedule.iconCd.PRESENT)
    }
    @IBAction func tapIconBtn3(_ sender: Any) {
        iconCd = Const.Schedule.iconCd.RIBBON
        selectIcon(iconCd: Const.Schedule.iconCd.RIBBON)
    }
    @IBAction func tapColorBtn1(_ sender: Any) {
        iconColorCd = Const.Schedule.colorCd.GRAY
        selectIconColor(iconColorCd: Const.Schedule.colorCd.GRAY)
    }
    @IBAction func tapColorBtn2(_ sender: Any) {
        iconColorCd = Const.Schedule.colorCd.BLUE
        selectIconColor(iconColorCd: Const.Schedule.colorCd.BLUE)
    }
    
    /**
     終日スイッチ
     */
    @IBAction func changeSwitch(_ sender: Any) {
        if allDaySwitch.isOn {
            allDay = true
            // 時刻を非表示
            startTimeTF.isHidden = true
            endTimeTF.isHidden = true
            // startDate, endDate設定
            let startDateStr = (startDateTF.text?.components(separatedBy: "(")[0])! + "0:00"
            let start = CommonMethod.dateFormatter(str: startDateStr, formattStr: "yyyy年M月d日H:mm")
            startDate = start
            let endDateStr = (endDateTF.text?.components(separatedBy: "(")[0])! + "0:00"
            let end = CommonMethod.dateFormatter(str: endDateStr, formattStr: "yyyy年M月d日H:mm")
            endDate = end
        } else {
            allDay = false
            // 時刻を表示
            startTimeTF.isHidden = false
            endTimeTF.isHidden = false
            // startDate, endDate設定
            let startDateStr = (startDateTF.text?.components(separatedBy: "(")[0])! + startTimeTF.text!
            let start = CommonMethod.dateFormatter(str: startDateStr, formattStr: "yyyy年M月d日H:mm")
            startDate = start
            let endDateStr = (endDateTF.text?.components(separatedBy: "(")[0])! + endTimeTF.text!
            let end = CommonMethod.dateFormatter(str: endDateStr, formattStr: "yyyy年M月d日H:mm")
            endDate = end
        }
    }
    
    /**
     値渡し
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toScheduleEditMemo") {
            let vc:ScheduleEditMemoViewController = segue.destination as? ScheduleEditMemoViewController ?? ScheduleEditMemoViewController()
            vc.memo = memoTV.text
        }
    }

    /**
     編集、保存ボタン押下
     */
    @IBAction func tapSaveBtn(_ sender: Any) {
        
        // 編集ボタン押下
        if !isEdit {
            
            // 編集モードに変更
            changeEditMode()
            
        // 保存ボタン押下
        } else {
            // 開始日〜終了日を１日ごと配列に格納
            // 開始日と終了日のみ時刻を設定、中間日は0:00とする
            let calendar = Calendar(identifier: .gregorian)
            var dateArray: [Date] = [Date]()
            var startDateTmp = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: startDate))!
            let endDateTmp = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: endDate))!
            while startDateTmp <= endDateTmp {
                dateArray.append(startDateTmp)
                startDateTmp = Calendar.current.date(byAdding: .day, value: 1, to: startDateTmp)!
            }
            dateArray[0] = startDate
            dateArray[dateArray.count - 1] = endDate
            
            // 新規登録
            if isNew {
                self.saveSchedule(dateArray: dateArray)
                self.saveScheduleDetail(dateArray: dateArray, isAll: true, psId: 0) // psId未使用

            // 既存データ更新
            } else {
                if let schedule: Schedule = oshiRealm.objects(Schedule.self)
                    .filter("\(Schedule.Types.id.rawValue) = %@", scheduleId!).first {
                    
                    // 親ID退避
                    let psId = schedule.parentScheduleId
                    
                    // 繰り返し設定あり、かつ繰り返し設定変更なし、かつ日時変更なし
                    if schedule.repeatCd != Const.Schedule.repeatCd.NO_REPEAT
                        && schedule.repeatCd == repeatCd
                        && schedule.startDate == self.startDate && schedule.endDate == self.endDate {
                        let alert = UIAlertController(title: "", message: "繰り返しスケジュールをすべて更新しますか？", preferredStyle: .alert)
                        let cancel = UIAlertAction(title: "いいえ", style: .default, handler: { (action) -> Void in
                            
                            // スケジュールTBL更新
                            self.updateSchedule(dateArray: dateArray)
                            // スケジュール詳細TBL削除、登録
                            self.deleteScheduleDetail(psId: psId, isAll: false)
                            self.saveScheduleDetail(dateArray: dateArray, isAll: false, psId: psId)
                            
                            alert.dismiss(animated: true)
                        })
                        let ok = UIAlertAction(title: "はい", style: .default, handler: { (action) -> Void in

                            // 関連スケジュールTBL全更新
                            self.updateSchedules(dateArray: dateArray, psId: psId)
                            
                            alert.dismiss(animated: true)
                        })
                        alert.addAction(cancel)
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)

                    // 繰り返し設定なし、かつ繰り返し設定変更なし
                    } else if schedule.repeatCd == Const.Schedule.repeatCd.NO_REPEAT
                                && schedule.repeatCd == self.repeatCd {
                        
                        // スケジュールTBL更新
                        self.updateSchedule(dateArray: dateArray)
                        // スケジュール詳細TBL削除、登録
                        self.deleteScheduleDetail(psId: psId, isAll: false)
                        self.saveScheduleDetail(dateArray: dateArray, isAll: false, psId: psId)

                    // 繰り返し設定変更あり、または日時変更あり
                    } else if (schedule.repeatCd != repeatCd)
                                || (schedule.startDate != self.startDate || schedule.endDate != self.endDate) {
                        
                        let alert = UIAlertController(title: "", message: "開始日時・終了日時・繰り返し設定を変更する場合、変更した日時からのスタートになります。よろしいですか？", preferredStyle: .alert)
                        let cancel = UIAlertAction(title: "いいえ", style: .default, handler: { (action) -> Void in
                            
                            // 編集モードに変更
                            self.changeEditMode()
                            
                            alert.dismiss(animated: true)
                        })
                        let ok = UIAlertAction(title: "はい", style: .default, handler: { (action) -> Void in

                            // スケジュールTBL、スケジュール詳細TBL削除、登録
                            self.deleteSchedule(psId: psId)
                            self.deleteScheduleDetail(psId: psId, isAll: true)
                            self.saveSchedule(dateArray: dateArray)
                            self.saveScheduleDetail(dateArray: dateArray, isAll: true, psId: psId)

                            alert.dismiss(animated: true)
                        })
                        alert.addAction(cancel)
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    
                    }
                }
            }
            // 参照モードに変更
            changeNoEditMode()
        }
    }
    
    
    /**
     削除ボタン押下
     */
    @IBAction func tapDeleteBtn(_ sender: Any) {
        
        // 繰り返しあり
        if repeatCd != Const.Schedule.repeatCd.NO_REPEAT {
            let alert = UIAlertController(title: "", message: Const.Message.DELTE_CONFIRM_MSG, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "いいえ", style: .default, handler: { (action) -> Void in
                // アラートを閉じる
                alert.dismiss(animated: true)
            })
            let ok_one = UIAlertAction(title: "この予定のみ", style: .default, handler: { (action) -> Void in
                
                // スケジュール関連TBL削除
                ScheduleCalendarViewController().deleteSchedule(oshiRealm: self.oshiRealm, scheduleId: self.scheduleId, isAll: false)
                self.dismiss(animated: true)
            })
            let ok_all = UIAlertAction(title: "すべての予定", style: .default, handler: { (action) -> Void in
                
                // スケジュール関連TBL削除
                ScheduleCalendarViewController().deleteSchedule(oshiRealm: self.oshiRealm, scheduleId: self.scheduleId, isAll: true)
                self.dismiss(animated: true)
            })
            alert.addAction(cancel)
            alert.addAction(ok_one)
            alert.addAction(ok_all)
            self.present(alert, animated: true, completion: nil)

        // 繰り返しなし
        } else {
            let alert = UIAlertController(title: "", message: Const.Message.DELTE_CONFIRM_MSG, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "いいえ", style: .default, handler: { (action) -> Void in
                // アラートを閉じる
                alert.dismiss(animated: true)
            })
            let ok = UIAlertAction(title: "はい", style: .default, handler: { (action) -> Void in
                
                // スケジュール関連TBL削除
                ScheduleCalendarViewController().deleteSchedule(oshiRealm: self.oshiRealm, scheduleId: self.scheduleId, isAll: false)
                self.dismiss(animated: true)
            })
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ScheduleEditViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // 列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        var cnt: Int = 0
        switch pickerView {
        case datePV:
            cnt = 3
        case timePV:
            cnt = 3
        case repeatPV:
            cnt = 1
        default:
            fatalError()
        }
        return cnt
    }

    // 行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var cnt: Int = 0
        switch pickerView {
        case datePV:
            switch component {
            case 0:
                cnt = yearArray.count
            case 1:
                cnt = monthArray.count
            case 2:
                cnt = dayArray.count
            default:
                cnt = 0
            }
        case timePV:
            switch component {
            case 0:
                cnt = hourArray.count
            case 1:
                cnt = 1
            case 2:
                cnt = minutsArray.count
            default:
                cnt = 0
            }
        case repeatPV:
            cnt = repeatArray.count
        default:
            fatalError()
        }
        return cnt
    }

    // データ
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var item: String = ""
        switch pickerView {
        case datePV:
            switch component {
            case 0:
                item = yearArray[row]
            case 1:
                item = monthArray[row]
            case 2:
                item = dayArray[row]
          default:
                item = ""
            }
        case timePV:
            switch component {
            case 0:
                item = hourArray[row]
            case 1:
                item = ":"
            case 2:
                item = minutsArray[row]
            default:
                item = ""
            }
        case repeatPV:
            item = repeatArray[row]
        default:
            fatalError()
        }
        return item
    }
    
    // 幅のサイズ
    func pickerView(_ pickerView: UIPickerView, widthForComponent component:Int) -> CGFloat {
        var ret: CGFloat!
        switch pickerView {
        case datePV:
            switch component {
            case 0:
                ret = (UIScreen.main.bounds.size.width-50)/3
            case 1:
                ret = (UIScreen.main.bounds.size.width-50)/3
            default:
                ret = (UIScreen.main.bounds.size.width-50)/3
            }
        case timePV:
            switch component {
            case 0:
                ret = (UIScreen.main.bounds.size.width-100)/2
            case 1:
                ret = 50
            case 2:
                ret = (UIScreen.main.bounds.size.width-100)/2
            default:
                ret = (UIScreen.main.bounds.size.width-100)/2
            }
        case repeatPV:
            ret = UIScreen.main.bounds.size.width
        default:
            fatalError()
        }
        return ret
    }

    /// Done button
    @objc func tapStartDateDoneBtn() {
        startDateTF.endEditing(true)
        var tmp = yearArray[datePV.selectedRow(inComponent: 0)]
                + monthArray[datePV.selectedRow(inComponent: 1)]
                + dayArray[datePV.selectedRow(inComponent: 2)]
        // 時間と結合
        tmp += startTimeTF.text ?? ""
        // dateに変換
        let date = CommonMethod.dateFormatter(str: tmp, formattStr: "yyyy年M月d日H:mm")
        // startDateに格納
        startDate = date
        // 曜日をつけてStringに変換
        let dateStr = CommonMethod.dateFormatter(date: date, formattKind: Const.DateFormatt.yyyyMdW)
        // TFに設定
        startDateTF.text = dateStr
    }

    /// cancel button
    @objc func tapStartDateCancelBtn() {
        startDateTF.endEditing(true)
    }

    /// Done button
    @objc func tapEndDateDoneBtn() {
        endDateTF.endEditing(true)
        var tmp = yearArray[datePV.selectedRow(inComponent: 0)]
                + monthArray[datePV.selectedRow(inComponent: 1)]
                + dayArray[datePV.selectedRow(inComponent: 2)]
        // 時間と結合
        tmp += endTimeTF.text ?? ""
        // dateに変換
        let date = CommonMethod.dateFormatter(str: tmp, formattStr: "yyyy年M月d日H:mm")
        // endDateに格納
        endDate = date
        // 曜日をつけてStringに変換
        let dateStr = CommonMethod.dateFormatter(date: date, formattKind: Const.DateFormatt.yyyyMdW)
        // TFに設定
        endDateTF.text = dateStr
    }

    /// cancel button
    @objc func tapEndDateCancelBtn() {
        endDateTF.endEditing(true)
    }

    /// Done button
    @objc func tapStartTimeDoneBtn() {
        startTimeTF.endEditing(true)
        var timeStr = hourArray[timePV.selectedRow(inComponent: 0)] + ":" + minutsArray[timePV.selectedRow(inComponent: 2)]
        // TFに設定
        startTimeTF.text = timeStr
        // 年月日と結合
        timeStr = (startDateTF.text?.components(separatedBy: "(")[0])! + timeStr
        // dateに変換
        let date = CommonMethod.dateFormatter(str: timeStr, formattStr: "yyyy年M月d日H:mm")
        // startDateに格納
        startDate = date
    }

    /// cancel button
    @objc func tapStartTimeCancelBtn() {
        startTimeTF.endEditing(true)
    }
    
    /// Done button
    @objc func tapEndTimeDoneBtn() {
        endTimeTF.endEditing(true)
        var timeStr = hourArray[timePV.selectedRow(inComponent: 0)] + ":" + minutsArray[timePV.selectedRow(inComponent: 2)]
        // TFに設定
        endTimeTF.text = timeStr
        // 年月日と結合
        timeStr = (endDateTF.text?.components(separatedBy: "(")[0])! + timeStr
        // dateに変換
        let date = CommonMethod.dateFormatter(str: timeStr, formattStr: "yyyy年M月d日H:mm")
        // endDateに格納
        endDate = date
    }

    /// cancel button
    @objc func tapEndTimeCancelBtn() {
        endTimeTF.endEditing(true)
    }

    /// Done button
    @objc func tapRepeatDoneBtn() {
        repeatTF.endEditing(true)
        // TFに設定
        repeatTF.text = repeatArray[repeatPV.selectedRow(inComponent: 0)]
        repeatCd = repeatArray.firstIndex(of: repeatTF.text!) ?? 0
    }

    /// cancel button
    @objc func tapRepeatCancelBtn() {
        repeatTF.endEditing(true)
    }

}

extension ScheduleEditViewController: UITextViewDelegate {
    /**
     変更あったとき
     */
    func textViewDidChange(_ textView: UITextView) {
        if memoTV.text.count > 0 {
            placeHolderLbl.isHidden = true
        } else {
            placeHolderLbl.isHidden = false
        }
    }
}

extension ScheduleEditViewController {
    
    /**
     アイコン選択状態反映
     */
    private func selectIcon(iconCd: Int) {
        
        switch iconCd {
        case Const.Schedule.iconCd.BIRTHDAY:
            iconIV1.backgroundColor = ICON_SELECTED_COLOR
            iconIV2.backgroundColor = UIColor.clear
            iconIV3.backgroundColor = UIColor.clear
        case Const.Schedule.iconCd.PRESENT:
            iconIV1.backgroundColor = UIColor.clear
            iconIV2.backgroundColor = ICON_SELECTED_COLOR
            iconIV3.backgroundColor = UIColor.clear
        case Const.Schedule.iconCd.RIBBON:
            iconIV1.backgroundColor = UIColor.clear
            iconIV2.backgroundColor = UIColor.clear
            iconIV3.backgroundColor = ICON_SELECTED_COLOR
        default:
            iconIV1.backgroundColor = ICON_SELECTED_COLOR
            iconIV2.backgroundColor = UIColor.clear
            iconIV3.backgroundColor = UIColor.clear
        }
    }
    
    /**
     アイコンカラー選択状態反映
     */
    private func selectIconColor(iconColorCd: Int) {
        
        switch iconColorCd {
        case Const.Schedule.colorCd.GRAY:
            colorBtn1.setTitle("✓", for: .normal)
            colorBtn2.setTitle("", for: .normal)
            colorBtn3.setTitle("", for: .normal)
        case Const.Schedule.colorCd.BLUE:
            colorBtn1.setTitle("", for: .normal)
            colorBtn2.setTitle("✓", for: .normal)
            colorBtn3.setTitle("", for: .normal)
        case Const.Schedule.colorCd.ORANGE:
            colorBtn1.setTitle("", for: .normal)
            colorBtn2.setTitle("", for: .normal)
            colorBtn3.setTitle("✓", for: .normal)
        default:
            colorBtn1.setTitle("✓", for: .normal)
            colorBtn2.setTitle("", for: .normal)
            colorBtn3.setTitle("", for: .normal)
        }
        // アイコンのカラー反映
        iconIV1.image = UIImage(named: Const.Schedule()
            .getIconName(iconCd: Const.Schedule.iconCd.BIRTHDAY, colorCd: iconColorCd))
        iconIV2.image = UIImage(named: Const.Schedule()
            .getIconName(iconCd: Const.Schedule.iconCd.PRESENT, colorCd: iconColorCd))
        iconIV3.image = UIImage(named: Const.Schedule()
            .getIconName(iconCd: Const.Schedule.iconCd.RIBBON, colorCd: iconColorCd))
    }
    
    /**
     編集モードに変更
     */
    private func changeEditMode() {
        // ボタン画像をチェックマークに変更
        editAndSaveBtn.setImage(UIImage(systemName: "checkmark"), for: .normal)
        // 編集可能にする
        coverView.isHidden = true
        memoBtn.isHidden = false
        // 編集フラグ
        isEdit = true
        // ヘッダ文言設定
        headerLbl.text = "編集"
        // 枠線
        titleTF.layer.borderWidth = 1
        memoTV.layer.borderWidth = 1
        // プレースホルダー
        if titleTF.text!.isEmpty {
            titleTF.attributedPlaceholder = NSAttributedString(string: "タイトルを記入",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
        if memoTV.text.isEmpty {
            placeHolderLbl.isHidden = false
        }
    }
    
    /**
     参照モードに変更
     */
    private func changeNoEditMode() {
        isEdit = false
        coverView.isHidden = false
        memoBtn.isHidden = true
        editAndSaveBtn.setImage(UIImage(systemName: "pencil.and.ellipsis.rectangle"), for: .normal)
        // TFの編集状態を解除
        titleTF.endEditing(true)
        startDateTF.endEditing(true)
        startTimeTF.endEditing(true)
        endDateTF.endEditing(true)
        endTimeTF.endEditing(true)
        repeatTF.endEditing(true)
        // 枠線
        titleTF.layer.borderWidth = 0
        memoTV.layer.borderWidth = 0
        // ヘッダ文言設定
        headerLbl.text = "参照"
        // プレースホルダー
        if titleTF.text!.isEmpty {
            titleTF.attributedPlaceholder = NSAttributedString(string: "",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
        if memoTV.text.isEmpty {
            placeHolderLbl.isHidden = true
        }
    }
    
    /**
     スケジュールTBL1件更新
     */
    private func updateSchedule(dateArray: [Date]) {
        try! self.oshiRealm.write {
            schedule.title = self.titleTF.text ?? ""
            schedule.iconCd = self.iconCd
            schedule.iconColorCd = self.iconColorCd
            schedule.allDay = self.allDay
            schedule.startDate = self.startDate
            schedule.endDate = self.endDate
            schedule.days = dateArray.count
            schedule.repeatCd = self.repeatCd
            schedule.memo = self.memoTV.text
            schedule.updateDate = Date()
        }
    }
    
    /**
     関連スケジュールTBL全件更新
     */
    private func updateSchedules(dateArray: [Date], psId: Int) {
        
        let schedules: Results<Schedule> = self.oshiRealm.objects(Schedule.self)
            .filter("\(Schedule.Types.parentScheduleId.rawValue) = %@", psId)

        try! self.oshiRealm.write {
            for schedule in schedules {
                schedule.title = self.titleTF.text ?? ""
                schedule.iconCd = self.iconCd
                schedule.iconColorCd = self.iconColorCd
                schedule.allDay = self.allDay
//                schedule.startDate = self.startDate
//                schedule.endDate = self.endDate
//                schedule.days = dateArray.count
//                schedule.repeatCd = self.repeatCd
                schedule.memo = self.memoTV.text
                schedule.updateDate = Date()
            }
        }
        
    }
    
    /**
     スケジュールTBL繰り返しデータ全削除
     */
    private func deleteSchedule(psId: Int) {
        // 関連スケジュールTBL全削除
        let schedules: Results<Schedule> = self.oshiRealm.objects(Schedule.self)
            .filter("\(Schedule.Types.parentScheduleId.rawValue) = %@", psId)
        do {
            try self.oshiRealm.write {
                self.oshiRealm.delete(schedules)
            }
        } catch {
            print("スケジュールTBL削除失敗", error)
        }
    }
    
    /**
     スケジュール詳細TBL削除
     */
    private func deleteScheduleDetail(psId: Int, isAll: Bool) {
        
        var scheduleDetails: Results<ScheduleDetail>!
        if isAll {
            // 繰り返しすべて削除
            scheduleDetails = self.oshiRealm.objects(ScheduleDetail.self)
                .filter("\(ScheduleDetail.Types.parentScheduleId.rawValue) = %@", psId)
        } else {
            // スケジュールIDに紐づくものを削除
            scheduleDetails = self.oshiRealm.objects(ScheduleDetail.self)
                .filter("\(ScheduleDetail.Types.scheduleId.rawValue) = %@", scheduleId!)
        }
        
        do {
            try self.oshiRealm.write {
                self.oshiRealm.delete(scheduleDetails)
            }
        } catch {
            print("スケジュール詳細TBL削除失敗", error)
        }
    }
    
    /**
     スケジュールTBL登録
     */
    private func saveSchedule(dateArray: [Date]) {
        
        // ScheduleID発行
        scheduleId = 1
        if let schedule: Schedule = oshiRealm.objects(Schedule.self)
            .sorted(byKeyPath: Schedule.Types.id.rawValue, ascending: false).first {
            scheduleId = schedule.id + 1
        }

        // スケジュールTBL
        var scheduleId = self.scheduleId
        var startDate = self.startDate
        var endDate = self.endDate
        try! oshiRealm.write {
            // 繰り返し登録
            for _ in 1...Const.Schedule().getReapeatCount(repeatCd: repeatCd) {
                let schedule = Schedule()
                schedule.id = scheduleId!
                schedule.title = titleTF.text ?? ""
                schedule.iconCd = iconCd
                schedule.iconColorCd = iconColorCd
                schedule.allDay = allDay
                schedule.startDate = startDate
                schedule.endDate = endDate
                schedule.days = dateArray.count
                schedule.repeatCd = repeatCd
                schedule.memo = memoTV.text
                schedule.parentScheduleId = self.scheduleId
                oshiRealm.add(schedule)
                
                scheduleId! += 1
                
                // 繰り返し種類により日時に加算する単位を変更
                switch repeatCd {
                case Const.Schedule.repeatCd.YEAR:
                    startDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate)!
                    endDate = Calendar.current.date(byAdding: .year, value: 1, to: endDate)!
                case Const.Schedule.repeatCd.MONTH:
                    startDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
                    endDate = Calendar.current.date(byAdding: .month, value: 1, to: endDate)!
                case Const.Schedule.repeatCd.WEEK:
                    startDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: startDate)!
                    endDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: endDate)!
                default:
                    print("no repeat")
                }
            }
        }
    }
    
    /**
     スケジュール詳細TBL登録
     */
    private func saveScheduleDetail(dateArray: [Date], isAll: Bool, psId: Int) {

        // スケジュール詳細ID発行
        var scheduleDetailId = 1
        if let scheduleDetail: ScheduleDetail = oshiRealm.objects(ScheduleDetail.self)
            .sorted(byKeyPath: ScheduleDetail.Types.id.rawValue, ascending: false).first {
            scheduleDetailId = scheduleDetail.id + 1
        }
        
        var dates: [Date] = dateArray
        
        // 登録
        var scheduleId = self.scheduleId
        try! oshiRealm.write {
            
            var max: Int!
            var parentId: Int!
            // 繰り返し全件登録
            if isAll {
                max = Const.Schedule().getReapeatCount(repeatCd: repeatCd)
                parentId = self.scheduleId
            // 1件登録
            } else {
                max = 1
                parentId = psId
            }
            // 登録
            for _ in 1...max {
                var dayNo = 1
                for date in dates {
                    let scheduleDetail = ScheduleDetail()
                    scheduleDetail.id = scheduleDetailId
                    scheduleDetail.scheduleId = scheduleId!
                    scheduleDetail.dayNo = dayNo
                    scheduleDetail.date = date
                    scheduleDetail.ymdString = CommonMethod.dateFormatter(date: date, formattKind: Const.DateFormatt.yyyyMMdd)
                    scheduleDetail.ymString = CommonMethod.dateFormatter(date: date, formattKind: Const.DateFormatt.yyyyMM)
                    scheduleDetail.parentScheduleId = parentId
                    oshiRealm.add(scheduleDetail)
                    scheduleDetailId += 1
                    dayNo += 1
                }
                scheduleId! += 1
                
                // 繰り返し種類により日時に加算する単位を変更
                var nextDateArray: [Date] = [Date]()
                switch repeatCd {
                case Const.Schedule.repeatCd.YEAR:
                    for date in dates {
                        nextDateArray.append(Calendar.current.date(byAdding: .year, value: 1, to: date)!)
                    }
                case Const.Schedule.repeatCd.MONTH:
                    for date in dates {
                        nextDateArray.append(Calendar.current.date(byAdding: .month, value: 1, to: date)!)
                    }
                case Const.Schedule.repeatCd.WEEK:
                    for date in dates {
                        nextDateArray.append(Calendar.current.date(byAdding: .weekOfYear, value: 1, to: date)!)
                    }
                default:
                    print("no repeat")
                }
                dates = nextDateArray
            }
        }
    }

}
