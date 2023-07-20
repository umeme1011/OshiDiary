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
    @IBOutlet weak var listTV: UITableView!
    @IBOutlet weak var noMessageSV: UIStackView!
    
    var myUD: MyUserDefaults!
    var oshiRealm: Realm!
    var oshiId: Int!
    var diaryDic: Dictionary = Dictionary<String, [Diary]>()
    var keyArray: [String] = [String]()
    var diary: Diary!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTF.delegate = self
        listTV.delegate = self
        listTV.dataSource = self
        
        myUD = MyUserDefaults.init()
        oshiId = myUD.getOshiId()
        self.changeVisual()
        
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
     戻るボタン押下
     */
    @IBAction func tapBackBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func changeVisual() {
        // イメージカラー設定
        baseView.backgroundColor = Const.ImageColor().getImageColor(cd: myUD.getImageColorCd())
        // ランダムに背景画像を設定
        backgroundIV.image = CommonMethod.roadBackgroundImage(oshiId: myUD.getOshiId()).randomElement()
    }
    
    /**
     データ渡し
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 編集画面にデータを渡す
        if segue.identifier == "toDiaryEdit" {
            let vc: DiaryEditViewController = segue.destination as! DiaryEditViewController
            vc.diary = diary
            vc.isNew = false
            vc.selectedDate = diary.date
        }
    }
}

extension DiarySearchViewController: UITextFieldDelegate {
    /**
     キーボードEnter押下
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // diaryDic初期化
        diaryDic.removeAll()
        
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
        oshiRealm = CommonMethod.createOshiRealm(oshiId: oshiId)
        // 検索
        var predicates: [NSPredicate] = [NSPredicate]()
        for text in textArray {
            let predicate = NSPredicate(format: "\(Diary.Types.title.rawValue) CONTAINS[c] %@ OR \(Diary.Types.content.rawValue) CONTAINS[c] %@", text.trimmingCharacters(in: .whitespaces), text.trimmingCharacters(in: .whitespaces))
            predicates.append(predicate)
        }
        let diaries = oshiRealm.objects(Diary.self).filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
            .sorted(byKeyPath: Diary.Types.date.rawValue, ascending: false)

        // 結果を年月で分類しDicに格納
        if !diaries.isEmpty {
            var tmpYmString = ""
            var diaryArray: [Diary] = [Diary]()
            for diary in diaries {
                if tmpYmString == diary.ymString {
                    diaryArray.append(diary)
                } else {
                    if !diaryArray.isEmpty {
                        diaryDic[tmpYmString] = diaryArray
                        diaryArray.removeAll()
                    }
                    diaryArray.append(diary)
                }
                tmpYmString = diary.ymString
            }
            diaryDic[tmpYmString] = diaryArray
        }
        // キー（日付）配列
        keyArray = [String](diaryDic.keys)
        // キーをソート（年月降順）
        keyArray.sort { $0 > $1 }
        // TVリロード
        listTV.reloadData()
        
        if !diaries.isEmpty {
            // 日記なしメッセージ非表示
            noMessageSV.isHidden = true
        } else {
            // 日記なしメッセージ表示
            noMessageSV.isHidden = false
        }

        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
}

extension DiarySearchViewController: UITableViewDelegate, UITableViewDataSource {
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
        let ym: String = CommonMethod.dateFormatter(date: CommonMethod.dateFormatter(str: keyArray[section], formattStr: "yyyyMM")
                                                     , formattKind: Const.DateFormatt.yyyyM)
        label.text = ym

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
        return diaryDic[keyArray[section]]?.count ?? 0
    }

    /**
     セル内容
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:  "cell", for:indexPath as IndexPath)
            as! ListTableViewCell

        // キーをもとにDiaryを取得
        let diaryArray: [Diary] = diaryDic[keyArray[indexPath.section]]!
        
        if indexPath.row < diaryArray.count {
            let current = Calendar.current
            cell.dateLbl.text = String(current.component(.day, from: diaryArray[indexPath.row].date))
            cell.weekLbl.text = CommonMethod.weekFormatter(date: diaryArray[indexPath.row].date)
            cell.timeLbl.text = CommonMethod.dateFormatter(date: diaryArray[indexPath.row].date, formattKind: Const.DateFormatt.Hmm)
            cell.titleLbl.text = diaryArray[indexPath.row].title
            cell.contentLbl.text = diaryArray[indexPath.row].content
            cell.imageIV.image = CommonMethod.roadDiaryImage(oshiId: oshiId, diaryId: diaryArray[indexPath.row].id).first
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
        diary = diaryDic[keyArray[indexPath.section]]![indexPath.row]
        performSegue(withIdentifier: "toDiaryEdit", sender: nil)
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
                var diaryArray: [Diary] = self.diaryDic[self.keyArray[indexPath.section]]!

                // 日記画像ディレクトリ削除
                CommonMethod.removeDiaryImage(oshiId: self.oshiId, diaryId: diaryArray[indexPath.row].id)
                // DiaryTBL削除
                DiaryCalendarViewController().deleteDiary(oshiRealm: self.oshiRealm, diaryId: diaryArray[indexPath.row].id)
                
                // 削除したデータをDicからも削除
                diaryArray.remove(at: indexPath.row)
                self.diaryDic[self.keyArray[indexPath.section]] = diaryArray
                if diaryArray.isEmpty {
                    self.diaryDic.removeValue(forKey: self.keyArray[indexPath.section])
                    self.keyArray.remove(at: indexPath.section)
                }
                if self.diaryDic.isEmpty {
                    // 日記なしメッセージ表示
                    self.noMessageSV.isHidden = false
                }
                self.listTV.reloadData()
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
