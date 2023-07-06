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
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var contentTV: PlaceHolderTextView!
    @IBOutlet weak var contentsViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageCV: UICollectionView!
    
    var imageArray: [UIImage] = [UIImage]()
    var selectedNo: Int!
    var myUD: MyUserDefaults!
    var oshiId: Int!
    var oshiRealm: Realm!
    var diary: Diary!
    var isNew: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentTV.delegate = self
        imageCV.delegate = self
        imageCV.dataSource = self
        
        myUD = MyUserDefaults.init()
        oshiId = myUD.getOshiId()
        oshiRealm = CommonMethod.createOshiRealm(oshiId: oshiId)
        
        // イメージカラー設定
        baseView.backgroundColor = Const.Color().getImageColor(cd: myUD.getImageColorCd())

        // キーボード開閉時アクション設定
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        
        // textView枠線
//        textView.layer.borderColor = UIColor(red:0.76, green:0.76, blue:0.76, alpha:1.0).cgColor
//        textView.layer.borderWidth = 1.0;
//        textView.layer.cornerRadius = 5.0;

        // keyboad toolbar
        let newToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
//        let newImageItem = UIBarButtonItem(image: UIImage(systemName: "photo"), style:.plain, target: self, action: #selector(tapImageBtn))
        let newSpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let newCloseItem = UIBarButtonItem(image: UIImage(systemName: "arrowtriangle.down.fill"), style:.plain, target: self, action: #selector(tapCloseBtn))
//        newToolbar.setItems([newImageItem, newSpacelItem, newCloseItem], animated: true)
        newToolbar.setItems([newSpacelItem, newCloseItem], animated: true)

        titleTF.inputAccessoryView = newToolbar
        contentTV.inputAccessoryView = newToolbar
        
        // 新規作成
        if isNew {
            // プレースホルダー
            titleTF.attributedPlaceholder = NSAttributedString(string: "タイトルを記入",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            contentTV.placeHolder = "推しとの思い出をのこそう♡"
        
        // 既存データ編集
        } else {
            dateLbl.text = CommonMethod.dateFormatter(date: diary.date)
            titleTF.text = diary.title
            contentTV.text = diary.content
        }
        
    }
    
    /**
     画像ボタン（未使用）
     */
//    @objc func tapImageBtn() {
//        var configuration = PHPickerConfiguration()
//        configuration.selectionLimit = myUD.getDiaryImageLimit() - imageArray.count // 選択上限
//        configuration.filter = .images // 取得できるメディアの種類。
//        let picker = PHPickerViewController(configuration: configuration)
//        picker.delegate = self
//        present(picker, animated: true)
//    }

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
     キャンセルボタン押下
     */
    @IBAction func tapCancelBtn(_ sender: Any) {
        let alert = UIAlertController(title: "編集キャンセル", message: "編集途中の内容は破棄されます。\nキャンセルしますか？", preferredStyle: .alert)
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
    
    /**
     投稿ボタン押下
     */
    @IBAction func tapPostBtn(_ sender: Any) {
        
        // 現在日時取得
        let now = Date()
        
        // データがすでに存在していたら更新
        if let diary: Diary = oshiRealm.objects(Diary.self)
            .filter("\(Diary.Types.id.rawValue) = %@", self.diary.id).first {
            try! oshiRealm.write {
                diary.title = titleTF.text ?? ""
                diary.content = contentTV.text
                diary.updateDate = now
            }

        // 存在しない場合は登録
        } else {
            var diaryId = 1
            // DiaryID発行
            if let diary: Diary = oshiRealm.objects(Diary.self)
                .sorted(byKeyPath: Diary.Types.id.rawValue, ascending: false).first {
                diaryId = diary.id + 1
            }

            let newDiary = Diary()
            try! oshiRealm.write {
                newDiary.id = diaryId
                newDiary.date = now
                newDiary.title = titleTF.text ?? ""
                newDiary.content = contentTV.text

                oshiRealm.add(newDiary)
            }
        }
        self.dismiss(animated: true)
    }
}

extension DiaryEditViewController: UITextViewDelegate {
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
        if imageArray.count == myUD.getDiaryImageLimit() {
            // 上限に達している場合は写真ボタン表示しない
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
                
                // 削除ボタン押下アクションセット
                cell.deleteBtn.tag = indexPath.row
                cell.deleteBtn.addTarget(self, action: #selector(tapDeleteBtn), for: .touchUpInside)

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
        configuration.filter = .images // 取得できるメディアの種類。
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    
}

