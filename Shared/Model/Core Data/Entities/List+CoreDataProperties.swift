//
//  List+CoreDataProperties.swift
//  Done
//
//  Created by Anton Cherkasov on 21.10.2021.
//
//

import Foundation
import CoreData


extension List {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<List> {
        return NSFetchRequest<List>(entityName: "List")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var tasks: NSSet?
	
	public override func awakeFromInsert() {
		super.awakeFromInsert()
		self.id = UUID()
		self.name = NSLocalizedString(.newList, comment: "")
	}
	
	public override func awakeFromFetch() {
		super.awakeFromFetch()
	}

}

// MARK: Generated accessors for tasks
extension List {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: Task)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: Task)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}

extension List : Identifiable {

}
