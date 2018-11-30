//
//  InfomationViewController.swift
//  BoyFriend
//
//  Created by 谢馆长 on 2018/10/18.
//  Copyright © 2018年 谢馆长. All rights reserved.
//

import UIKit

class InfomationViewController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let records = CoreDataManager.shared.getAllGameRecord()
        
        if records.count > 0{
            let record = records[0]
            
            //编程知识加分
            let score0 = UserDefaults.standard.integer(forKey: "score0")
            //艺术知识加分
            let score1 = UserDefaults.standard.integer(forKey: "score1")
            //军事知识加分
            let score2 = UserDefaults.standard.integer(forKey: "score2")
            
            scoreLabel.text = "\(Int(record.score) + score0 + score1 + score2)" + "%"
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
