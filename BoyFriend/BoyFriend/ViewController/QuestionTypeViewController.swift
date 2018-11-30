//
//  QuestionAnswerViewController.swift
//  BoyFriend
//
//  Created by 谢冠章 on 2018/11/25.
//  Copyright © 2018 谢馆长. All rights reserved.
//

import UIKit

class QuestionTypeViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    var index = 0
    var score0 = 0
    var score1 = 0
    var score2 = 0
    
    
    @IBAction func BtnClicked1(_ sender: Any) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QuestionAnswerViewController") as! QuestionAnswerViewController
        vc.datasource = QuestionModel.createQuestions(questionType: 0)!
        vc.questionType = 0
        navigationController?.pushViewController(vc, animated: true)
        
    }
    @IBAction func btnClicked2(_ sender: Any) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QuestionAnswerViewController") as! QuestionAnswerViewController
        vc.datasource = QuestionModel.createQuestions(questionType: 1)!
        vc.questionType = 1
        navigationController?.pushViewController(vc, animated: true)
        
    }
    @IBAction func btnClicked3(_ sender: Any) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QuestionAnswerViewController") as! QuestionAnswerViewController
        vc.datasource = QuestionModel.createQuestions(questionType: 2)!
        vc.questionType = 2
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated:true)
        
    }

}
