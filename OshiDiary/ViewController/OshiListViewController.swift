//
//  OshiListViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/28.
//

import UIKit

class OshiListViewController: UIViewController {
    
    @IBOutlet weak var listTV: UITableView!
    @IBOutlet weak var editBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.listTV.delegate = self
        self.listTV.dataSource = self
        
    }

    /**
     編集ボタン押下
     */
    @IBAction func tapEditBtn(_ sender: Any) {
        if self.listTV.isEditing == true {
            self.listTV.isEditing = false
            self.editBtn.setTitle("編集", for: .normal)
        } else {
            self.listTV.isEditing = true
            self.editBtn.setTitle("完了", for: .normal)
        }
    }
}

extension OshiListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier:  "addCell", for:indexPath as IndexPath)
                as! OshiListAddTableViewCell

            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier:  "cell", for:indexPath as IndexPath)
                as! OshiListTableViewCell
            
            cell.nameLbl.text = "ててててて"

            return cell

        }
    }
    
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
    
}
