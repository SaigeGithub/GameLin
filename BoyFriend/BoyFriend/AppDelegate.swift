//
//  AppDelegate.swift
//  BoyFriend
//
//  Created by 谢冠章 on 2018/10/11.
//  Copyright © 2018年 谢馆长. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData
import GoogleMobileAds
//import AVOSCloud

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var allowRotation = false
    var allowNotification = false


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerNotification()
        
        // Initialize the Google Mobile Ads SDK.
        // Sample AdMob app ID: ca-app-pub-3940256099942544~1458002511
        
        GADMobileAds.configure(withApplicationID: admobAppId)

        
        //leancloud
//        AVOSCloud.setApplicationId("7SO8G7MrAXhvEYVjn8fGVzgr-gzGzoHsz", clientKey: "NIGdK3aJ0rxqsWXCBbMfUmgy")
        //已经收到的通知
        NotificationHelp.shared.center.getDeliveredNotifications { (notifications) in
            
            for notification in notifications{
                 NotificationHelp.shared.handleMessage(notification: notification)
            }
            NotificationHelp.shared.center.removeAllDeliveredNotifications()
        }

        return true
    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if allowRotation == true{
            return .all
        }else{
            return .portrait
        }
    }
    //注册通知
    func registerNotification(){
        NotificationHelp.shared.center.requestAuthorization(options: [.alert, .sound]) { (succ, error) in
            if succ == false{
                print("没有打开通知")
                DispatchQueue.main.async {
//                    没有打开通知的情况下,检查游戏进度,继续游戏
                    self.contiuneGame()
                }
            }else{
                print("打开了通知")
            }
            self.allowNotification = succ
        }
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("回到前台")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enterForeGround"), object: nil)
        //已经收到的通知
        NotificationHelp.shared.center.getDeliveredNotifications { (notifications) in
            NotificationHelp.shared.notificationTaped = true
            for notification in notifications{
                NotificationHelp.shared.handleMessage(notification: notification)
            }
            
            NotificationHelp.shared.center.removeAllDeliveredNotifications()
        }
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationHelp.shared.center.requestAuthorization(options: [.alert, .sound]) { (succ, error) in
            
            self.allowNotification = succ
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
      
        
    }


    
    func contiuneGame(){
        let storyBook = story.chineseScript
        
        if let record = CoreDataManager.shared.getLastGameRecord(){
            let progress = record.process
            let fullStory = storyBook?.questions
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
                let boyName = storyBook!.boyName
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
                                            time += 1
                                            if let message = msg.message{
                                                NotificationHelp.shared.sendSystemMessage(msg: message, time: time)
                                            }
                                            if let sleep = story.sleep{
                                                
                                                time += TimeInterval(sleep)
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
                                        if let sleep = story.sleep{
                                            
                                            time += TimeInterval(sleep)
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


