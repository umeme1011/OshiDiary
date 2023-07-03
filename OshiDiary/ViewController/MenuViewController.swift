//
//  MenuViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/06/26.
//

import UIKit

class MenuViewController: UIViewController {
    
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
    
    @IBAction func swipeLeft(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
