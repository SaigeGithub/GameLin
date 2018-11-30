//
//  GameProcess+CoreDataProperties.swift
//  
//
//  Created by 谢馆长 on 2018/10/24.
//
//

import Foundation
import CoreData


extension GameProcess {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GameProcess> {
        return NSFetchRequest<GameProcess>(entityName: "GameProcess")
    }

    @NSManaged public var boyName: String?
    @NSManaged public var gameId: Int64
    @NSManaged public var girlName: String?
    @NSManaged public var process: Int64
    @NSManaged public var score: Int64

}
