//
//  DiaryListOverViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/22.
//

import UIKit
import FSCalendar

class DiaryListOverViewController: UIViewController {
    
    @IBOutlet weak var baseView: UIView!
    
    var myUD: MyUserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myUD = MyUserDefaults.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // イメージカラー設定
        baseView.backgroundColor = Const.Color().getImageColor(cd: myUD.getImageColorCd())
    }

    @IBAction func tapBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
