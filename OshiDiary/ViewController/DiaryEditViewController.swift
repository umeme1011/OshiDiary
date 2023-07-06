//
//  DiaryNewViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/22.
//

import UIKit
import PhotosUI

class DiaryEditViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var textView: PlaceHolderTextView!
    @IBOutlet weak var contentsViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageCV: UICollectionView!
    
    var imageArray: [UIImage] = [UIImage]()
    var selectedNo: Int!
    
    var myUD: MyUserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        imageCV.delegate = self
        imageCV.dataSource = self
        
        myUD = MyUserDefaults.init()
        
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
        let newImageItem = UIBarButtonItem(image: UIImage(systemName: "photo"), style:.plain, target: self, action: #selector(tapImageBtn))
        let newSpacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let newCloseItem = UIBarButtonItem(image: UIImage(systemName: "arrowtriangle.down.fill"), style:.plain, target: self, action: #selector(tapCloseBtn))
        newToolbar.setItems([newImageItem, newSpacelItem, newCloseItem], animated: true)
        textView.inputAccessoryView = newToolbar
        
        // プレースホルダー
        titleTF.attributedPlaceholder = NSAttributedString(string: "タイトルを記入",
                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textView.placeHolder = "推しとの思い出をのこそう♡"
    }
    
    /**
     画像ボタン
     */
    @objc func tapImageBtn() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0 // 選択上限。0にすると無制限に。
        configuration.filter = .images // 取得できるメディアの種類。
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    /**
     キーボード閉じるボタン
     */
    @objc func tapCloseBtn() {
        textView.endEditing(true)
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
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCollectionViewCell

        if !imageArray.isEmpty {
            cell.imageIV.image = imageArray[indexPath.row]
            
            // 削除ボタン押下アクションセット
            cell.deleteBtn.tag = indexPath.row
            cell.deleteBtn.addTarget(self, action: #selector(tapDeleteBtn), for: .touchUpInside)

        }
        return cell
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
    
}

