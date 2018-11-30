//
//  NotificationHelp.swift
//  BoyFriend
//
//  Created by 谢冠章 on 2018/10/14.
//  Copyright © 2018年 谢馆长. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData



class NotificationHelp: NSObject {
   static let shared = NotificationHelp()
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var inChatVC = false
    //点击了通知
    var notificationTaped  = false
    let center = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        center.delegate = self
    }
    //计算打字需要的时间
    func inputSpeed(count:Int) -> TimeInterval{
        if count > 0{
            //如果还在点了广告加速的五分钟内
            let time = UserDefaults.standard.double(forKey: "speedUpTime") + 300
            if Date().timeIntervalSince1970 < time{
                //打一个字需要
                print("加速打字状态")
                let pwm = typingSpeed * Double(count/2)
                return  TimeInterval(pwm)
            }else{
                let pwm = typingSpeed * Double(count)
                return  TimeInterval(pwm)
            }
            
           
            
        }else{
            return 1
        }
        
    }
    func sendMyMessage(title:String,msg:String,time:TimeInterval) {
        let msgType:Int64 = 2
        let messageId = msg.md5 + "\(NSDate().timeIntervalSince1970)"
        if appdelegate.allowNotification == true{
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = msg
            content.userInfo = ["msgType":msgType,"msgId":messageId,"isImage":false]
            content.sound = UNNotificationSound.default()
            // Deliver the notification in five seconds.
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval:time, repeats: false)
            let request = UNNotificationRequest(identifier: "\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request)
        }else{
            //如果通知没有打开
            self.handleMessageSilent(msg: msg, userInfo: ["msgType":msgType,"msgId":messageId,"isImage":false],time: time)
        }

    }
    
    func sendYouMessage(title:String,msg:String,time:TimeInterval) {
        let msgType:Int64 = 1
        let messageId = msg.md5 + "\(NSDate().timeIntervalSince1970)"
        if appdelegate.allowNotification == true{
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = msg
            content.userInfo = ["msgType":msgType,"msgId":messageId,"isImage":false]
            content.sound = UNNotificationSound.default()
            // Deliver the notification in five seconds.
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
            let request = UNNotificationRequest(identifier: "\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request)
        }else{
            //如果通知没有打开
            self.handleMessageSilent(msg: msg, userInfo:["msgType":msgType,"msgId":messageId,"isImage":false],time: time)
        }
    }
    //对方发的图片
    func sendYouImage(title:String,msg:String,time:TimeInterval) {
        
        let msgType:Int64 = 1
        let messageId = msg.md5 + "\(NSDate().timeIntervalSince1970)"
        if appdelegate.allowNotification == true{
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = msg
            content.userInfo = ["msgType":msgType,"msgId":messageId,"isImage":true]
            content.sound = UNNotificationSound.default()
            // Deliver the notification in five seconds.
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
            let request = UNNotificationRequest(identifier: "\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request)
        }else{
            //如果通知没有打开
            self.handleMessageSilent(msg: msg, userInfo: ["msgType":msgType,"msgId":messageId,"isImage":true],time: time)
        }
        
    }
    
    //发送系统消息
    func sendSystemMessage(msg:String,time:TimeInterval){
        let msgType:Int64 = 0
        let messageId = msg.md5 + "\(NSDate().timeIntervalSince1970)"
        if appdelegate.allowNotification == true{
            let content = UNMutableNotificationContent()
            content.title = "系统消息"
            content.body = msg
            content.userInfo = ["msgType":msgType,"msgId":messageId,"isImage":false]
            content.sound = UNNotificationSound.default()
            // Deliver the notification in five seconds.
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
            let request = UNNotificationRequest(identifier: "\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request)
        }else{
            //如果通知没有打开
            self.handleMessageSilent(msg: msg, userInfo: ["msgType":msgType,"msgId":messageId,"isImage":false],time: time)
        }
       
    }
    //女方发的图片
    func sendPhotoMessage(title:String,imageName:String,time:TimeInterval){
        let msgType:Int64 = 2
        let messageId = imageName.md5 + "\(NSDate().timeIntervalSince1970)"
        if appdelegate.allowNotification == true{
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = imageName
                content.userInfo = ["msgType":msgType,"msgId":messageId,"isImage":true]
                content.sound = UNNotificationSound.default()
                // Deliver the notification in five seconds.
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
                let request = UNNotificationRequest(identifier: "\(Date().timeIntervalSince1970)", content: content, trigger: trigger)
                // Schedule the notification.
                let center = UNUserNotificationCenter.current()
                center.add(request)
        }else{
                //如果通知没有打开
                self.handleMessageSilent(msg: imageName, userInfo: ["msgType":msgType,"msgId":messageId,"isImage":true],time: time)
        }
        
    }
}
extension NotificationHelp:UNUserNotificationCenterDelegate{
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
        print("点击了通知")
//        NotificationHelp.shared.notificationTaped = true
//        handleMessage(notification: response.notification)
        if (inChatVC == false){
            //开始聊天
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController")
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.window?.rootViewController?.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        handleMessage(notification: notification)
        
        //如果当前页面是聊天页面,就不弹出通知
        let userInfo = notification.request.content.userInfo
        if (inChatVC == true){
            if userInfo["msgType"] as! Int64 == 1{
                completionHandler([.badge])
            }
            
        }else{
            completionHandler([.badge,.sound])
        }
        
    }
    
    //收到信息后的处理
    func handleMessage(notification:UNNotification){
        let userInfo = notification.request.content.userInfo
        let content = notification.request.content.body
        let msgType = userInfo["msgType"] as! Int64
        let msgId = userInfo["msgId"] as! String
        let isImage = userInfo["isImage"] as! Bool
        var imageName = ""
        if msgType == 1{
            imageName = "boy"
        }else if msgType == 2{
            imageName = "girl"
        }
        
        
        let conversations = CoreDataManager.shared.getConversationWith(messageId: msgId)
        
        if conversations.count == 0{
            //收到消息保存进度
            CoreDataManager.shared.saveGameProcess()
            //保存会话
            CoreDataManager.shared.saveConversationWith(messageId:msgId,conent: content, headImage: imageName, msgType: msgType, time: Date(),isImage: isImage)
            //发送通知
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receiveMessage"), object: nil, userInfo: userInfo as [AnyHashable : Any])
        }else{
            print("已经有这条记录了" + content)
        }
        

        
        
    }
    
    //收到信息后的处理(通知关闭的情况)
    func handleMessageSilent(msg:String,userInfo:[String:Any],time:TimeInterval){
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
            let content = msg
            let msgType = userInfo["msgType"] as! Int64
            let msgId = userInfo["msgId"] as! String
            var imageName = ""
            let isImage = userInfo["isImage"] as! Bool
            if msgType == 1{
                imageName = "boy"
            }else if msgType == 2{
                imageName = "girl"
            }
            
            let conversations = CoreDataManager.shared.getConversationWith(messageId: msgId)
            
            if conversations.count == 0{
                //收到消息保存进度
                CoreDataManager.shared.saveGameProcess()
                //保存会话
                CoreDataManager.shared.saveConversationWith(messageId:msgId,conent: content, headImage: imageName, msgType: msgType, time: Date(),isImage: isImage)
                //发送通知
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receiveMessage"), object: nil, userInfo: userInfo as [AnyHashable : Any])
            }
            
        }
        
        
        
    }
}
