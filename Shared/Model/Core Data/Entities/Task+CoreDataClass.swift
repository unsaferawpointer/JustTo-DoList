//
//  Task+CoreDataClass.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 09.08.2021.
//
//

import Foundation
import CoreData
import CoreDataStore
import AppKit

@objc(Task)
public class Task: NSManagedObject {
	var listName: String?
}

extension Task : Duplicatable {
	public func duplicate() -> Self {
		guard let context = managedObjectContext else {
			fatalError("managedObjectContext don't exist")
		}
		if let duplicated = Task(context: context) as? Self {
			duplicated.text = text
			duplicated.transientIsDone = isDone
			duplicated.isFavorite = isFavorite
			duplicated.typeMask = typeMask
			return duplicated
		}
		fatalError("Your type is not the same as Self")
	}
}

extension Task {
	public override var description: String {
		return
				"""
				
				id = \(objectID)
				text = \(text)
				list = \(list?.name)
				"""
	}
}
