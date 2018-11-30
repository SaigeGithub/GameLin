//
//  SettingViewController.swift
//  BoyFriend
//
//  Created by 谢冠章 on 2018/10/18.
//  Copyright © 2018年 谢馆长. All rights reserved.
//

import UIKit
import UserNotifications




class SettingViewController: UIViewController {
    typealias volumChangedClosure = (Float) -> Void
    
    @IBOutlet weak var tableView: UITableView!
    var volumChanged:volumChangedClosure?
    var sw:UISwitch?
    var datasource = [(String,String,Bool)]()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置完成通知
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSwData), name: NSNotification.Name(rawValue: "enterForeGround"), object: nil)
        
        //有英文剧本
        if story.converEnglishJsonToModel() == true{
            if let language = UserDefaults.standard.object(forKey: "language"){
                datasource = [("Idea","音量".localString(),true),("开启推送","开启推送".localString(),true),("langu",language as! String,false),("comment","官方微博".localString(),false),("User","关于我们".localString(),false)]
            }else{
                datasource = [("Idea","音量".localString(),true),("开启推送","开启推送".localString(),true),("langu","简体中文".localString(),false),("comment","官方微博".localString(),false),("User","关于我们".localString(),false)]
            }
            
        }else{
            datasource = [("Idea","音量".localString(),true),("开启推送","开启推送".localString(),true),("comment","官方微博".localString(),false),("User","关于我们".localString(),false)]
        }
        
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //刷新显示开关
    @objc func reloadSwData(){
        NotificationHelp.shared.center.requestAuthorization(options: [.alert]) { (granted, error) in
            
            DispatchQueue.main.async {
                self.sw?.isOn = granted
            }
        }
    }
    //推送开关
    func switchValueChanged(){
       NotificationHelp.shared.center.requestAuthorization(options: [.alert]) { (granted, error) in
        
        DispatchQueue.main.async {
            self.sw?.isOn = granted
        }
        }
        let url = URL(string: UIApplicationOpenSettingsURLString)
        if UIApplication.shared.canOpenURL(url!){
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
    //调音量
    @objc func changeVolum(sender:UISlider){
        UserDefaults.standard.set(sender.value, forKey: "GameVolum")
        if volumChanged != nil{
            volumChanged!(sender.value)
        }
    }
    
}
extension SettingViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "VolumTableViewCell", for: indexPath) as! VolumTableViewCell
            let model = datasource[indexPath.row]
            cell.headImage.image = UIImage(named: model.0)
            cell.titleLabel.text = model.1
            
            cell.slider.addTarget(self, action: #selector(changeVolum(sender:)), for: .valueChanged)
            if let vol =  UserDefaults.standard.object(forKey: "GameVolum"){
                cell.slider.value = vol as! Float
            }
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
            let model = datasource[indexPath.row]
            cell.headImage.image = UIImage(named: model.0)
            cell.titleLabel.text = model.1
            if model.2 == true{
                cell.notificationSwitch.isHidden = false
                cell.titleLabel.textAlignment = .left
                self.sw = cell.notificationSwitch
                NotificationHelp.shared.center.requestAuthorization(options: [.alert]) { (granted, error) in
                    DispatchQueue.main.async {
                        cell.notificationSwitch.isOn = granted
                    }
                }
                
            }else{
                cell.notificationSwitch.isHidden = true
                cell.titleLabel.textAlignment = .center
            }
            return cell
        }
        

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 110
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let model = datasource[indexPath.row]
        switch model.1 {
        case "开启推送".localString():
            switchValueChanged()
        case "官方微博".localString():
            let url = URL(string: weibo)
            if UIApplication.shared.canOpenURL(url!){
                UIApplication.shared.open(url!, options: [ : ], completionHandler: nil)
            }
        case "关于我们".localString():
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AboutUsViewController")
            navigationController?.pushViewController(vc, animated: true)
        case "简体中文".localString(),"英语".localString():
            
            //英文剧本还没写
            if story.converEnglishJsonToModel() == false{
                
//                showHUDMessage("英文剧本还没写")
                return
            }
            let alert = UIAlertController(title: "选择语言".localString(), message: "切换剧本语言后游戏进度将会重置".localString(), preferredStyle: .actionSheet)
            let chinese = UIAlertAction(title: "简体中文".localString(), style: .default) { (action) in
                UserDefaults.standard.setValue("简体中文".localString(), forKeyPath: "language")
                
                //清除所有通知
                NotificationHelp.shared.center.removeAllPendingNotificationRequests()
                NotificationHelp.shared.center.removeAllDeliveredNotifications()
                CoreDataManager.shared.deleteAllGameRecord()
                //删除所有会话记录
                CoreDataManager.shared.deleteAllConversation()
                self.navigationController?.popToRootViewController(animated: true)
            }
            let english = UIAlertAction(title: "英语".localString(), style: .default) { (action) in
                //清除所有通知
                NotificationHelp.shared.center.removeAllPendingNotificationRequests()
                NotificationHelp.shared.center.removeAllDeliveredNotifications()
                CoreDataManager.shared.deleteAllGameRecord()
                //删除所有会话记录
                CoreDataManager.shared.deleteAllConversation()
                UserDefaults.standard.setValue("英语".localString(), forKeyPath: "language")
                
                self.navigationController?.popToRootViewController(animated: true)
            }
            let cancel = UIAlertAction(title: "取消".localString(), style: .cancel) { (action) in
                
            }
            alert.addAction(chinese)
            alert.addAction(english)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        default:
            break
        }
        
        
        
    }
}
