//
//  CoreDataManager.swift
//  BoyFriend
//
//  Created by 谢馆长 on 2018/10/15.
//  Copyright © 2018年 谢馆长. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    // 单例
    static let shared = CoreDataManager()
    
    //coreData
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "Conversation", withExtension: "momd")
        let managedObjectModel = NSManagedObjectModel.init(contentsOf: modelURL!)
        return managedObjectModel!
    }()
    
    //    懒加载持久化存储协调器NSPersistentStoreCoordinator
    //    sqliteURL是sqlite文件的路径
    //    documentDir是后面加载好了的Document路径
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator.init(managedObjectModel: managedObjectModel)
        let sqliteURL = documentDir.appendingPathComponent("Conversation.sqlite")
        let options = [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true]
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: sqliteURL, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: Any]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as Any?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as Any?
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 6666, userInfo: dict)
            
            abort()
        }
        return persistentStoreCoordinator
    }()
    
    lazy var documentDir: URL = {
        let documentDir = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
        return documentDir!
    }()
    
    //    懒加载NSManagedObjectContext
    lazy var context: NSManagedObjectContext = {
        let context = NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        return context
    }()
    
//    // 拿到AppDelegate中创建好了的NSManagedObjectContext
//    lazy var context: NSManagedObjectContext = {
//
//        let context = ((UIApplication.shared.delegate) as! AppDelegate).context
//        return context
//    }()
    
    // 更新数据
    private func saveContext() {
        do {
            try self.context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
    }
    
    // 增加会话数据
    func saveConversationWith(messageId:String,conent: String, headImage: String,msgType:Int64,time:Date,isImage:Bool) {
        let conversation = NSEntityDescription.insertNewObject(forEntityName: "Conversation", into: context) as! Conversation
        conversation.content = conent
        conversation.headImage = headImage
        conversation.msgType = msgType
        conversation.time = time
        conversation.messageId = messageId
        conversation.isImage = isImage
        conversation.cellHeight = getCellHeight(content: conent, isImage: isImage,msgType: msgType)
        if msgType == 1 || msgType == 2{
            conversation.bubbleWidth = getBubbleWidth(conent)
        }
        
        saveContext()
        
    }
    
    //计算cell高度存储在模型中
    func getCellHeight(content:String,isImage:Bool,msgType:Int64) -> Float{
        
        var height:Float = 0
        if content.count > 0{
            
            switch msgType{
            case 0:
                height = Float(content.getSpaceLabelHeight(fontSize: 12, width: SCREENWIDTH-30, lineSpace: 5)) + 20

            case 1,2:
                height =  Float(content.ga_heightForComment(fontSize: 14, width: SCREENWIDTH-155)) + 80
            default:break
                
            }
            
        }
        if  isImage == true{
            let image = UIImage(named: content)
            
            let heightScale = image!.size.height/image!.size.width
            height = Float(100 * heightScale)
        }
        return Float(height)
        
    }
    //计算气泡宽度
    func getBubbleWidth(_ msg:String) -> Float{
        var width =  msg.ga_widthForComment(fontSize: 14) + 35
        if width > SCREENWIDTH - 130{
            width = UIScreen.main.bounds.size.width - 130
        }else{
            
            let timeWidth = "yyyy-MM-dd hh:mm:ss".ga_widthForComment(fontSize: 12)
            if width < timeWidth{
                width = CGFloat(timeWidth)
            }else{
                width = CGFloat(width)
            }
        }
        
        return Float(width)
    }
    
    
    // 获取所有数据
    func getAllConversation() -> [Conversation] {
        let fetchRequest: NSFetchRequest = Conversation.fetchRequest()
        
        let sort = NSSortDescriptor.init(key: "time", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        do {
            let result = try context.fetch(fetchRequest)
            
            return result
        } catch {
            fatalError();
        }
    }
    
    // 根据消息获取数据
    func getConversationWith(messageId: String) -> [Conversation] {
        let fetchRequest: NSFetchRequest = Conversation.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "messageId == %@", messageId)
        do {
            let result: [Conversation] = try context.fetch(fetchRequest)
            return result
        } catch {
            fatalError();
        }
    }

    // 删除所有数据
    func deleteAllConversation() {
        // 这里直接调用上面获取所有数据的方法
        let result = getAllConversation()
        
        // 循环删除所有数据
        for conversation in result {
            context.delete(conversation)
        }
        saveContext()
    }
    
    
    
    //游戏数据
    
    // 开始新游戏,保存一条游戏记录
    func startGameProcessWith(boyName:String,girlName:String,gameId:Int64) {
        //删掉所有游戏记录
        deleteAllGameRecord()
        //新增一条记录
        let game = NSEntityDescription.insertNewObject(forEntityName: "GameProcess", into: context) as! GameProcess
        game.process = 0
        game.score = 0
        game.boyName = boyName
        game.girlName = girlName
        game.gameId  = gameId
        saveContext()
        
    }
    // 保存游戏进度
    func saveGameProcess() {
        let fetchRequest: NSFetchRequest = GameProcess.fetchRequest()
        
        do {
            // 拿到符合条件的所有数据
            let result = try context.fetch(fetchRequest)
            for game in result {
                // 循环修改
                game.process += 1
                print("现在进度是" + "\(game.process)")
            }
        } catch {
            fatalError();
        }
        saveContext()
    }
    // 保存游戏好感度
    func saveGameScoreWith(score: Int64) {
        let fetchRequest: NSFetchRequest = GameProcess.fetchRequest()
        
        do {
            // 拿到符合条件的所有数据
            let result = try context.fetch(fetchRequest)
            for game in result {
                // 循环修改
                game.score += score
            }
        } catch {
            fatalError();
        }
        saveContext()
    }
    
    
    // 获取所有游戏记录
    func getAllGameRecord() -> [GameProcess] {
        let fetchRequest: NSFetchRequest = GameProcess.fetchRequest()
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch {
            fatalError();
        }
    }
    // 获取一条游戏记录
    func getLastGameRecord() -> GameProcess? {
        let fetchRequest: NSFetchRequest = GameProcess.fetchRequest()
        do {
            let result = try context.fetch(fetchRequest)
            if result.count > 0{
                return result[0]
            }
        } catch {
            fatalError();
        }
        return nil 
    }
    // 获取好感度
    func getGameScore() -> Int64 {
        let fetchRequest: NSFetchRequest = GameProcess.fetchRequest()
        do {
            let result = try context.fetch(fetchRequest)
            if result.count > 0{
                let record = result[0]
                return record.score
            }else{
                return 0
            }
        } catch {
            fatalError();
        }
    }
    
    // 删除游戏数据
    func deleteAllGameRecord() {
        // 这里直接调用上面获取所有数据的方法
        let result = getAllGameRecord()
        
        // 循环删除所有数据
        for record in result {
            context.delete(record)
        }
        saveContext()
    }
    
    
}
