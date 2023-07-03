//
//  SettingViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/28.
//

import UIKit
import PhotosUI
import RealmSwift

class SettingViewController: UIViewController {
    
    @IBOutlet weak var baseView: UIView!
    
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var imageCV: UICollectionView!
    @IBOutlet weak var backgroundIV: UIImageView!
    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var imageColorBtn1: UIButton!
    @IBOutlet weak var imageColorBtn2: UIButton!
    @IBOutlet weak var imageColorBtn3: UIButton!
    @IBOutlet weak var imageColorBtn4: UIButton!
    
    var tapIconBtn: Bool!
    var tapImageAddBtn: Bool!
    var imageArray: [UIImage] = [UIImage]()
    var myUD: MyUserDefaults!
    var oshiId: String!
    var oshiRealm: Realm!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCV.delegate = self
        imageCV.dataSource = self
        
        myUD = MyUserDefaults.init()
        oshiId = String(myUD.getOshiId())
        
        // Realm
        oshiRealm = CommonMethod.createOshiRealm()
        
        // イメージカラー設定
        baseView.backgroundColor = Const.Color().getImageColor(cd: myUD.getImageColorCd())
        
        if let setting: Setting = oshiRealm.objects(Setting.self)
            .filter("\(Setting.Types.id.rawValue) = %@", myUD.getOshiId()).first {
            // 名前を設定
            nameTF.text = setting.name
            // イメージカラー
            switch setting.imageColorCd {
            case Const.Color.imageColorCd.WHITE:
                imageColorBtn1.setTitle("✓", for: .normal)
            case Const.Color.imageColorCd.MISTYROSE:
                imageColorBtn2.setTitle("✓", for: .normal)
            case Const.Color.imageColorCd.LIGHTCYAN:
                imageColorBtn3.setTitle("✓", for: .normal)
            case Const.Color.imageColorCd.LAVENDER:
                imageColorBtn4.setTitle("✓", for: .normal)
            default:
                imageColorBtn1.setTitle("✓", for: .normal)
            }
        } else {
            // プレースホルダー
            nameTF.attributedPlaceholder = NSAttributedString(string: "名前を記入",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            // イメージカラー白を選択
            imageColorBtn1.setTitle("✓", for: .normal)
        }
        
        // アイコン画像読込
        let iconFileName = Const.File.OSHI_DIR_NAME + oshiId
                        + "/" + Const.File.Setting.SETTING_DIR_NAME
                        + "/" + Const.File.Setting.ICON_FILE_NAME
        iconIV.image = CommonMethod.roadImageFile(name: iconFileName, defaultName: Const.File.DEFAULT_IMAGE_NAME)
        
        // 背景画像読込
        let bacgroundFileName = Const.File.OSHI_DIR_NAME + oshiId
                            + "/" + Const.File.Setting.SETTING_DIR_NAME
                            + "/" + Const.File.Setting.BACKGROUND_IMAGE_DIR_NAME
                            + "/" + Const.File.Setting.BACKGROUND_IMAGE_FILE_NAME
        var cnt = 1
        var image: UIImage!
        while cnt <= Const.Limit.Premium.BACKGROUND_IMAGE_COUNT {
            if CommonMethod.isFileExists(name: bacgroundFileName + String(cnt) + ".jpg") {
                image = CommonMethod.roadImageFile(name: bacgroundFileName + String(cnt) + ".jpg", defaultName: "")
                imageArray.append(image)
            }
            cnt += 1
        }
    }

    /**
     キャンセルボタン押下
     */
    @IBAction func tapCancelBtn(_ sender: Any) {
        let alert = UIAlertController(title: "編集キャンセル", message: "編集途中の内容は破棄されます。\nキャンセルしますか？", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "いいえ", style: .default, handler: { (action) -> Void in
            // アラートを閉じる
            alert.dismiss(animated: true)
        })
        let ok = UIAlertAction(title: "はい", style: .default, handler: { (action) -> Void in
            // 画面を閉じる
            self.dismiss(animated: true)
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    /**
     保存ボタン押下
     */
    @IBAction func tapSaveBtn(_ sender: Any) {
        
        // 設定用のディレクトリ作成
        CommonMethod.createDir(name: Const.File.OSHI_DIR_NAME + oshiId
                               + "/" + Const.File.Setting.SETTING_DIR_NAME)
        
        // アイコン画像保存
        CommonMethod.saveImageFile(image: iconIV.image!
                                   , name: Const.File.OSHI_DIR_NAME + oshiId
                                   + "/" + Const.File.Setting.SETTING_DIR_NAME
                                   + "/" + Const.File.Setting.ICON_FILE_NAME)
        
        // 背景画像ディレクトリ削除、作成
        let dirName = Const.File.OSHI_DIR_NAME + oshiId
                    + "/" + Const.File.Setting.SETTING_DIR_NAME
                    + "/" + Const.File.Setting.BACKGROUND_IMAGE_DIR_NAME
        CommonMethod.removeFile(name: dirName)
        CommonMethod.createDir(name: dirName)
        
        // 背景画像保存
        var cnt = 0
        for image in imageArray {
            cnt += 1
            CommonMethod.saveImageFile(image: image, name: dirName
                                       + "/" + Const.File.Setting.BACKGROUND_IMAGE_FILE_NAME + String(cnt) + ".jpg")
        }
        
        // Realm
        // データがすでに存在していたら更新
        if let setting: Setting = oshiRealm.objects(Setting.self)
            .filter("\(Setting.Types.id.rawValue) = %@", myUD.getOshiId()).first {
            try! oshiRealm.write {
                setting.name = nameTF.text
                setting.imageColorCd = myUD.getImageColorCd()
                setting.updateDate = Date()
            }

        // 存在しない場合は登録
        } else {
            var id: Int = 1
            if let setting: Setting = oshiRealm.objects(Setting.self)
                .sorted(byKeyPath: Setting.Types.id.rawValue, ascending: false).first {
                id = setting.id + 1
            }
            let newSetting = Setting()
            try! oshiRealm.write {
                newSetting.id = id
                newSetting.name = nameTF.text
                newSetting.imageColorCd = myUD.getImageColorCd()
                oshiRealm.add(newSetting)
            }
            // 推しIDをUDに設定
            myUD.setOshiId(id: id)
        }
        
        // 設定画面を閉じる
        dismiss(animated: true)
    }
    
    /**
     アイコンボタン押下
     */
    @IBAction func tapIconBtn(_ sender: Any) {
        tapIconBtn = true
        
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1 // 選択上限。0にすると無制限に。
        configuration.filter = .images // 取得できるメディアの種類。
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)

    }
    /**
     イメージカラーボタン1押下
     */
    @IBAction func tapImageColorBtn1(_ sender: Any) {
        imageColorBtn1.setTitle("✓", for: .normal)
        imageColorBtn2.setTitle("　", for: .normal)
        imageColorBtn3.setTitle("　", for: .normal)
        imageColorBtn4.setTitle("　", for: .normal)
        myUD.setImageColorCd(cd: Const.Color.imageColorCd.WHITE)
        baseView.backgroundColor = UIColor.white
    }
    /**
     イメージカラーボタン2押下
     */
    @IBAction func tapImageColorBtn2(_ sender: Any) {
        imageColorBtn1.setTitle("　", for: .normal)
        imageColorBtn2.setTitle("✓", for: .normal)
        imageColorBtn3.setTitle("　", for: .normal)
        imageColorBtn4.setTitle("　", for: .normal)
        myUD.setImageColorCd(cd: Const.Color.imageColorCd.MISTYROSE)
        baseView.backgroundColor = Const.Color().getImageColor(cd: Const.Color.imageColorCd.MISTYROSE)
    }
    /**
     イメージカラーボタン3押下
     */
    @IBAction func tapImageColorBtn3(_ sender: Any) {
        imageColorBtn1.setTitle("　", for: .normal)
        imageColorBtn2.setTitle("　", for: .normal)
        imageColorBtn3.setTitle("✓", for: .normal)
        imageColorBtn4.setTitle("　", for: .normal)
        myUD.setImageColorCd(cd: Const.Color.imageColorCd.LIGHTCYAN)
        baseView.backgroundColor = Const.Color().getImageColor(cd: Const.Color.imageColorCd.LIGHTCYAN)
    }
    /**
     イメージカラーボタン4押下
     */
    @IBAction func tapImageColorBtn4(_ sender: Any) {
        imageColorBtn1.setTitle("　", for: .normal)
        imageColorBtn2.setTitle("　", for: .normal)
        imageColorBtn3.setTitle("　", for: .normal)
        imageColorBtn4.setTitle("✓", for: .normal)
        myUD.setImageColorCd(cd: Const.Color.imageColorCd.LAVENDER)
        baseView.backgroundColor = Const.Color().getImageColor(cd: Const.Color.imageColorCd.LAVENDER)
    }
}

extension SettingViewController: PHPickerViewControllerDelegate {
    /**
     画像複数選択
     */
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        var cnt = 0
        for result in results {
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                    guard image is UIImage else {
                        return
                    }
                    if self?.tapImageAddBtn == true {
                        self?.imageArray.append(image as! UIImage)
                    }
                    DispatchQueue.main.async {
                        if self?.tapImageAddBtn == true && !(self?.imageArray.isEmpty)! {
                            self?.imageCV.reloadData()
                            cnt += 1
                            if cnt == results.count {
                                self?.tapImageAddBtn = false
                            }
                        }
                        if self?.tapIconBtn == true {
                            self?.iconIV.image = image as? UIImage
                            self?.tapIconBtn = false
                        }
                    }
                }
            }
        }
    }
}

/**
 画像一覧
 */
extension SettingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if imageArray.count == Const.Limit.Normal.BACKGROUND_IMAGE_COUNT {
            // 上限に達している場合は+ボタン表示しない
            return imageArray.count
        } else {
            return imageArray.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // 最後乗セルは追加ボタンを表示
        if indexPath.row == imageArray.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addCell", for: indexPath) as! ImageAddCollectionViewCell
            
            // 追加ボタン押下アクションセット
            cell.addBtn.tag = indexPath.row
            cell.addBtn.addTarget(self, action: #selector(tapAddBtn), for: .touchUpInside)

            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCollectionViewCell
            
            if !imageArray.isEmpty {
                cell.imageIV.image = imageArray[indexPath.row]
                
                // 削除ボタン押下アクションセット
                cell.deleteBtn.tag = indexPath.row
                cell.deleteBtn.addTarget(self, action: #selector(tapDeleteBtn), for: .touchUpInside)
                
            }
            return cell
        }
    }
    /**
     cell選択
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 背景画像をセット
        backgroundIV.image = imageArray[indexPath.row]
    }

    /**
     削除ボタン押下
     */
    @objc private func tapDeleteBtn(_ sender:UIButton) {
        let row: Int = sender.tag
        imageArray.remove(at: row)
        imageCV.reloadData()
    }
    
    /**
     追加ボタン押下
     */
    @objc private func tapAddBtn(_ sender:UIButton) {
        
        // 選択上限
        let limit = Const.Limit.Normal.BACKGROUND_IMAGE_COUNT - imageArray.count
        
        tapImageAddBtn = true
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = limit
        configuration.filter = .images // 取得できるメディアの種類。
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
}

