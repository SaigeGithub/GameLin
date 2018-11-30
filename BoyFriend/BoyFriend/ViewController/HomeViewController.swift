//
//  HomeViewController.swift
//  BoyFriend
//
//  Created by 谢冠章 on 2018/10/15.
//  Copyright © 2018年 谢馆长. All rights reserved.
//

import UIKit
import MBProgressHUD_Add


class HomeViewController: UIViewController {

//    var cancelledData : Data?//用于停止下载时,保存已下载的部分
//    var downloadRequest:DownloadRequest!//下载请求对象
//    var destination:DownloadRequest.DownloadFileDestination!//下载文件的保存路径
//    var videoUrl = "http://gslb.miaopai.com/stream/1UKfVpOmazRYEb4fVejwhgpX~3uIxmHBV~8VCQ__.mp4"
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressBGView: UIView!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logo: UIImageView!
    
    var script = story.chineseScript
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let lan = UserDefaults.standard.object(forKey: "language"){
            if lan as! String == "简体中文".localString(){
                script = story.chineseScript
            }else{
                script = story.englishScript()
            }
            print(lan)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        progressBGView.layer.cornerRadius = 15
        progressBGView.layer.masksToBounds = true
//        loadData()
        
       
        
    }
    
//    func loadData() {
//        var downProgress:Float = 0.0
//        progressBGView.isHidden = false
//
//        //下载的进度条显示
//        Alamofire.download(videoUrl).downloadProgress(queue: DispatchQueue.main) { (progress) in
//           downProgress = Float(progress.fractionCompleted)
//            self.progressView.progress = downProgress
//
//        }
//
//        //下载存储路径
//        self.destination = {_,response in
//            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
//            let fileUrl = documentsUrl?.appendingPathComponent("chinese.json")
//            print(fileUrl as Any)
//            return (fileUrl!,[.removePreviousFile, .createIntermediateDirectories] )
//        }
//
//        self.downloadRequest = Alamofire.download(videoUrl, to: self.destination)
//
//        self.downloadRequest.responseData(completionHandler: downloadResponse)
//    }
//    //根据下载状态处理
//    func downloadResponse(response:DownloadResponse<Data>){
//        switch response.result {
//        case .success:
//            print("下载完成")
//            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
//            if let filePath = documentsUrl?.appendingPathComponent("chinese.json"){
//               self.storyBook =  story.converDownloadedJsonToModel(url: filePath)
//            }
//
//            progressBGView.isHidden = true
//        case .failure:
//            self.cancelledData = response.resumeData//意外停止的话,把已下载的数据存储起来
//        }
//    }
    @IBAction func startGame(_ sender: Any) {
        
        //获取游戏记录
        let records = CoreDataManager.shared.getAllGameRecord()
        if records.count > 0 {
            let alert = UIAlertController(title: "开始新游戏".localString(), message: "你有游戏正在进行中,重新开始将会覆盖原有游戏记录,是否开始新游戏".localString(), preferredStyle: .alert)
            let cancel = UIAlertAction(title: "继续游戏".localString(), style: .default) { (action) in
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController")
                self.navigationController?.pushViewController(vc, animated: true)
            }
            let sure = UIAlertAction(title: "重新开始".localString(), style: .destructive) { (action) in
                self.restartNewGame()
            }
            alert.addAction(cancel)
            alert.addAction(sure)
            present(alert, animated: true, completion: nil)
        }else{
            self.startNewGame()
        }
        
        
    }
    
    @IBAction func contiuneGame(_ sender: Any) {
       
        let records = CoreDataManager.shared.getAllGameRecord()
        guard records.count > 0 else {
            
            return
        }
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func 跳转到微博(_ sender: Any) {
        let url = URL(string: weibo)
        if UIApplication.shared.canOpenURL(url!){
            UIApplication.shared.open(url!, options: [ : ], completionHandler: nil)
        }
        
    }
    
    //重新开始
    func restartNewGame(){
        
        //删除所有会话记录
        CoreDataManager.shared.deleteAllConversation()

        //开始遍历剧本发信息
        startSendMessage()
       
    }
    
    //开始新游戏
    func startNewGame(){
        
        
        //开始遍历剧本发信息
        startSendMessage()
    
    }
    //开始遍历剧本给你发信息
    func startSendMessage(){
        //清除加速状态
        UserDefaults.standard.removeObject(forKey: "speedUpTime")
        //开始新游戏记录
        CoreDataManager.shared.startGameProcessWith(boyName: (script!.boyName)!, girlName: (script!.girlName)!, gameId: 0)
        //清除所有通知
        NotificationHelp.shared.center.removeAllPendingNotificationRequests()
        NotificationHelp.shared.center.removeAllDeliveredNotifications()
        //重置音乐进度条
        UserDefaults.standard.set(0.0, forKey: "musicCurrentTime")
        //获取剧本,男主角给你发信息
        if let stories = script!.questions{
            var time:TimeInterval = 0
            let boyName = script!.boyName
            
            for story in stories{
                if let messages = story.messages{
                    if messages.count > 0{
                        let msg = messages[0]
                        
                        if let messageType = story.messageType{
                            switch messageType{
                                
                            case 0:
                                time += 1
                                if let message = msg.message{
                                    NotificationHelp.shared.sendSystemMessage( msg: message, time: time)
                                }
                                if let sleep = story.sleep{
                                    
                                    time += TimeInterval(sleep)
                                }
                                
                                
                            case 1:
                                
                                if let image = msg.image{
                                    time += 1
                                    NotificationHelp.shared.sendYouImage( title: boyName!, msg: image, time: time)
                                }else if let message = msg.message{
                                    time += NotificationHelp.shared.inputSpeed(count: message.count)
                                    NotificationHelp.shared.sendYouMessage(title: boyName!, msg: message, time:time)
                                }
                                
                                
                            default:break
                            }
                            
                        }
                        if story.messageType == 2 {
                            break
                        }
                    }
                    
                    
                }
                
                
            }
        }
        //开始聊天
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController")
        navigationController?.pushViewController(vc, animated: true)
    }

}


