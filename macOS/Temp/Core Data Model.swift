//
//  Core Data Model.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 08.08.2021.
//

import Foundation
import CoreData

class CoreDataModel {
	init() {
		let model = NSManagedObjectModel()
		
		let taskEntry = NSEntityDescription()
		taskEntry.name = "Task"
		
		let creationTime = NSAttributeDescription()
		creationTime.attributeType = .dateAttributeType
		creationTime.isOptional = false
		
		let nameAttribute = NSAttributeDescription()
		nameAttribute.attributeType = .stringAttributeType
		nameAttribute.defaultValue = "New To Do"
		nameAttribute.isOptional = false
		
		let isFavoriteAttribute = NSAttributeDescription()
		isFavoriteAttribute.attributeType = .booleanAttributeType
		isFavoriteAttribute.defaultValue = false
		
		let isRawDoneAttribute = NSAttributeDescription()
		isRawDoneAttribute.attributeType = .booleanAttributeType
		isRawDoneAttribute.defaultValue = false
		
		
		
		
		
	}
}
