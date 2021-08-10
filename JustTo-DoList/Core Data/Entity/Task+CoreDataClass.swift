//
//  Task+CoreDataClass.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 09.08.2021.
//
//

import Foundation
import CoreData

@objc(Task)
public class Task: NSManagedObject {
	public override func awakeFromInsert() {
		super.awakeFromInsert()
		
		self.id = UUID()
		self.text = "New To Do"
		self.isDone = true
		self.creationDate = Date()
		self.completionDate = nil
		self.isFavorite = false
		self.typeMask = 0
	}
}

extension Task : Duplicatable {
	func duplicate() -> Self {
		return self
	}
}
