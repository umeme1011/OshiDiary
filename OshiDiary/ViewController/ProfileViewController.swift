//
//  ProfileViewController.swift
//  OshiDiary
//
//  Created by umeme on 2023/07/26.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var listTV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listTV.delegate = self
        listTV.dataSource = self
        
        listTV.estimatedRowHeight = 35
        listTV.rowHeight = UITableView.automaticDimension
    }

    
    @IBAction func tapBackBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:  "cell", for:indexPath as IndexPath)
            as! ListTableViewCell

        cell.profileLbl.text = "趣味・特技：XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        
        return cell
    }
    
    
}
