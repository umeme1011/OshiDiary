//
//  Const.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/29.
//

import UIKit

class Const {
    
    class Realm {
        static let SCHEMA_VER = 1
    }
    
    class File {
        static let OSHI_DIR_NAME = "oshi_id" // ID付与
        static let DEFAULT_IMAGE_NAME = "kuma_default"
        static let COMMON_DIR_NAME = "common"

        class Setting {
            static let SETTING_DIR_NAME = "setting"
            static let BACKGROUND_IMAGE_DIR_NAME = "background_image"
            
            static let ICON_FILE_NAME = "icon.jpg"
            static let BACKGROUND_IMAGE_FILE_NAME = "background_image"  // 連番付与
        }
        
        class Realm {
            static let REALM_DIR_NAME = "realm"
            static let OSHI_REALM_NAME = "oshi_id"    // ID付与
            static let COMMON_REALM_NAME = "common.realm"
        }

        class Schedule {
            static let SCHEDULE_DIR_NAME = "schedule"
        }

        class Diary {
            static let DIARY_DIR_NAME = "diray_id"  // ID付与
            static let DIARY_IMAGE_FILE_NAME = "diray_id"    // ID、連番付与
        }
    }
    
    class Course {
        class Premium {
            static let BACKGROUND_IMAGE_LIMIT = 10
            static let DIARY_IMAGE_LIMIT = 10
        }
        class Normal {
            static let BACKGROUND_IMAGE_LIMIT = 3
            static let DIARY_IMAGE_LIMIT = 3
        }
    }
    
    class ImageColor {
        class imageColorCd {
            static let WHITE = 1
            static let MISTYROSE = 2
            static let LIGHTCYAN = 3
            static let LAVENDER = 4
        }
        
        func getImageColor(cd: Int) -> UIColor {
            var ret: UIColor!
            if cd == imageColorCd.WHITE {
                ret = UIColor.white
            }
            if cd == imageColorCd.MISTYROSE {
                ret = UIColor(red: 255/255, green: 228/255, blue: 225/255, alpha: 1)
            }
            if cd == imageColorCd.LIGHTCYAN {
                ret = UIColor(red: 224/255, green: 255/255, blue: 255/255, alpha: 1)
            }
            if cd == imageColorCd.LAVENDER {
                ret = UIColor(red: 230/255, green: 230/255, blue: 250/255, alpha: 1)
            }
            return ret
        }
    }
    
    class ScheduleIcon {
        class iconCd {
            static let BIRTHDAY = 1
        }
        class colorCd {
            static let GRAY = 1
        }
        func getIconName(iconCd: Int, colorCd: Int) -> String {
            switch iconCd {
            case Const.ScheduleIcon.iconCd.BIRTHDAY:
                switch colorCd {
                case Const.ScheduleIcon.colorCd.GRAY:
                    return "birthday_gray"
                default:
                    return ""
                }
            default:
                return ""
            }
        }
    }
    
    class ScreenName {
        static let SCHEDULE_CALENDAR = "ScheduleCalendar"
        static let SCHEDULE_LIST = "ScheduleList"
        static let DIALY_CALENDAR = "DiaryCalendar"
        static let DIALY_LIST = "DiaryList"
    }
    
    class Message {
        static let EDIT_BACK_CONFIRM_MSG = "編集途中の内容は破棄されます。\nよろしいですか？"
        static let DELTE_CONFIRM_MSG = "削除してもよろしいですか？"
    }
    
    class DateFormatt {
        static let yyyyMdWHmmss = 1
        static let yyyyMdW = 2
        static let yyyyMd = 3
        static let yyyyM = 4
        static let yyyy = 5
        static let M = 6
        static let d = 7
        static let Hmmss = 8
        static let Hmm = 9
        static let H = 10
        static let mm = 11
    }
    
    class Array {
        
        // 年配列
        func getYearArray() -> [String] {
            // 2000年〜2100年
            var ret: [String] = [String]()
            var year = 2000
            while year <= 2100 {
                ret.append(String(year) + "年")
                year += 1
            }
            return ret
        }
        // 月配列
        static let MONTH_ARRAY = ["1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月"]
        // 日配列
        static let DAY_ARRAY = ["1日","2日","3日","4日","5日","6日","7日","8日","9日","10日","11日","12日","13日","14日","15日","16日","17日","18日","19日","20日","21日","22日","23日","24日","25日","26日","27日","28日","29日","30日","31日"]
        // 時間配列
        static let HOUR_ARRAY = ["0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23"]
        // 分配列
        func getMinutsArray() -> [String] {
            // 00〜59分
            var ret: [String] = [String]()
            var minuts = 0
            while minuts <= 59 {
                ret.append(String(format: "%02d", minuts))
                minuts += 1
            }
            return ret
        }
    }
}
