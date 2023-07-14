//
//  ScheduleEditViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/27.
//

import UIKit

class ScheduleEditViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var baseView: UIView!
    
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var memoTV: PlaceHolderTextView!
    @IBOutlet weak var contentsViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var startDateTF: UITextField!
    @IBOutlet weak var startTimeTF: UITextField!
    @IBOutlet weak var endDateTF: UITextField!
    @IBOutlet weak var endTimeTF: UITextField!
    @IBOutlet weak var repeatTF: UITextField!
    
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
    var selectedDate: Date = Date()
    var isNew: Bool = true

    // pickerView用
    var yearArray: [String] = [String]()
    var monthArray: [String] = [String]()
    var dayArray: [String] = [String]()
    var hourArray: [String] = [String]()
    var minutsArray: [String] = [String]()

    // Schedule登録用
    var iconCd: Int!
    var iconColorCd: Int!
    var allDay: Bool = true
    var startDate: Date = Date()
    var endDate: Date = Date()
    
    let ICON_SELECTED_COLOR = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoTV.delegate = self
        datePV.delegate = self
        datePV.dataSource = self
        timePV.delegate = self
        timePV.dataSource = self
        
        myUD = MyUserDefaults.init()
        
        // pickerView用配列作成
        yearArray = Const.Array().getYearArray()
        monthArray = Const.Array.MONTH_ARRAY
        dayArray = Const.Array.DAY_ARRAY
        hourArray = Const.Array.HOUR_ARRAY
        minutsArray = Const.Array().getMinutsArrayPerFive()
        
        // イメージカラー設定
        baseView.backgroundColor = Const.ImageColor().getImageColor(cd: myUD.getImageColorCd())

        // キーボード開閉アクション設定
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // 枠線
        titleTF.layer.borderColor  = UIColor(red:0.76, green:0.76, blue:0.76, alpha:1.0).cgColor
        titleTF.layer.borderWidth = 1.0
        titleTF.layer.cornerRadius = 5.0
        startDateTF.borderStyle = .none
        startTimeTF.borderStyle = .none
        endDateTF.borderStyle = .none
        endTimeTF.borderStyle = .none
        repeatTF.layer.borderWidth = 0
        memoTV.layer.borderColor = UIColor(red:0.76, green:0.76, blue:0.76, alpha:1.0).cgColor
        memoTV.layer.borderWidth = 1.0
        memoTV.layer.cornerRadius = 5.0
        
        // プレースホルダー
        titleTF.attributedPlaceholder = NSAttributedString(string: "タイトルを記入",
                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        memoTV.placeHolder = "メモを記入"

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

        // 年月日初期値
        startDateTF.text = CommonMethod.dateFormatter(date: selectedDate, formattKind: Const.DateFormatt.yyyyMdW)
        endDateTF.text = CommonMethod.dateFormatter(date: selectedDate, formattKind: Const.DateFormatt.yyyyMdW)
        
        // 時刻初期値 0:00
        let calendar = Calendar(identifier: .gregorian)
        let tmp = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let date = calendar.date(from: tmp)
        startTimeTF.text = CommonMethod.dateFormatter(date: date!, formattKind: Const.DateFormatt.Hmm)
        endTimeTF.text = CommonMethod.dateFormatter(date: date!, formattKind: Const.DateFormatt.Hmm)
        
        // PickerView初期値
        let yearStr = CommonMethod.dateFormatter(date: selectedDate, formattKind: Const.DateFormatt.yyyy)
        let monthStr = CommonMethod.dateFormatter(date: selectedDate, formattKind: Const.DateFormatt.M)
        let dayStr = CommonMethod.dateFormatter(date: selectedDate, formattKind: Const.DateFormatt.d)
        let hourStr = CommonMethod.dateFormatter(date: date!, formattKind: Const.DateFormatt.H)
        let minutsStr = CommonMethod.dateFormatter(date: date!, formattKind: Const.DateFormatt.mm)
        datePV.selectRow(yearArray.firstIndex(of: yearStr)!, inComponent: 0, animated: true)
        datePV.selectRow(monthArray.firstIndex(of: monthStr)!, inComponent: 1, animated: true)
        datePV.selectRow(dayArray.firstIndex(of: dayStr)!, inComponent: 2, animated: true)
        timePV.selectRow(hourArray.firstIndex(of: hourStr)!, inComponent: 0, animated: true)
        timePV.selectRow(minutsArray.firstIndex(of: minutsStr)!, inComponent: 2, animated: true)

        // 新規作成
        if isNew {
            // 時刻非表示
            startTimeTF.isHidden = true
            endTimeTF.isHidden = true
            // アイコン初期値選択
            iconCd = Const.ScheduleIcon.iconCd.BIRTHDAY
            iconIV1.backgroundColor = ICON_SELECTED_COLOR
            // アイコンカラー初期値選択
            iconColorCd = Const.ScheduleIcon.colorCd.GRAY
            colorBtn1.setTitle("✓", for: .normal)
        } else {
            
        }
    }
    
    /**
     キーボード表示
     */
    @objc func keyboardWillShow(notification: NSNotification) {
        // キーボードの高さに合わせてViewのボトムを上に上げる
        if let keyboadSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let tabBarHeight = tabBarController?.tabBar.frame.size.height ?? 0
            contentsViewBottomConstraint.constant = keyboadSize.height + tabBarHeight
        }
    }
    
    /**
     キーボード非表示
     */
    @objc func keyboardWillHide() {
        // Viewのボトムをもとに戻す
        contentsViewBottomConstraint.constant = 0
    }

    /**
     キャンセルボタン押下
     */
    @IBAction func tapCancelBtn(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "編集途中の内容は破棄されます。\nよろしいですか？", preferredStyle: .alert)
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
    
    @IBAction func tapIconBtn1(_ sender: Any) {
        iconCd = Const.ScheduleIcon.iconCd.BIRTHDAY
        iconIV1.backgroundColor = ICON_SELECTED_COLOR
        iconIV2.backgroundColor = UIColor.clear
        iconIV3.backgroundColor = UIColor.clear
    }
    
    @IBAction func tapIconBtn2(_ sender: Any) {
        iconCd = Const.ScheduleIcon.iconCd.PRESENT
        iconIV1.backgroundColor = UIColor.clear
        iconIV2.backgroundColor = ICON_SELECTED_COLOR
        iconIV3.backgroundColor = UIColor.clear
    }
    @IBAction func tapIconBtn3(_ sender: Any) {
        iconCd = Const.ScheduleIcon.iconCd.RIBBON
        iconIV1.backgroundColor = UIColor.clear
        iconIV2.backgroundColor = UIColor.clear
        iconIV3.backgroundColor = ICON_SELECTED_COLOR
    }
    @IBAction func tapColorBtn1(_ sender: Any) {
        iconColorCd = Const.ScheduleIcon.colorCd.GRAY
        colorBtn1.setTitle("✓", for: .normal)
        colorBtn2.setTitle("", for: .normal)
        colorBtn3.setTitle("", for: .normal)
        iconIV1.image = UIImage(named: Const.ScheduleIcon()
            .getIconName(iconCd: Const.ScheduleIcon.iconCd.BIRTHDAY, colorCd: iconColorCd))
        iconIV2.image = UIImage(named: Const.ScheduleIcon()
            .getIconName(iconCd: Const.ScheduleIcon.iconCd.PRESENT, colorCd: iconColorCd))
        iconIV3.image = UIImage(named: Const.ScheduleIcon()
            .getIconName(iconCd: Const.ScheduleIcon.iconCd.RIBBON, colorCd: iconColorCd))
    }
    @IBAction func tapColorBtn2(_ sender: Any) {
        iconColorCd = Const.ScheduleIcon.colorCd.BLUE
        colorBtn1.setTitle("", for: .normal)
        colorBtn2.setTitle("✓", for: .normal)
        colorBtn3.setTitle("", for: .normal)
        iconIV1.image = UIImage(named: Const.ScheduleIcon()
            .getIconName(iconCd: Const.ScheduleIcon.iconCd.BIRTHDAY, colorCd: iconColorCd))
        iconIV2.image = UIImage(named: Const.ScheduleIcon()
            .getIconName(iconCd: Const.ScheduleIcon.iconCd.PRESENT, colorCd: iconColorCd))
        iconIV3.image = UIImage(named: Const.ScheduleIcon()
            .getIconName(iconCd: Const.ScheduleIcon.iconCd.RIBBON, colorCd: iconColorCd))
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
        } else {
            allDay = false
            // 時刻を表示
            startTimeTF.isHidden = false
            endTimeTF.isHidden = false
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
        timeStr = (startDateTF.text?.components(separatedBy: "(")[0])! + timeStr
        // dateに変換
        let date = CommonMethod.dateFormatter(str: timeStr, formattStr: "yyyy年M月d日H:mm")
        // endDateに格納
        endDate = date
    }

    /// cancel button
    @objc func tapEndTimeCancelBtn() {
        endTimeTF.endEditing(true)
    }

}
