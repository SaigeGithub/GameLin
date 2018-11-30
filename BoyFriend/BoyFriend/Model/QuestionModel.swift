//
//  QuestionModel.swift
//  dbdHd
//
//  Created by dbd on 2018/11/23.
//  Copyright © 2018 dbd. All rights reserved.
//

import UIKit
import HandyJSON

struct QuestionModel: Codable {
    var question = ""
    var answers = [answerModel]()
    
    static func createQuestions(questionType:Int) -> [QuestionModel]?{
        var name = ""
        switch questionType {
        case 0:
            name = "programming"
        case 1:
            name = "art"
        case 2:
            name = "military"
        default:
            break
        }
        let path = Bundle.main.path(forResource: name, ofType: "json")
        let url = URL(fileURLWithPath: path!)
        // 带throws的方法需要抛异常
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            do{
                let beers = try decoder.decode([QuestionModel].self, from: data)
                return beers
            }catch let error as Error?{
                print("解析json出现错误!",error as Any)
            }
            
            
        } catch let error as Error? {
            print("读取本地数据出现错误!",error as Any)
        }
        
        return nil
        
    }
}
struct answerModel: Codable {
    var answerStr = ""
    var correct = false
    var selected = false
    enum CodingKeys: String, CodingKey {
        case answerStr
        case correct

    }
}
