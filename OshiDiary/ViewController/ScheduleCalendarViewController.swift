//
//  ScheduleCalendarViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/26.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic

class ScheduleCalendarViewController: UIViewController {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var listTV: UITableView!
    @IBOutlet weak var backgroundIV: UIImageView!
    
    var backgroundImageArray: [UIImage] = [UIImage]()
    var myUD: MyUserDefaults!
    var oshiId: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.delegate = self
        calendar.dataSource = self
        listTV.delegate = self
        listTV.dataSource = self
        
        myUD = MyUserDefaults.init()
        oshiId = myUD.getOshiId()
        
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
    }
    
    func changeVisual() {
        // ランダムに背景画像を設定
        backgroundIV.image = CommonMethod.roadBackgroundImage(oshiId: myUD.getOshiId()).randomElement()
    }
}

extension ScheduleCalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
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

extension ScheduleCalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:  "cell", for:indexPath as IndexPath)
        as! ListTableViewCell
        
        cell.dateLbl.text = "31"
        cell.weekLbl.text = "金"
        cell.titleLbl.text = "ああああああああああ"
        cell.timeLbl.text = "10:00 〜 21:00"
        cell.memoLbl.text = "めもめもめも"
        
        return cell
    }
}

