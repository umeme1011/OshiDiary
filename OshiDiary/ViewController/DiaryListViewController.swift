//
//  DiaryListViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/22.
//

import UIKit
import RealmSwift

class DiaryListViewController: UIViewController {
    
    @IBOutlet weak var listTV: UITableView!
    @IBOutlet weak var backgroundIV: UIImageView!
    @IBOutlet weak var noMessageSV: UIStackView!
    
    var backgroundImageArray: [UIImage] = [UIImage]()
    var myUD: MyUserDefaults!
    var oshiId: Int!
    var oshiRealm: Realm!
    var diaryDic: Dictionary = Dictionary<String, [Diary]>()
    var keyArray: [String] = [String]()
    var diary: Diary!
    var pageNumber = 1
    var pageSize = 10
    var diaries: Results<Diary>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTV.delegate = self
        listTV.dataSource = self
        
        myUD = MyUserDefaults.init()
        oshiId = myUD.getOshiId()
    }
    
    /**
     画面再描画
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.changeVisual()
    }

    /**
     画面表示生成
     */
    func changeVisual() {
        // diaryDic初期化
        diaryDic.removeAll()

        // oshiRealm生成
        oshiId = myUD.getOshiId()
        oshiRealm = CommonMethod.createOshiRealm(oshiId: oshiId)

        // 日記データ取得
        diaries = oshiRealm.objects(Diary.self)
            .sorted(byKeyPath: Diary.Types.date.rawValue, ascending: false)

        if !diaries.isEmpty {
            // 日記なしメッセージ非表示
            noMessageSV.isHidden = true
        } else {
            // 日記なしメッセージ表示
            noMessageSV.isHidden = false
        }

        // ページごとにデータ設定
        setDiaryDic()
        
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

extension DiaryListViewController: UITableViewDelegate, UITableViewDataSource {
    
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
     スクロール時
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // すべて表示されたら実施しない
        if diaries.count >= pageSize * pageNumber {
            let scrollPosY = scrollView.contentOffset.y //スクロール位置
            let maxOffsetY = scrollView.contentSize.height - scrollView.frame.size.height //スクロール領域の高さからスクロール画面の高さを引いた値
            let distanceToBottom = maxOffsetY - scrollPosY //スクロール領域下部までの距離

            //スクロール領域下部に近づいたら追加で記事を取得する
            if distanceToBottom < 200 {
                pageNumber += 1
                setDiaryDic()
            }
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
                
                // DB物理削除
                if let diary: Diary = self.oshiRealm.objects(Diary.self)
                    .filter("\(Diary.Types.id.rawValue) = %@", diaryArray[indexPath.row].id).first {
                    
                    do {
                        try self.oshiRealm.write {
                            self.oshiRealm.delete(diary)
                        }
                    } catch {
                        print("削除失敗", error)
                    }
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
                }
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

extension DiaryListViewController {
    
    /**
     ページごとにデータ設定
     */
    private func setDiaryDic() {
        
        // 次ページのデータを取得
        var diaryOffsetArray: [Diary] = [Diary]()
        for offset in (pageSize * (pageNumber - 1))..<(pageSize * pageNumber) {
            if offset < diaries.count {
                diaryOffsetArray.append(diaries[offset])
            }
        }
    
        // 年月ごとに分類しDictionaryに追加
        var tmpMonth = ""
        var diaryArray: [Diary] = [Diary]()
        for diary in diaryOffsetArray {
            if tmpMonth == diary.ymString {
                diaryArray.append(diary)
            } else {
                if !diaryArray.isEmpty {
                    if diaryDic[tmpMonth] != nil {
                        diaryDic[tmpMonth]! += diaryArray
                    } else {
                        diaryDic[tmpMonth] = diaryArray
                    }
                    diaryArray.removeAll()
                }
                diaryArray.append(diary)
            }
            tmpMonth = diary.ymString
        }
        if diaryDic[tmpMonth] != nil {
            diaryDic[tmpMonth]! += diaryArray
        } else {
            diaryDic[tmpMonth] = diaryArray
        }

        // キー（日付）配列
        keyArray = [String](diaryDic.keys)
        // キーをソート（年月降順）
        keyArray.sort { $0 > $1 }
        
        // listTVリロード
        listTV.reloadData()
    }
}
