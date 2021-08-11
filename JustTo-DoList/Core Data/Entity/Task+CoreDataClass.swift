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
	
}

extension Task : Duplicatable {
	func duplicate() -> Self {
		guard let context = managedObjectContext else {
			fatalError("managedObjectContext don't exist")
		}
		let duplicated = Task(context: context)
		duplicated.text = text
		duplicated.transientIsDone = isDone
		duplicated.isFavorite = isFavorite
		duplicated.typeMask = typeMask
		return self
	}
}
