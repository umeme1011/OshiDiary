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
    
    class Color {
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
        static let YMDWHMS = 1
        static let YMDW = 2
        static let HMS = 3
        static let HM = 4
        static let YM = 5
    }
}
