//
//  DiaryNewViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/22.
//

import UIKit
import PhotosUI
import RealmSwift

class DiaryEditViewController: UIViewController {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var contentsViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageCV: UICollectionView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var timeTF: UITextField!
    @IBOutlet weak var editAndSaveBtn: UIButton!
    @IBOutlet weak var placeholderLbl: UILabel!
    @IBOutlet weak var contentTV: UITextView!
    
    var imageArray: [UIImage] = [UIImage]()
    var selectedNo: Int!
    var myUD: MyUserDefaults!
    var oshiId: Int!
    var oshiRealm: Realm!
    var diary: Diary!
    var isNew: Bool = true
    var isEdit: Bool = false
    var diaryId: Int!
    var selectedDate: Date = Date()
    var datePV: UIPickerView = UIPickerView()
    var timePV: UIPickerView = UIPickerView()

    // pickerView用
    var yearArray: [String] = [String]()
    var monthArray: [String] = [String]()
    var dayArray: [String] = [String]()
    var hourArray: [String] = [String]()
    var minutsArray: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentTV.delegate = self
        imageCV.delegate = self
        imageCV.dataSource = self
        datePV.delegate = self
        datePV.dataSource = self
        timePV.delegate = self
        timePV.dataSource = self
        
        myUD = MyUserDefaults.init()
        oshiId = myUD.getOshiId()
        oshiRealm = CommonMethod.createOshiRealm(oshiId: oshiId)
        
        // pickerView用配列作成
        yearArray = Const.Array().getYearArray()
        monthArray = Const.Array.MONTH_ARRAY
        dayArray = Const.Array.DAY_ARRAY
        hourArray = Const.Array.HOUR_ARRAY
        minutsArray = Const.Array().getMinutsArray()

        // イメージカラー設定
        baseView.backgroundColor = Const.ImageColor().getImageColor(cd: myUD.getImageColorCd())

        // キーボード開閉時アクション設定
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        // 枠線を消す
        dateTF.borderStyle = .none
        timeTF.borderStyle = .none

        //***********************
        // タイトル、内容用keyboad toolbar
        let newToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        let newSpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let newCloseItem = UIBarButtonItem(title: "閉じる", style:.plain, target: self, action: #selector(tapCloseBtn))
        newToolbar.setItems([newSpacelItem, newCloseItem], animated: true)
        titleTF.inputAccessoryView = newToolbar
        contentTV.inputAccessoryView = newToolbar
        
        //***********************
        // datePV toolbar
        let dateToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        let dateCancelItem = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(tapDateCancelBtn))
        let dateSpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let dateDoneItem = UIBarButtonItem(title: "決定", style: .plain, target: self, action: #selector(tapDateDoneBtn))
        dateToolbar.setItems([dateCancelItem, dateSpacelItem, dateDoneItem], animated: true)
        dateTF.inputView = datePV
        dateTF.inputAccessoryView = dateToolbar
        
        //***********************
        // timePV toolbar
        let timeToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        let timeCancelItem = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(tapTimeCancelBtn))
        let timeSpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let timeDoneItem = UIBarButtonItem(title: "決定", style: .plain, target: self, action: #selector(tapTimeDoneBtn))
        timeToolbar.setItems([timeCancelItem, timeSpacelItem, timeDoneItem], animated: true)
        timeTF.inputView = timePV
        timeTF.inputAccessoryView = timeToolbar

        // PickerView初期値
        let yearStr = CommonMethod.dateFormatter(date: selectedDate, formattKind: Const.DateFormatt.yyyy)
        let monthStr = CommonMethod.dateFormatter(date: selectedDate, formattKind: Const.DateFormatt.M)
        let dayStr = CommonMethod.dateFormatter(date: selectedDate, formattKind: Const.DateFormatt.d)
        let hourStr = CommonMethod.dateFormatter(date: selectedDate, formattKind: Const.DateFormatt.H)
        let minutsStr = CommonMethod.dateFormatter(date: selectedDate, formattKind: Const.DateFormatt.mm)
        datePV.selectRow(yearArray.firstIndex(of: yearStr)!, inComponent: 0, animated: true)
        datePV.selectRow(monthArray.firstIndex(of: monthStr)!, inComponent: 1, animated: true)
        datePV.selectRow(dayArray.firstIndex(of: dayStr)!, inComponent: 2, animated: true)
        timePV.selectRow(hourArray.firstIndex(of: hourStr)!, inComponent: 0, animated: true)
        timePV.selectRow(minutsArray.firstIndex(of: minutsStr)!, inComponent: 2, animated: true)
        
        // 日付初期値
        dateTF.text = CommonMethod.dateFormatter(date: selectedDate, formattKind: Const.DateFormatt.yyyyMd)
        // 時間初期値
        timeTF.text = CommonMethod.dateFormatter(date: selectedDate, formattKind: Const.DateFormatt.Hmm)

        // 新規作成
        if isNew {
            // プレースホルダー
            titleTF.attributedPlaceholder = NSAttributedString(string: "タイトルを記入",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            
            // DiaryID発行
            diaryId = 1
            if let diary: Diary = oshiRealm.objects(Diary.self)
                .sorted(byKeyPath: Diary.Types.id.rawValue, ascending: false).first {
                diaryId = diary.id + 1
            }
            // ゴミ箱非表示
            deleteBtn.isHidden = true
            // 編集フラグ
            isEdit = true
            // 保存ボタン画像にする
            editAndSaveBtn.setImage(UIImage(systemName: "checkmark"), for: .normal)
        
        // 既存データ編集
        } else {
            // 初期値設定
            titleTF.text = diary.title
            if titleTF.text?.count == 0 {
                // プレースホルダー
                titleTF.attributedPlaceholder = NSAttributedString(string: "タイトルを記入",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            }
            contentTV.text = diary.content
            if contentTV.text.count > 0 {
                placeholderLbl.isHidden = true
            } else {
                placeholderLbl.isHidden = false
            }
            
            // 初期表示は編集不可
            titleTF.isEnabled = false
            contentTV.isEditable = false
            contentTV.isSelectable = false
            dateTF.isEnabled = false
            timeTF.isEnabled = false
            
            // DiaryId設定
            diaryId = diary.id
            // 日記画像読込
            imageArray = CommonMethod.roadDiaryImage(oshiId: oshiId, diaryId: diaryId)
        }
    }
    
    /**
     キーボード閉じるボタン
     */
    @objc func tapCloseBtn() {
        titleTF.endEditing(true)
        contentTV.endEditing(true)
    }
    
    /**
     キーボード表示
     */
    @objc func keyboardWillShow(notification: NSNotification) {
        // キーボードの高さに合わせてViewのボトムを上に上げる
        if let keyboadSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let tabBarHeight = tabBarController?.tabBar.frame.size.height ?? 0
            contentsViewBottomConstraint.constant = -(keyboadSize.height - tabBarHeight)
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
     戻るボタン押下
     */
    @IBAction func tapBackBtn(_ sender: Any) {
        
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
    
    /**
     削除ボタン押下
     */
    @IBAction func tapDiaryDeleteBtn(_ sender: Any) {
        let alert = UIAlertController(title: "", message: Const.Message.DELTE_CONFIRM_MSG, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "いいえ", style: .default, handler: { (action) -> Void in
            // アラートを閉じる
            alert.dismiss(animated: true)
        })
        let ok = UIAlertAction(title: "はい", style: .default, handler: { (action) -> Void in
            // 日記画像ディレクトリ削除
            let oshiIdStr: String = String(self.oshiId)
            let diaryIdStr: String = String(self.diaryId)
            let dirName: String = Const.File.OSHI_DIR_NAME + oshiIdStr
                                + "/" + Const.File.Diary.DIARY_DIR_NAME + diaryIdStr
            CommonMethod.removeFile(name: dirName)
            
            // DB物理削除
            if let diary: Diary = self.oshiRealm.objects(Diary.self)
                .filter("\(Diary.Types.id.rawValue) = %@", self.diaryId!).first {
                
                do {
                    try self.oshiRealm.write {
                        self.oshiRealm.delete(diary)
                    }
                } catch {
                    print("削除失敗", error)
                }
            }
            // 画面を閉じる
            self.dismiss(animated: true)
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     編集、保存ボタン押下
     */
    @IBAction func tapSaveBtn(_ sender: Any) {
        
        // 編集ボタン押下
        if !isEdit {
            // ボタン画像をチェックマークに変更
            editAndSaveBtn.setImage(UIImage(systemName: "checkmark"), for: .normal)
            // 編集可能にする
            titleTF.isEnabled = true
            contentTV.isEditable = true
            contentTV.isSelectable = true
            contentTV.isScrollEnabled = true
            dateTF.isEnabled = true
            timeTF.isEnabled = true
            // 編集フラグ
            isEdit = true
            // 画像ボタン表示
            imageCV.reloadData()
        // 保存ボタン押下
        } else {
            let oshiIdStr: String = String(oshiId)
            let diaryIdStr: String = String(diaryId)
            // 日記用のディレクトリ削除、作成
            let dirName: String = Const.File.OSHI_DIR_NAME + oshiIdStr
                                + "/" + Const.File.Diary.DIARY_DIR_NAME + diaryIdStr
            CommonMethod.removeFile(name: dirName)
            CommonMethod.createDir(name: dirName)
            
            // 日記画像保存
            var cnt = 0
            for image in imageArray {
                cnt += 1
                let cntStr: String = String(cnt)
                let fileName: String = Const.File.Diary.DIARY_IMAGE_FILE_NAME
                            + diaryIdStr + "_" + cntStr + ".jpg"
                CommonMethod.saveImageFile(image: image, name: dirName + "/" + fileName)
            }
            
            // 日時をフォーマット
            let dateString = CommonMethod.dateFormatter(date: selectedDate, formattKind: Const.DateFormatt.yyyyMdW)
            let ymString = CommonMethod.dateFormatter(date: selectedDate, formattKind: Const.DateFormatt.yyyyM)
            
            // データがすでに存在していたら更新
            if let diary: Diary = oshiRealm.objects(Diary.self)
                .filter("\(Diary.Types.id.rawValue) = %@", diaryId!).first {
                try! oshiRealm.write {
                    diary.date = selectedDate
                    diary.dateString = dateString
                    diary.ymString = ymString
                    diary.title = titleTF.text ?? ""
                    diary.content = contentTV.text
                    diary.updateDate = Date()
                }

            // 存在しない場合は登録
            } else {
                let newDiary = Diary()
                try! oshiRealm.write {
                    newDiary.id = diaryId
                    newDiary.date = selectedDate
                    newDiary.dateString = dateString
                    newDiary.ymString = ymString
                    newDiary.title = titleTF.text ?? ""
                    newDiary.content = contentTV.text

                    oshiRealm.add(newDiary)
                }
            }
            self.dismiss(animated: true)
        }
    }
    
}

extension DiaryEditViewController: UITextViewDelegate {
    /**
     変更あったとき
     */
    func textViewDidChange(_ textView: UITextView) {
        if contentTV.text.count > 0 {
            placeholderLbl.isHidden = true
        } else {
            placeholderLbl.isHidden = false
        }
    }
}

extension DiaryEditViewController: UITextFieldDelegate {
}

extension DiaryEditViewController: PHPickerViewControllerDelegate {
    /**
     画像複数選択
     */
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        for result in results {
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                    guard image is UIImage else {
                        return
                    }
                    self?.imageArray.append(image as! UIImage)
                    DispatchQueue.main.async {
                        if !(self?.imageArray.isEmpty)! {
                            self?.imageCV.reloadData()
                        }
                    }
                }
            }
        }
    }
}

/**
 画像一覧
 */
extension DiaryEditViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (imageArray.count == myUD.getDiaryImageLimit()) || !isEdit {
            // 上限に達している場合、参照の場合は写真ボタン表示しない
            return imageArray.count

        } else {
            return imageArray.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == imageArray.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addCell", for: indexPath) as! ImageAddCollectionViewCell
            
            // 追加ボタン押下アクションセット
            cell.addBtn.tag = indexPath.row
            cell.addBtn.addTarget(self, action: #selector(tapImageBtn), for: .touchUpInside)

            return cell

        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCollectionViewCell

            if !imageArray.isEmpty {
                cell.imageIV.image = imageArray[indexPath.row]
                
                // 参照の場合は削除ボタン非表示
                if !isEdit {
                    cell.deleteBtn.isHidden = true
                } else {
                    cell.deleteBtn.isHidden = false
                    // 削除ボタン押下アクションセット
                    cell.deleteBtn.tag = indexPath.row
                    cell.deleteBtn.addTarget(self, action: #selector(tapDeleteBtn), for: .touchUpInside)
                }
            }
            return cell
        }
        
    }
    
    /**
     cell選択
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedNo = indexPath.row
        performSegue(withIdentifier: "toImageDetail",sender: nil)
    }

    /**
     値渡し
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toImageDetail") {
            let vc: ImageDetailViewController = (segue.destination as? ImageDetailViewController)!
            vc.imageArray = imageArray
            vc.selectedNo = selectedNo
        }
    }
    
    /**
     削除ボタン押下
     */
    @objc private func tapDeleteBtn(_ sender:UIButton) {
        let row: Int = sender.tag
        imageArray.remove(at: row)
        imageCV.reloadData()
    }
    
    /**
     画像ボタン
     */
    @objc private func tapImageBtn() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = myUD.getDiaryImageLimit() - imageArray.count // 選択上限
        configuration.filter = .images // 取得できるメディアの種類
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
}

extension DiaryEditViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    @objc func tapDateDoneBtn() {
        dateTF.endEditing(true)
        var dateStr = yearArray[datePV.selectedRow(inComponent: 0)]
                + monthArray[datePV.selectedRow(inComponent: 1)]
                + dayArray[datePV.selectedRow(inComponent: 2)]
        // TFに設定
        dateTF.text = dateStr
        // 時間と結合
        dateStr += timeTF.text ?? ""
        selectedDate = CommonMethod.dateFormatter(str: dateStr, formattStr: "yyyy年M月d日H:mm")
    }

    /// cancel button
    @objc func tapDateCancelBtn() {
        dateTF.endEditing(true)
    }

    /// Done button
    @objc func tapTimeDoneBtn() {
        timeTF.endEditing(true)
        var timeStr = hourArray[timePV.selectedRow(inComponent: 0)] + ":" + minutsArray[timePV.selectedRow(inComponent: 2)]
        // TFに設定
        timeTF.text = timeStr
        // 年月日と結合
        timeStr = (dateTF.text ?? "") + timeStr
        selectedDate = CommonMethod.dateFormatter(str: timeStr, formattStr: "yyyy年M月d日H:mm")
    }

    /// cancel button
    @objc func tapTimeCancelBtn() {
        timeTF.endEditing(true)
    }
}
