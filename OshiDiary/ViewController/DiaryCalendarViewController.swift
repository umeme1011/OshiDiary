//
//  DiaryCalendarViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/22.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic
import RealmSwift

class DiaryCalendarViewController: UIViewController {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var listTV: UITableView!
    @IBOutlet weak var backgroundIV: UIImageView!
    
    var backgroundImageArray: [UIImage] = [UIImage]()
    var myUD: MyUserDefaults!
    var oshiId: Int!
    var oshiRealm: Realm!
    var diaries: Results<Diary>!
    var diary: Diary!
    var diaryDic: Dictionary = Dictionary<String, [Diary]>()
    var keyArray: [String] = [String]()
    var selectedDate: Date!
    var currentPage: Date!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.delegate = self
        calendar.dataSource = self
        listTV.delegate = self
        listTV.dataSource = self
        
        myUD = MyUserDefaults.init()
        
        // calendarの曜日部分を日本語表記に変更
        calendar.calendarWeekdayView.weekdayLabels[0].text = "日"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "月"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "火"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "水"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "木"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "金"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "土"
        
        calendar.calendarWeekdayView.weekdayLabels[0].font = UIFont.boldSystemFont(ofSize: 16)
        calendar.calendarWeekdayView.weekdayLabels[1].font = UIFont.boldSystemFont(ofSize: 16)
        calendar.calendarWeekdayView.weekdayLabels[2].font = UIFont.boldSystemFont(ofSize: 16)
        calendar.calendarWeekdayView.weekdayLabels[3].font = UIFont.boldSystemFont(ofSize: 16)
        calendar.calendarWeekdayView.weekdayLabels[4].font = UIFont.boldSystemFont(ofSize: 16)
        calendar.calendarWeekdayView.weekdayLabels[5].font = UIFont.boldSystemFont(ofSize: 16)
        calendar.calendarWeekdayView.weekdayLabels[6].font = UIFont.boldSystemFont(ofSize: 16)
        
        // calendarの曜日部分の色を変更
        calendar.calendarWeekdayView.weekdayLabels[0].textColor = .systemRed
        calendar.calendarWeekdayView.weekdayLabels[6].textColor = .systemBlue
        
        // カレンダー表示月を格納
        currentPage = calendar.currentPage
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
        
        // 表示月のyyyy/MMを取得
        let ymString: String = CommonMethod.dateFormatter(date: currentPage, formattKind: Const.DateFormatt.YM)
        
        // 日記データ取得
        diaries = oshiRealm.objects(Diary.self)
            .filter("\(Diary.Types.ymString.rawValue) = %@", ymString)
            .sorted(byKeyPath: Diary.Types.date.rawValue, ascending: true)
        
        // 日付ごとに分類しDictionaryに格納
        if !diaries.isEmpty {
            var tmpDate = ""
            var diaryArray: [Diary] = [Diary]()
            for diary in diaries {
                if tmpDate == diary.dateString {
                    diaryArray.append(diary)
                } else {
                    if !diaryArray.isEmpty {
                        diaryDic[tmpDate] = diaryArray
                        diaryArray.removeAll()
                    }
                    diaryArray.append(diary)
                }
                tmpDate = diary.dateString
            }
            diaryDic[tmpDate] = diaryArray
        }
        // キー（日付）配列
        keyArray = [String](diaryDic.keys)
        // キーをソート
        keyArray.sort()

        // ランダムに背景画像を設定
        backgroundIV.image = CommonMethod.roadBackgroundImage(oshiId: myUD.getOshiId()).randomElement()
        // listTVリロード
        listTV.reloadData()
        // カレンダーリロード
        calendar.reloadData()
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
            vc.selectedDate = Date()
        }
    }

}

extension DiaryCalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    /**
     土日や祝日の日の文字色を変える
     */
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        //祝日判定をする（祝日は赤色で表示する）
        if judgeHoliday(date){
            return UIColor.red
        }
        //土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
        let weekday = getWeekIdx(date)
        if weekday == 1 {   //日曜日
            return UIColor.red
        }
        else if weekday == 7 {  //土曜日
            return UIColor.blue
        }
        return nil
    }
    
    /**
     祝日判定を行い結果を返すメソッド(True:祝日)
     */
    func judgeHoliday(_ date : Date) -> Bool {
        //祝日判定用のカレンダークラスのインスタンス
        let tmpCalendar = Calendar(identifier: .gregorian)
        // 祝日判定を行う日にちの年、月、日を取得
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        
        // CalculateCalendarLogic()：祝日判定のインスタンスの生成
        let holiday = CalculateCalendarLogic()
        
        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }
    
    /**
     date型 -> 年月日をIntで取得
     */
    func getDay(_ date:Date) -> (Int,Int,Int){
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year,month,day)
    }
    
    /**
     曜日判定(日曜日:1 〜 土曜日:7)
     */
    func getWeekIdx(_ date: Date) -> Int{
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }

    /**
     イベントある日に点を付ける
     */
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int{
        var ret: Int = 0
        
        // 登録日付と比較するために日付を年月日曜日にフォーマット
        let dateString: String = CommonMethod.dateFormatter(date: date, formattKind: Const.DateFormatt.YMDW)
        
        for diary in diaries {
            if diary.dateString == dateString {
                ret += 1
            }
        }
        return ret
    }
    
    /**
     セルをタップ
     */
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 選択した日付
        selectedDate = date
        // リストをスクロール
        let dateStr = CommonMethod.dateFormatter(date: date, formattKind: Const.DateFormatt.YMDW)
        scroll(dateStr: dateStr)
    }
    
    /**
     月を変更
     */
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        // 表示月を格納
        currentPage = calendar.currentPage
        // 画面表示更新
        self.changeVisual()
    }
    
}

extension DiaryCalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        
        let cnt = diaryDic[keyArray[section]]?.count
        label.text = "\(keyArray[section])  \(cnt ?? 0)件"

        // Viewデザイン
        let screenWidth:CGFloat = listTV.frame.size.width
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 0.0
        view.frame = CGRect(x:0, y:0, width:screenWidth, height:25)
        view.backgroundColor = Const.Color().getImageColor(cd: myUD.getImageColorCd())
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
            cell.timeLbl.text = CommonMethod.dateFormatter(date: diaryArray[indexPath.row].date, formattKind: Const.DateFormatt.HM)
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
                let oshiIdStr: String = String(self.oshiId)
                let diaryIdStr: String = String(diaryArray[indexPath.row].id)
                let dirName: String = Const.File.OSHI_DIR_NAME + oshiIdStr
                                    + "/" + Const.File.Diary.DIARY_DIR_NAME + diaryIdStr
                CommonMethod.removeFile(name: dirName)
                
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
                    self.listTV.reloadData()
                    self.calendar.reloadData()
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
    
    /**
     指定の日付までスクロールする
     */
    private func scroll(dateStr: String) {
        if let index = keyArray.firstIndex(of: dateStr) {
            let indexPath = IndexPath(row: 0, section: index)
            listTV.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}
