//
//  Task+CoreDataProperties.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 09.08.2021.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var id: UUID
    @NSManaged public var text: String
    @NSManaged public private (set) var isDone: Bool
    @NSManaged public var creationDate: Date
    @NSManaged public private (set) var completionDate: Date?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var typeMask: Int16

}

extension Task : Identifiable {

}
