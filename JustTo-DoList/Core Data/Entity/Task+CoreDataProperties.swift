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

    @NSManaged public private (set) var id: UUID
    @NSManaged public var text: String
    @NSManaged public private (set) var isDone: Bool
    @NSManaged public private (set) var creationDate: Date
    @NSManaged public private (set) var completionDate: Date?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var typeMask: Int16
	
	public override func awakeFromInsert() {
		super.awakeFromInsert()
		self.id = UUID()
		self.text = "New To Do"
		self.isDone = false
		self.creationDate = Date()
		self.completionDate = nil
		self.isFavorite = false
		self.typeMask = 0
	}
	
	func setCompletion(_ isDone: Bool) {
		if self.isDone != isDone {
			self.completionDate = isDone ? Date() : nil
		}
		self.isDone = isDone
	}

}

extension Task : Identifiable {

}
