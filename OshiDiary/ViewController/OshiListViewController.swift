//
//  OshiListViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/28.
//

import UIKit
import RealmSwift

class OshiListViewController: UIViewController {
    
    @IBOutlet weak var listTV: UITableView!
    @IBOutlet weak var editBtn: UIButton!
    
    var myUD: MyUserDefaults!
    var oshiId: Int!
    var commonRealm: Realm!
    var oshiSettings: Results<OshiSetting>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTV.delegate = self
        listTV.dataSource = self
        
        myUD = MyUserDefaults.init()
        oshiId = myUD.getOshiId()
        commonRealm = CommonMethod.createCommonRealm()
        
        // 推しリスト取得
        oshiSettings = commonRealm.objects(OshiSetting.self)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 編集後再表示
        oshiId = myUD.getOshiId()
        listTV.reloadData()
        // メニュー画面にデザイン反映
        let vc: MenuViewController = self.presentingViewController as! MenuViewController
        vc.changeVisual()
    }
    
    /**
     編集ボタン押下
     */
    @IBAction func tapEditBtn(_ sender: Any) {
        // TODO 削除、編集できない
        if listTV.isEditing == true {
            listTV.setEditing(false, animated: true)
            editBtn.setTitle("編集", for: .normal)
        } else {
            listTV.setEditing(true, animated: true)
            editBtn.setTitle("完了", for: .normal)
        }
    }
    
    /**
     値渡し
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segue.identifier {
        // 推し追加ボタン押下で設定画面へ
        case "toSetting":
            // 遷移先のVC取得
            let vc:SettingViewController = segue.destination as? SettingViewController ?? SettingViewController()
            vc.isNew = true
        default:
            return
        }
    }

    /**
     閉じるボタン押下
     */
    @IBAction func tapCloseBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension OshiListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return oshiSettings.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == oshiSettings.count {
            let cell = tableView.dequeueReusableCell(withIdentifier:  "addCell", for:indexPath as IndexPath)
                as! OshiListAddTableViewCell

            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:  "cell", for:indexPath as IndexPath)
                as! OshiListTableViewCell
            
            // アイコン画像
            cell.iconIV.image = CommonMethod.roadIconImage(oshiId: oshiSettings[indexPath.row].id)
            // 名前
            cell.nameLbl.text = oshiSettings[indexPath.row].name
            // チェックマーク
            if oshiId != oshiSettings[indexPath.row].id {
                cell.checkIV.isHidden = true
            } else {
                cell.checkIV.isHidden = false
            }

            return cell
        }
    }
    
    // セルの移動を許可する
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //並び替え時に呼ばれるメソッド
    private func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath){
 
//        //移動されたデータを取得する。
//        let moveData = tableView.cellForRowAtIndexPath(sourceIndexPath)?.textLabel!.text
//
//        //元の位置のデータを配列から削除する。
//        dataList.removeAtIndex(sourceIndexPath.row)
//
//        //移動先の位置にデータを配列に挿入する。
//        dataList.insert(moveData!, atIndex:destinationIndexPath.row)
    }
    
    // セルがタップされた時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        myUD.setOshiId(id: oshiSettings[indexPath.row].id)
        myUD.setImageColorCd(cd: oshiSettings[indexPath.row].imageColorCd)
        
        let vc: MenuViewController = self.presentingViewController as! MenuViewController
        vc.changeVisual()

        self.dismiss(animated: true)
    }
}
