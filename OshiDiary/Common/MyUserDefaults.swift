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

    // 背景画像数上限
    func setBackgroundImageCount(id : Int) {
        ud.set(id, forKey: "backgroundImageCount")
    }
    
    func getBackgroundImageCount() -> Int {
        return ud.object(forKey: "backgroundImageCount") as? Int ?? Const.Limit.Normal.BACKGROUND_IMAGE_COUNT
    }
    
    func setImageColorCd(cd : Int) {
        ud.set(cd, forKey: "imageColorCd")
    }
    
    func getImageColorCd() -> Int {
        return ud.object(forKey: "imageColorCd") as? Int ?? Const.Limit.Normal.BACKGROUND_IMAGE_COUNT
    }


}
