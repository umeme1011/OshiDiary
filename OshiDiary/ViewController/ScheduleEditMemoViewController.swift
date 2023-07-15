//
//  ScheduleEditMemoViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/07/15.
//

import UIKit

class ScheduleEditMemoViewController: UIViewController {
    
    @IBOutlet var baseView: UIView!
    @IBOutlet weak var memoTV: PlaceHolderTextView!
    @IBOutlet weak var contentsViewBottomConstraint: NSLayoutConstraint!
    
    var myUD: MyUserDefaults!
    var memo: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        memoTV.delegate = self
        
        myUD = MyUserDefaults.init()
        
        // イメージカラー設定
        baseView.backgroundColor = Const.ImageColor().getImageColor(cd: myUD.getImageColorCd())

        // 枠線
        memoTV.layer.borderColor = UIColor(red:0.76, green:0.76, blue:0.76, alpha:1.0).cgColor
        memoTV.layer.borderWidth = 1.0
        memoTV.layer.cornerRadius = 5.0

        // プレースホルダー
        if memo.isEmpty {
            memoTV.placeHolder = "メモを記入"
        } else {
            // 初期値設定
            memoTV.text = memo
        }
        
        // キーボード開閉時アクション設定
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    /**
     決定ボタン押下
     */
    @IBAction func tapDoneBtn(_ sender: Any) {
        // 元画面のメモに値を設定
        let vc: ScheduleEditViewController = self.presentingViewController as! ScheduleEditViewController
        vc.memoTV.text = memoTV.text
        if !memoTV.text.isEmpty {
            // 元画面のプレースホルダーを消す
            vc.memoTV.placeHolder = ""
        }
        self.dismiss(animated: true)
    }
}

extension ScheduleEditMemoViewController: UITextViewDelegate {
}
