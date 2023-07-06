//
//  MyUserDefaults.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/30.
//

import Foundation

class MyUserDefaults {
    let ud = UserDefaults.standard
    
    init() {
        
    }

    // 推しID
    func setOshiId(id : Int) {
        ud.set(id, forKey: "oshiId")
    }
    
    func getOshiId() -> Int {
        return ud.object(forKey: "oshiId") as? Int ?? 1
    }

    // 初回フラグ
    func setFirstFlg(flg : Bool) {
        ud.set(flg, forKey: "firstFlg")
    }
    
    func getFirstFlg() -> Bool {
        return ud.object(forKey: "firstFlg") as? Bool ?? true
    }

    // 背景画像数上限
    func setBackgroundImageCount(id : Int) {
        ud.set(id, forKey: "backgroundImageCount")
    }
    
    func getBackgroundImageCount() -> Int {
        return ud.object(forKey: "backgroundImageCount") as? Int ?? Const.Limit.Normal.BACKGROUND_IMAGE_COUNT
    }
    
    // イメージカラーCD
    func setImageColorCd(cd : Int) {
        ud.set(cd, forKey: "imageColorCd")
    }
    
    func getImageColorCd() -> Int {
        return ud.object(forKey: "imageColorCd") as? Int ?? Const.Color.imageColorCd.WHITE
    }

    // 最終表示画面
    func setLastShowScreen(screen : String) {
        ud.set(screen, forKey: "lastShowScreen")
    }
    
    func getLastShowScreen() -> String {
        return ud.object(forKey: "lastShowScreen") as? String ?? Const.ScreenName.SCHEDULE_CALENDAR
    }

}
