//
//  Conversation+CoreDataProperties.swift
//  
//
//  Created by 谢冠章 on 2018/10/26.
//
//

import Foundation
import CoreData


extension Conversation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Conversation> {
        return NSFetchRequest<Conversation>(entityName: "Conversation")
    }

    @NSManaged public var content: String?
    @NSManaged public var headImage: String?
    @NSManaged public var isImage: Bool
    @NSManaged public var messageId: String?
    @NSManaged public var msgType: Int64
    @NSManaged public var time: NSDate?
    @NSManaged public var cellHeight: Float
    @NSManaged public var bubbleWidth: Float

}
