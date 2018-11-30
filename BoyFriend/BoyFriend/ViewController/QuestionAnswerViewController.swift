//
//  QuestionAnswerViewController.swift
//  BoyFriend
//
//  Created by 谢馆长 on 2018/11/27.
//  Copyright © 2018 谢馆长. All rights reserved.
//

import UIKit

class QuestionAnswerViewController: UIViewController {
    
    var datasource = [QuestionModel]()
    var selectedAnswer:answerModel?
    var questionType = 0
    var score = 0
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var nextBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func nextBtnClicked(_ sender: UIButton) {
        if let answer = selectedAnswer{
            
            
           
            
            if answer.correct == true{
                score += 1
                switch questionType{
                case 0:
                    UserDefaults.standard.set(score, forKey: "score0")
                case 1:
                    UserDefaults.standard.set(score, forKey: "score1")
                case 2:
                    UserDefaults.standard.set(score, forKey: "score2")
                default:break
                }
            }
            
            if datasource.count == 1{
                
                showHUDMessage("答对了".localString() + String(format: "%d", score) + "题,林昴对你的好感度增加了".localString())
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                    self.navigationController?.popViewController(animated: true)
                }
                return
            }
            datasource.remove(at:0)
            table.reloadData()
            table.allowsSelection = true
            selectedAnswer = nil
            if datasource.count == 1{
                sender.setTitle("完成".localString(), for: .normal)
            }
            print(datasource.count)
        }else{
            self.showHUDMessage("请选择一个答案".localString())
        }
        
    }
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension QuestionAnswerViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if datasource.count > 0{
            return 1
        }else{
            return 0
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let model = datasource[section]
        return model.answers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerTableViewCell", for: indexPath) as! AnswerTableViewCell
        let model = datasource[indexPath.section]
        cell.answerLabel.text = model.answers[indexPath.row].answerStr
        if model.answers[indexPath.row].correct == false{
            cell.imageV.image = UIImage(named: "false-circle")
        }else{
            cell.imageV.image = UIImage(named: "yes1")
        }
        cell.imageV.isHidden = !model.answers[indexPath.row].selected
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let model = datasource[section]
        
        let height = model.question.ga_heightForComment(fontSize: 15, width: SCREENWIDTH - 40) + 40
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREENWIDTH, height: height))
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: SCREENWIDTH-40, height: height))
        label.font = UIFont.systemFont(ofSize: 15)
        view.addSubview(label)
        label.numberOfLines = 0
        label.text = model.question
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let model = datasource[section]
        
        return model.question.ga_heightForComment(fontSize: 15, width: SCREENWIDTH - 40) + 40
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = datasource[indexPath.section]
        let text = model.answers[indexPath.row].answerStr
        return text.ga_heightForComment(fontSize: 15, width: SCREENWIDTH - 75) + 40
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedAnswer = datasource[indexPath.section].answers[indexPath.row]
        tableView.allowsSelection = false
        
    }
}
