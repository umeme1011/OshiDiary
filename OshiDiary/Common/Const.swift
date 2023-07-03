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

        class Setting {
            static let SETTING_DIR_NAME = "setting"
            static let BACKGROUND_IMAGE_DIR_NAME = "background_image"
            
            static let ICON_FILE_NAME = "icon.jpg"
            static let BACKGROUND_IMAGE_FILE_NAME = "background_image"  // 連番付与
        }
        
        class Realm {
            static let REALM_DIR_NAME = "realm"
            static let REALM_NAME = "oshi_id"    // ID付与
        }

    }
    
    class Limit {
        class Premium {
            static let BACKGROUND_IMAGE_COUNT = 10
        }
        class Normal {
            static let BACKGROUND_IMAGE_COUNT = 3
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
}
