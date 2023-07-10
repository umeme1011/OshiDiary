//
//  DiarySearchViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/07/09.
//

import UIKit
import RealmSwift

class DiarySearchViewController: UIViewController {
    
    @IBOutlet var baseView: UIView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var backgroundIV: UIImageView!
    
    var myUD: MyUserDefaults!
    var oshiRealm: Realm!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchTF.delegate = self
        
        myUD = MyUserDefaults.init()

        self.changeVisual()
        
        // 枠線
        searchTF.layer.borderColor = UIColor(red:0.76, green:0.76, blue:0.76, alpha:1.0).cgColor
        searchTF.layer.borderWidth = 1.0;
        searchTF.layer.cornerRadius = 17.5;
        
        // プレースホルダー
        searchTF.attributedPlaceholder = NSAttributedString(string: "スペースでAND検索",
                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])

    }
    
    /**
     戻るボタン押下
     */
    @IBAction func tapBackBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func changeVisual() {
        // イメージカラー設定
        baseView.backgroundColor = Const.Color().getImageColor(cd: myUD.getImageColorCd())
        // ランダムに背景画像を設定
        backgroundIV.image = CommonMethod.roadBackgroundImage(oshiId: myUD.getOshiId()).randomElement()
    }
}

extension DiarySearchViewController: UITextFieldDelegate {
    /**
     キーボードEnter押下
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // 検索文字列を取得、空白で分割
        var text: String = textField.text ?? ""
        text = text.trimmingCharacters(in: .whitespaces)
        var textArray: [String] = text.components(separatedBy: "　")
        // 全角スペース、半角スペースどちらもOKにする
        for i in 0..<textArray.count {
            if textArray[i].contains(" ") {
                let array = textArray[i].components(separatedBy: " ")
                textArray.remove(at: i)
                textArray += array
            }
        }
        
        // oshiRealm生成
        oshiRealm = CommonMethod.createOshiRealm(oshiId: myUD.getOshiId())
        // 検索
        var predicates: [NSPredicate] = [NSPredicate]()
        for text in textArray {
            let predicate = NSPredicate(format: "\(Diary.Types.title.rawValue) CONTAINS[c] %@ OR \(Diary.Types.content.rawValue) CONTAINS[c] %@", text.trimmingCharacters(in: .whitespaces), text.trimmingCharacters(in: .whitespaces))
            predicates.append(predicate)
        }
        var result = oshiRealm.objects(Diary.self).filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates))

        // 2023/07/11　結果を年月でわけてDicに格納、リスト表示
        
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }

}
