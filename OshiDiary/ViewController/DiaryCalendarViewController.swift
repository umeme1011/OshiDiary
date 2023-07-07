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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.delegate = self
        calendar.dataSource = self
        listTV.delegate = self
        listTV.dataSource = self
        
        myUD = MyUserDefaults.init()
        oshiId = myUD.getOshiId()
        oshiRealm = CommonMethod.createOshiRealm(oshiId: oshiId)
        
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
        
        // ランダムに背景画像を設定
        self.changeVisual()
        
        // 日記データ取得
        diaries = oshiRealm.objects(Diary.self)
            .sorted(byKeyPath: Diary.Types.date.rawValue, ascending: true)
        
    }
    
    /**
     画面再描画
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listTV.reloadData()
    }
    
    func changeVisual() {
        // ランダムに背景画像を設定
        backgroundIV.image = CommonMethod.roadBackgroundImage(oshiId: myUD.getOshiId()).randomElement()
    }
    
    // データ渡し
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 編集画面にデータを渡す
        if segue.identifier == "toDiaryEdit" {
            let vc: DiaryEditViewController = segue.destination as! DiaryEditViewController
            vc.diary = diary
            vc.isNew = false
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
}

extension DiaryCalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:  "cell", for:indexPath as IndexPath)
            as! ListTableViewCell
        
        let current = Calendar.current
        
        cell.dateLbl.text = String(current.component(.day, from: diaries[indexPath.row].date))
        cell.weekLbl.text = CommonMethod.weekFormatter(date: diaries[indexPath.row].date)
        cell.titleLbl.text = diaries[indexPath.row].title
        cell.contentLbl.text = diaries[indexPath.row].content
        cell.imageIV.image = CommonMethod.roadDiaryImage(oshiId: oshiId, diaryId: diaries[indexPath.row].id).first
        
        return cell
    }

    // セルがタップされた時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // タップしたセルを取得
        if let cell: UITableViewCell = listTV.cellForRow(at: indexPath) {
            // 選択状態を解除
            cell.isSelected = false
        }
        // 編集画面へ遷移
        diary = diaries[indexPath.row]
        performSegue(withIdentifier: "toDiaryEdit", sender: nil)
    }
    
    // 右から左へスワイプ
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
                // 日記画像ディレクトリ削除
                let oshiIdStr: String = String(self.oshiId)
                let diaryIdStr: String = String(self.diaries[indexPath.row].id)
                let dirName: String = Const.File.OSHI_DIR_NAME + oshiIdStr
                                    + "/" + Const.File.Diary.DIARY_DIR_NAME + diaryIdStr
                CommonMethod.removeFile(name: dirName)
                
                // DB物理削除
                if let diary: Diary = self.oshiRealm.objects(Diary.self)
                    .filter("\(Diary.Types.id.rawValue) = %@", self.diaries[indexPath.row].id).first {
                    
                    do {
                        try self.oshiRealm.write {
                            self.oshiRealm.delete(diary)
                        }
                    } catch {
                        print("削除失敗", error)
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
