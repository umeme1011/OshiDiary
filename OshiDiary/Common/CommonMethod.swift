//
//  CommonMethod.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/29.
//

import Foundation
import RealmSwift

class CommonMethod {
    
    /**
     Documentディレクトリパス取得
     */
    static func getDocPath() -> URL {
        let path =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print("Documentディレクトリパス：\(path)")
        return path
    }
    
    /**
     ファイルパス取得
     */
    static func getFilePath(name: String) -> URL {
        let path = getDocPath().appendingPathComponent(name)
        return path
    }
    
    /**
     ファイル存在確認
     */
    static func isFileExists(name: String) -> Bool {
        let fileManager = FileManager.default
        let docPath =  NSHomeDirectory() + "/Documents"
        let filePath = docPath + "/" + name
        if !fileManager.fileExists(atPath: filePath) {
            return false
        }else{
            return true
        }
    }
    
    /**
     ファイル削除
     ディレクトリ指定の場合はディレクトリを削除
     */
    static func removeFile(name: String) {
        let fileManager = FileManager.default
        let fullURL = getDocPath().appendingPathComponent(name)
        do {
            try fileManager.removeItem(at: fullURL)
        } catch {
            print("ファイル削除失敗")
            print(error.localizedDescription)
        }
    }
    
    /**
     Documentディレクトリ配下にディレクトリ作成
     */
    static func createDir(name: String) {
        if !isFileExists(name: name) {
            let fileManager = FileManager.default
            let docPath =  getDocPath()
            let dir = docPath.appendingPathComponent(name, conformingTo: .directory)
            do {
               try fileManager.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
           } catch {
               print("ディレクトリ作成失敗")
               print(error.localizedDescription)
           }
        }
    }
    
    /**
     画像ファイル保存
     */
    static func saveImageFile(image: UIImage, name: String) {
        
        // 画像ファイル保存
        guard image.jpegData(compressionQuality: 0.0) != nil else {
            return
        }
        let imageData = image.jpegData(compressionQuality: 0.0)
        
        do {
            try imageData!.write(to: getFilePath(name: name))
            print("画像保存成功")
        } catch {
            print("画像保存失敗", error)
        }
    }
    
    /**
     画像読込
     */
    static func roadImageFile(name: String, defaultName: String) -> UIImage {
        var image: UIImage!
        let path = getDocPath().appendingPathComponent(name).path
        if isFileExists(name: name) {
            image = UIImage(contentsOfFile: path)
        } else {
            print("画像なし")
            image = UIImage(named: defaultName)   // デフォルト画像
        }
        return image
    }
    
    /**
     背景画像読込
     */
    static func roadBackgroundImage(oshiId: Int) -> [UIImage] {
        var ret: [UIImage] = [UIImage]()
        let oshiIdStr: String = String(oshiId)
        
        let bacgroundFileName: String = Const.File.OSHI_DIR_NAME + oshiIdStr
                            + "/" + Const.File.Setting.SETTING_DIR_NAME
                            + "/" + Const.File.Setting.BACKGROUND_IMAGE_DIR_NAME
                            + "/" + Const.File.Setting.BACKGROUND_IMAGE_FILE_NAME
        var cnt = 1
        var image: UIImage!
        while cnt <= Const.Limit.Premium.BACKGROUND_IMAGE_COUNT {
            if CommonMethod.isFileExists(name: bacgroundFileName + String(cnt) + ".jpg") {
                image = CommonMethod.roadImageFile(name: bacgroundFileName + String(cnt) + ".jpg", defaultName: "")
                ret.append(image)
            }
            cnt += 1
        }

        return ret
    }
    
    /**
     Realm作成
     */
    static func createRealm(path: URL) -> Realm {
        let realm: Realm = try! Realm(fileURL: path)
        return realm
    }

    /**
     推しRealm作成
     */
    static func createOshiRealm(oshiId: Int) -> Realm {
        return createRealm(path: getOshiRealmPath(oshiId: oshiId))
    }

    /**
     推しRealmファイルパス取得
     */
    static func getOshiRealmPath(oshiId: Int) -> URL {
        let oshiIdStr: String = String(oshiId)
        // Realm用ディレクトリ作成
        createDir(name: Const.File.OSHI_DIR_NAME + oshiIdStr + "/" + Const.File.Realm.REALM_DIR_NAME)
        // パス
        let fileName: String = Const.File.OSHI_DIR_NAME + oshiIdStr
                    + "/" + Const.File.Realm.REALM_DIR_NAME
                    + "/" + Const.File.Realm.REALM_NAME + oshiIdStr + ".realm"
        let path = getDocPath().appendingPathComponent(fileName)
        return path
    }

}
