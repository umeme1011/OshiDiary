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
    
    var myUD: MyUserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoTV.delegate = self
        
        myUD = MyUserDefaults.init()
        
        // イメージカラー設定
        baseView.backgroundColor = Const.ImageColor().getImageColor(cd: myUD.getImageColorCd())

        // キーボード開閉アクション設定
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // 枠線
        titleTF.layer.borderColor  = UIColor(red:0.76, green:0.76, blue:0.76, alpha:1.0).cgColor
        titleTF.layer.borderWidth = 1.0
        titleTF.layer.cornerRadius = 5.0
        startDateTF.layer.borderWidth = 0
        startTimeTF.layer.borderWidth = 0
        endDateTF.layer.borderWidth = 0
        endTimeTF.layer.borderWidth = 0
        repeatTF.layer.borderWidth = 0
        memoTV.layer.borderColor = UIColor(red:0.76, green:0.76, blue:0.76, alpha:1.0).cgColor
        memoTV.layer.borderWidth = 1.0
        memoTV.layer.cornerRadius = 5.0
        
        // プレースホルダー
        titleTF.attributedPlaceholder = NSAttributedString(string: "タイトルを記入",
                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        memoTV.placeHolder = "メモを記入"


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
}
