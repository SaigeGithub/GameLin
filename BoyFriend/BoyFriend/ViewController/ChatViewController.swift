//
//  ChatViewController.swift
//  BoyFriend
//
//  Created by 谢馆长 on 2018/10/11.
//  Copyright © 2018年 谢馆长. All rights reserved.
//

import UIKit
import GoogleMobileAds
import AVKit
import MBProgressHUD_Add
import SKPhotoBrowser



class ChatViewController: UIViewController {
    var player : AVAudioPlayer?
    var datasource = [Conversation]()
    
    var script = story.chineseScript
    var answers = [answer]()
    //    let storyBook = story.converJsonToModel()
    //是否加速,点击广告加速
    var sleepTime:TimeInterval = 0
    //正在输入标记
    var isTyping = false{
        didSet{
            self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
            scrollToEnd()
        }
    }
    //是否已经选择了
    var answerSelected = true
    //输入框
    @IBOutlet weak var inputTF: UITextField!
    //消息列表
    @IBOutlet weak var tableView: UITableView!
    //答案列表
    @IBOutlet weak var inputTableView: UITableView!
    
    @IBOutlet weak var inputTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var heartBtn: UIButton!
    @IBOutlet weak var scoreAddLabel: UILabel!
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationHelp.shared.inChatVC = false
        //保存音乐进度
        UserDefaults.standard.set(player?.currentTime, forKey: "musicCurrentTime")
        if player?.isPlaying == true{
            player?.stop()
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationHelp.shared.inChatVC = true
        
        checkInputState()
        if player?.isPlaying == false{
            player?.play()
        }
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //滚动到底部
        scrollToEnd()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playBGM()
        
        //收到消息
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMessage(notification:)), name: NSNotification.Name(rawValue: "receiveMessage"), object: nil)
        
        
        //选择剧本
        if let lan = UserDefaults.standard.object(forKey: "language"){
            if lan as! String == "简体中文".localString(){
                script = story.chineseScript
            }else{
                script = story.englishScript()
            }
            print(lan)
        }
        
        
        //获取所有消息
        self.datasource =  CoreDataManager.shared.getAllConversation()
        
        self.tableView.reloadData()
        self.isTyping = false
        
        
        
        
        
        //点击关闭答案
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissAnswer))
        tableView.addGestureRecognizer(tap)
        
        GADRewardBasedVideoAd.sharedInstance().delegate = self
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),withAdUnitID: admobAdUnitId)
        
    }
    
    //加快回复速度
    @IBAction func speedUp(_ sender: Any) {
        if GADRewardBasedVideoAd.sharedInstance().isReady == true {
            let alert = UIAlertController(title: "加快回复".localString(), message: "看广告，林昴会回复更快哟。是否观看广告？".localString(), preferredStyle: .alert)
            let cancel = UIAlertAction(title: "取消".localString(), style: .cancel) { (action) in
                
            }
            let sure = UIAlertAction(title: "确定".localString(), style: .default) { (action) in
                //展示广告
                GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
                
            }
            alert.addAction(cancel)
            alert.addAction(sure)
            self.present(alert, animated: true, completion: nil)
            
        }else{
            self.showHUDMessage("广告还没准备好".localString())
        }
        
    }
    //下一关
    @IBAction func netStage(_ sender: Any) {
        if sleepTime > 0{
            if GADRewardBasedVideoAd.sharedInstance().isReady == true{
                let alert = UIAlertController(title: "加快进度".localString(), message: "观看广告就可以立马跳到下一章，是否观看广告？".localString(), preferredStyle: .alert)
                let cancel = UIAlertAction(title: "取消".localString(), style: .cancel) { (action) in
                    
                    self.player?.play()
                }
                let sure = UIAlertAction(title: "确定".localString(), style: .default) { (action) in
                    //展示广告
                    GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
                    
                    
                }
                alert.addAction(cancel)
                alert.addAction(sure)
                self.present(alert, animated: true, completion: nil)
            }else{
                self.showHUDMessage( "广告还没准备好".localString())
            }
            
        }else{
            self.showHUDMessage( "跳过章节等待，本段结束才可使用。".localString())
        }
        
    }
    //检查输入状态
    func checkInputState(){
        
        let fullStory = script!.questions
        if let record = CoreDataManager.shared.getLastGameRecord(){
            let progress = record.process
            if Int(progress) < (fullStory?.count)!{
                //看看下一条对信息
                let nextStory = fullStory![Int(progress)]
                if nextStory.messageType == 1{
                    isTyping = true
                }else{
                    isTyping = false
                }
                //如果上一条信息带有sleep标志,不显示正在输入
                if progress > 0{
                    let lastStory = fullStory![Int(progress) - 1]
                    if lastStory.sleep != nil{
                        isTyping = false
                    }
                }
                
            }
            
            
        }
        
        
    }
    //收到消息
    @objc func didReceiveMessage(notification:Notification){
        
        
        if let notificationObj =  notification.userInfo {
            let conversations = CoreDataManager.shared.getConversationWith(messageId: notificationObj["msgId"] as! String)
            DispatchQueue.main.async {
                if conversations.count > 0{
                    
                    let conersation = conversations[0]
                    
                    //把数据插入tableView
                    self.datasource.append(conersation)
                    
                    let indexPath = IndexPath(row: self.datasource.count-1, section: 0)
                    self.tableView.insertRows(at: [indexPath], with: .fade)
                    self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
                    
                }
                
                //收到对方消息以后又可以选择答案了
                if notificationObj["msgType"] as! Int64 == 1 {
                    self.answerSelected = false
                }
                self.checkInputState()
            }
            
            
        }
        
    }
    
    //好感度
    @IBAction func liakbilityBtnClicked(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InfomationViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //设置
    @IBAction func settingBtnClicked(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        vc.volumChanged = { volum in
            self.player?.volume = volum
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //回到首页
    @IBAction func backHomeVC(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    //显示图片
    func showImage(imageName:String){
        // 打开浏览器
        // 1. create SKPhoto Array from UIImage
        var images = [SKPhoto]()
        let photo = SKPhoto.photoWithImage(UIImage(named: imageName)!)
        images.append(photo)
        
        // 2. create PhotoBrowser Instance, and present from your viewController.
        let browser = SKPhotoBrowser(photos: images)
        browser.delegate = self
        browser.initializePageIndex(0)
        present(browser, animated: true, completion: nil)
    }
    //选择答案
    @IBAction func selectAnswer(_ sender: Any) {
        if let record = CoreDataManager.shared.getLastGameRecord(){
            let progress = record.process
            
            if script!.questions!.count <= Int(progress){
                return
            }
            let story = script!.questions![Int(progress)]
            if progress > 0{
                let lastScript = script!.questions![Int(progress) - 1]
                if let end = lastScript.end{
                    if end == "good"{
                        let gameScore = CoreDataManager.shared.getGameScore()
                        if let branchScore = lastScript.branchScore{
                            if gameScore >= branchScore{
                                return
                            }
                        }
                    }
                }
            }
            
            
            if story.messageType == 2{
                if let girlMsgs = story.messages{
                    
                    answers = girlMsgs
                    inputTableView.reloadData()
                    var height:CGFloat = 60
                    //                        计算输入框高度
                    for answer in girlMsgs{
                        if let message = answer.message{
                            let width = message.ga_widthForComment(fontSize: 14)
                            if width > SCREENWIDTH - 70{
                                height += message.ga_heightForComment(fontSize: 14, width: SCREENWIDTH - 70) + 40
                            }else{
                                height += 50
                            }
                        }else{
                            height += 50
                        }
                    }
                    if girlMsgs.count > 0{
                        //                        修改输入框高度
                        inputTableView.layoutIfNeeded()
                        UIView.animate(withDuration: 0.8) {
                            self.inputTableViewHeight.constant = height
                        }
                        
                        
                        //                        调整tableView偏移量
                        //                        tableView.contentInset = UIEdgeInsetsMake(-height, 0, height, 0)
                        if datasource.count > 0{
                            tableView.scrollToRow(at: IndexPath(row: datasource.count - 1, section: 0), at: .bottom, animated: true)
                        }
                        
                        
                        
                        
                    }
                }
            }
            
        }
    }
    
    //b关闭答案列表
    @objc func dismissAnswer() {
        answers.removeAll()
        inputTableView.reloadData()
        inputTableView.layoutIfNeeded()
        UIView.animate(withDuration: 0.8) {
            self.inputTableViewHeight.constant = 55
        }
        
    }
    //滚动到底部
    func scrollToEnd(){
        if datasource.count > 3{
            
            UIView.animate(withDuration: 0.4) {
                //滚到底
                if self.isTyping == true{
                    
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: false)
                }else{
                    self.tableView.scrollToRow(at: IndexPath(row: self.datasource.count-1, section: 0), at: .top, animated: false)
                }
                
            }
            
        }
    }
    
}
extension ChatViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == inputTableView{
            return 1
        }else{
            return 2
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == inputTableView{
            return answers.count
            
        }else{
            
            if section == 0{
                return datasource.count
            }else{
                if isTyping == true{
                    return 1
                }else {
                    return 0
                }
                
            }
        }
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            if tableView != inputTableView{
                let model = datasource[indexPath.row]
                switch model.msgType{
                case 1:
                    if model.isImage == true{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "BoyPhotoTableViewCell", for: indexPath) as! BoyPhotoTableViewCell
                        if let photoName = model.content{
                            let image = UIImage(named: photoName)
                            cell.photoView.image = image
                            cell.imageName = photoName
                            let heightScale = image!.size.height/image!.size.width
                            cell.photoWidth.constant = 100 * heightScale
                            cell.photoHeight.constant = 100 * heightScale
                            cell.tapImage = { [weak self] name in
                                self?.showImage(imageName: name)
                            }
                            
                        }
                        
                        return cell
                    }else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
                        
                        cell.model = model
                        return cell
                    }
                    
                case 2:
                    if model.isImage == true{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoTableViewCell", for: indexPath) as! PhotoTableViewCell
                        if let photoName = model.content{
                            let image = UIImage(named: photoName)
                            cell.imageName  = photoName
                            cell.tapImage = { [weak self] name in
                                self?.showImage(imageName: name)
                            }
                            let heightScale = image!.size.height/image!.size.width
                            var width = 100 * heightScale
                            if width > SCREENWIDTH - 100{
                                width = SCREENWIDTH - 100
                            }
                            cell.photoWidth.constant = width
                            cell.photoHeight.constant = width
                            
                        }
                        
                        return cell
                    }else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCellRight", for: indexPath) as! ChatTableViewCellRight
                        cell.model = model
                        return cell
                    }
                    
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "systemMessageCell", for: indexPath) as! systemMessageCell
                    if let content = model.content{
                        let width =  content.ga_widthForComment(fontSize: 12)
                        if width > UIScreen.main.bounds.size.width - 30{
                            cell.bubleViewWidth.constant = UIScreen.main.bounds.size.width - 30
                        }else{
                            cell.bubleViewWidth.constant = CGFloat(width)+20
                        }
                        cell.messageLabel.setLabelSpace(font: UIFont.systemFont(ofSize: 12), str: model.content!,lineSpace: 5)
                    }
                    
                    
                    return cell
                    
                default:
                    let cell = UITableViewCell()
                    
                    return cell
                    
                }
                
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "GameAnswerTableViewCell", for: indexPath) as! GameAnswerTableViewCell
                
                let text = answers[indexPath.row]
                if let _ = text.image{
                    cell.answerLabel!.text = "图片"
                }else{
                    cell.answerLabel!.text = text.message
                }
                
                return cell
            }
        }else{
            //正在输入
            let cell = tableView.dequeueReusableCell(withIdentifier: "TypingTableViewCell", for: indexPath) as! TypingTableViewCell
            return cell
        }
        
        
        
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0{
            
            if tableView != inputTableView{
                
                let model = datasource[indexPath.row]
                
                return CGFloat(model.cellHeight)
                
                
            }else{
                
                var height:CGFloat = 0
                let answer = answers[indexPath.row]
                if let message = answer.message{
                    let width = message.ga_widthForComment(fontSize: 14)
                    if width > UIScreen.main.bounds.size.width - 70{
                        height = (message.ga_heightForComment(fontSize: 14, width: UIScreen.main.bounds.size.width-70))+40
                    }else{
                        height = 50
                    }
                    return height
                }else{
                    return 50
                }
                
                
            }
        }else{
            return 100
        }
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == inputTableView {
            let girlName = script!.girlName
            let message = answers[indexPath.row]
            let score = message.score
            if score > 0{
                scoreAddLabel.heartAnimation()
                scoreAddLabel.text = "+" + "\(score)"
                CoreDataManager.shared.saveGameScoreWith(score: score)
                UIView.animate(withDuration: 1, animations: {
                    self.scoreAddLabel.alpha = 1
                }) { (result) in
                    self.scoreAddLabel.alpha = 0
                }
            }else if score < 0{
                CoreDataManager.shared.saveGameScoreWith(score: score)
            }
            if let record = CoreDataManager.shared.getLastGameRecord(){
                let progress = record.process
                
                let gameScore = CoreDataManager.shared.getGameScore()
                if script!.questions!.count <= Int(progress){
                    return
                }
                //                let story = fullStory![Int(progress)]
                if let message = message.message{
                    NotificationHelp.shared.sendMyMessage( title: girlName!, msg: message, time: 0.1)
                }else if let image = message.image{
                    NotificationHelp.shared.sendPhotoMessage(title: girlName!, imageName: image, time: 0.1)
                }
                
                
                
                //剧本已经到头了
                if script!.questions!.count <= Int(progress + 1){
                    dismissAnswer()
                    return
                }
                //下一条轮到对方发信息
                let nextStory = script!.questions![Int(progress) + 1]
                if nextStory.messageType != 2{
                    let stories = script!.questions!.suffix(script!.questions!.count - Int(progress) - 1)
                    
                    //男主角给你发信息
                    var time:TimeInterval = 0
                    let boyName = script!.boyName
                    for story in stories{
                        
                        if let messages = story.messages{
                            if messages.count > 0{
                                let msg = messages[0]
                                
                                //主线剧情
                                if let messageType = story.messageType{
                                    //出现分支剧情
                                    if let branchScore = story.branchScore{
                                        if branchScore > gameScore{
                                            //保存进度
                                            print("没有达到支线剧情条件")
                                            CoreDataManager.shared.saveGameProcess()
                                            continue
                                        }else{
                                            print("进入支线")
                                            switch messageType{
                                                
                                            case 0:
                                                time += 1
                                                if let message = msg.message{
                                                    NotificationHelp.shared.sendSystemMessage(msg: message, time: time)
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
                                        
                                    }else{
                                        switch messageType{
                                            
                                        case 0:
                                            time += 1
                                            if let message = msg.message{
                                                NotificationHelp.shared.sendSystemMessage(msg: message, time: time)
                                            }
                                            
                                            
                                            
                                        case 1:
                                            
                                            if let image = msg.image{
                                                time += 1
                                                NotificationHelp.shared.sendYouImage(title: boyName!, msg: image, time: time)
                                            }else if let message = msg.message{
                                                time += NotificationHelp.shared.inputSpeed(count: message.count)
                                                NotificationHelp.shared.sendYouMessage(title: boyName!, msg: message, time:time)
                                            }
                                            
                                            
                                        default:break
                                        }
                                    }
                                    
                                }
                                
                                
                                
                            }
                        }
                        //如果有休息时间,跳出循环
                        if let sleep = story.sleep{
                            isTyping = false
                            if GADRewardBasedVideoAd.sharedInstance().isReady == true {
                                self.player?.pause()
                                let alert = UIAlertController(title: "加快进度".localString(), message: "观看广告就可以立马跳到下一章，是否观看广告？".localString(), preferredStyle: .alert)
                                let cancel = UIAlertAction(title: "取消".localString(), style: .cancel) { (action) in
                                    
                                    self.player?.play()
                                }
                                let sure = UIAlertAction(title: "确定".localString(), style: .default) { (action) in
                                    //展示广告
                                    GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
                                    
                                    
                                }
                                alert.addAction(cancel)
                                alert.addAction(sure)
                                self.present(alert, animated: true, completion: nil)
                                sleepTime = TimeInterval(sleep)
                                break
                            }else{
                                sleepTime = TimeInterval(sleep)
                                time += TimeInterval(sleep)
                            }
                            
                        }
                        if let _ = story.end{
                            break
                        }
                        if story.messageType == 2 {
                            break
                        }
                        
                        
                    }
                }
                
            }
            dismissAnswer()
        }else{
            if indexPath.section == 0{
                
                let conversation = datasource[indexPath.row]
                
                if conversation.isImage == true{
                    
                    
                }
            }
            
        }
        
    }
    func contiuneGame(speedUp:Bool){
        
        
        if let record = CoreDataManager.shared.getLastGameRecord(){
            let progress = record.process
            let fullStory = script!.questions
            let gameScore = CoreDataManager.shared.getGameScore()
            if fullStory!.count <= Int(progress){
                return
            }
            
            //剧本已经到头了
            if fullStory!.count <= Int(progress){
                
                return
            }
            //下一条轮到对方发信息
            let nextStory = fullStory![Int(progress)]
            if nextStory.messageType != 2{
                let stories = fullStory!.suffix(fullStory!.count - Int(progress))
                
                //男主角给你发信息
                var time:TimeInterval = 0
                if speedUp == true{
                    time += 1
                }else{
                    time += TimeInterval(sleepTime)
                }
                let boyName = script!.boyName
                for story in stories{
                    if let messages = story.messages{
                        if messages.count > 0{
                            let msg = messages[0]
                            
                            //主线剧情
                            if let messageType = story.messageType{
                                //出现分支剧情
                                if let branchScore = story.branchScore{
                                    if branchScore >= gameScore{
                                        //保存进度
                                        print("没有达到支线剧情条件")
                                        CoreDataManager.shared.saveGameProcess()
                                        continue
                                    }else{
                                        print("进入支线")
                                        switch messageType{
                                            
                                        case 0:
                                            
                                            if let message = msg.message{
                                                NotificationHelp.shared.sendSystemMessage( msg: message, time: time)
                                            }
                                            
                                            
                                            
                                        case 1:
                                            
                                            if let image = msg.image{
                                                time += 1
                                                NotificationHelp.shared.sendYouImage(title: boyName!, msg: image, time: time)
                                            }else if let message = msg.message{
                                                time += NotificationHelp.shared.inputSpeed(count: message.count)
                                                NotificationHelp.shared.sendYouMessage(title: boyName!, msg: message, time:time)
                                            }
                                            
                                            
                                        default:break
                                        }
                                    }
                                    
                                }else{
                                    switch messageType{
                                        
                                    case 0:
                                        time += 1
                                        if let message = msg.message{
                                            NotificationHelp.shared.sendSystemMessage( msg: message, time: time)
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
                                
                            }
                            
                            
                            
                        }
                    }
                    //如果有休息时间,跳出循环
                    if let sleep = story.sleep{
                        isTyping = false
                        if GADRewardBasedVideoAd.sharedInstance().isReady == true {
                            self.player?.pause()
                            let alert = UIAlertController(title: "加快进度".localString(), message: "观看广告就可以立马跳到下一章，是否观看广告？".localString(), preferredStyle: .alert)
                            let cancel = UIAlertAction(title: "取消".localString(), style: .cancel) { (action) in
                                
                                self.player?.play()
                            }
                            let sure = UIAlertAction(title: "确定".localString(), style: .default) { (action) in
                                //展示广告
                                GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
                                
                                
                            }
                            alert.addAction(cancel)
                            alert.addAction(sure)
                            self.present(alert, animated: true, completion: nil)
                            sleepTime = TimeInterval(sleep)
                            break
                        }else{
                            time += TimeInterval(sleep)
                        }
                        
                    }
                    if story.messageType == 2 {
                        break
                    }
                    if let _ = story.end{
                        break
                    }
                    
                }
            }
            
        }
    }
    
    
}


extension ChatViewController:AVAudioPlayerDelegate{
    
    func playBGM(){
        //播放声音
        let filePath = Bundle.main.path(forResource: "bgm_maoudamashii_piano34", ofType: "mp3")
        player = try? AVAudioPlayer.init(contentsOf: URL(fileURLWithPath: filePath!))
        player?.delegate = self
        
        if player?.isPlaying == false{
            if let vol = UserDefaults.standard.object(forKey: "GameVolum"){
                player?.volume = vol as! Float
            }else{
                player?.volume = 1
            }
            player?.currentTime = TimeInterval(UserDefaults.standard.float(forKey: "musicCurrentTime"))
            player?.numberOfLoops = -1
            player?.prepareToPlay()
            player?.play()
        }
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("播放结束")
    }
    
}
extension ChatViewController:GADRewardBasedVideoAdDelegate{
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        UserDefaults.standard.set(NSDate().timeIntervalSince1970, forKey: "speedUpTime")
        self.showHUDMessage("观看了广告,五分钟内回复加速".localString())
        contiuneGame(speedUp: true)
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd) {
        print("Reward based video ad is received.")
        
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Opened reward based video ad.")
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad started playing.")
    }
    
    func rewardBasedVideoAdDidCompletePlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("广告播放完了")
        
    }
    
    
    //关闭了广告
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        
        //        player?.play()
        //加载下一个广告
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
                                                    withAdUnitID: admobAdUnitId)
        
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad will leave application.")
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print(error.localizedDescription)
    }
}
extension ChatViewController:SKPhotoBrowserDelegate{
    func didShowPhotoAtIndex(_ browser: SKPhotoBrowser, index: Int) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        //允许横屏
        delegate.allowRotation = true
    }
    func didDismissAtPageIndex(_ index: Int) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        //强制竖屏
        delegate.allowRotation = false
        setNewOrientation(fullScreen: false)
        
    }
}
func setNewOrientation(fullScreen:Bool){
    if fullScreen == true{
        let resetOrientationTarget = NSNumber(integerLiteral: UIInterfaceOrientation.unknown.rawValue)
        UIDevice.current.setValue(resetOrientationTarget, forKey: "orientation")
        let orientationTarget = NSNumber(integerLiteral: UIInterfaceOrientation.landscapeRight.rawValue)
        UIDevice.current.setValue(orientationTarget, forKey: "orientation")
    }else{
        let resetOrientationTarget = NSNumber(integerLiteral: UIInterfaceOrientation.unknown.rawValue)
        UIDevice.current.setValue(resetOrientationTarget, forKey: "orientation")
        let orientationTarget = NSNumber(integerLiteral:UIInterfaceOrientation.portrait.rawValue)
        UIDevice.current.setValue(orientationTarget, forKey: "orientation")
    }
}



