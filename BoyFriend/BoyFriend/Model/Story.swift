//
//  Story.swift
//  BoyFriend
//
//  Created by 谢冠章 on 2018/10/16.
//  Copyright © 2018年 谢馆长. All rights reserved.
//

import UIKit
//import AVOSCloud

////消息类型
//enum messageType:Int64,Decodable {
//
//    case systemMsg = 0
//    case yourMsg = 1
//    case myMsg = 2
//    //    case photoMsg = 3
//}

//问题
struct question: Decodable {
    var messageId:Int64?
    var messageType:Int64?
    var branchScore: Int64?
    var sleep: Int64?
    var messages:[answer]?
    var end:String?
}

//答案
struct answer: Decodable {
    var score:Int64 = 0
    var message:String?
    var image:String?
}
//剧本
struct story: Decodable{
    var boyName:String?
    var girlName:String?
    var boyImageName:String?
    var girlImageName:String?
    var questions:[question]?
    
    static let chineseScript = story().chineseScript()
//    static let englishScript = story().englishScript()
    

    
   func chineseScript() -> story?{
  
        let path = Bundle.main.path(forResource: "chinese", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        // 带throws的方法需要抛异常
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            do{
                let beers = try decoder.decode(story.self, from: data)
                return beers
            }catch let error as Error?{
                print("解析json出现错误!",error as Any)
            }


        } catch let error as Error? {
            print("读取本地数据出现错误!",error as Any)
        }

        return nil
    }
   static func englishScript() -> story?{
        let path = Bundle.main.path(forResource: "english", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        // 带throws的方法需要抛异常
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            do{
                let beers = try decoder.decode(story.self, from: data)
                return beers
            }catch let error as Error?{
                print("解析json出现错误!",error as Any)
            }
            
            
        } catch let error as Error? {
            print("读取本地数据出现错误!",error as Any)
        }
        
        return nil
    }
    //解析下载好的剧本
    static func converDownloadedJsonToModel(url:URL) -> story?{
        // 带throws的方法需要抛异常
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            do{
                let beers = try decoder.decode(story.self, from: data)
                return beers
            }catch let error as Error?{
                print("解析json出现错误!",error as Any)
            }
            
            
        } catch let error as Error? {
            print("读取本地数据出现错误!",error as Any)
        }
        
        return nil
    }
    
    
    //查询是否有英文剧本
    static func converEnglishJsonToModel() -> Bool{
        
        let path = Bundle.main.path(forResource: "english", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        // 带throws的方法需要抛异常
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            do{
                let beers = try decoder.decode(story.self, from: data)
                if beers.questions!.count > 0{
                    return true
                }else{
                    return false
                }
            }catch let error as Error?{
                print("解析json出现错误!",error as Any)
                return false
            }
            
            
        } catch let error as Error? {
            print("读取本地数据出现错误!",error as Any)
            return false
        }
        
        
    }
}


