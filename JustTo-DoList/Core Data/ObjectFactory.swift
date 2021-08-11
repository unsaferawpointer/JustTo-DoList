//
//  ObjectFactory.swift
//  
//
//  Created by Anton Cherkasov on 29.07.2021.
//

import Foundation
import CoreData

protocol Duplicatable {
	func duplicate() -> Self
}

public class ObjectFactory<T: NSManagedObject> {
	
	public private (set) var viewContext: NSManagedObjectContext
	var errorHandler: ((Error) -> ())?
	
	public init(context: NSManagedObjectContext) {
		self.viewContext = context
	}
	
}

extension ObjectFactory {
	
	public func save() {
		do {
			try viewContext.save()
		} catch {
			errorHandler?(error)
		}
	}
	
	public func updateRelations(of object: T) {
		
		var objectsIDs : Set<NSManagedObjectID> = []
		
		let toOneRelationshipKeys = object.toOneRelationshipKeys
		let toManyRelationshipKeys = object.toManyRelationshipKeys
		
		print("toOneRelationshipKeys = \(toOneRelationshipKeys)")
		print("toManyRelationshipKeys = \(toManyRelationshipKeys)")
		
		for key in toOneRelationshipKeys {
			let relationshipObjectIDs = object.objectIDs(forRelationshipNamed: key)
			for objectID in relationshipObjectIDs {
				objectsIDs.insert(objectID)
			}
		}
		
		for key in toManyRelationshipKeys {
			let relationshipObjectIDs = object.objectIDs(forRelationshipNamed: key)
			for objectID in relationshipObjectIDs {
				objectsIDs.insert(objectID)
			}
		}
		
		print("objectIDs = \(objectsIDs)")
		
		NSLog("objectIDs = %@", objectsIDs)
		
		for objectID in objectsIDs {
			let objectToUpdate = viewContext.object(with: objectID)
			viewContext.refresh(objectToUpdate, mergeChanges: true)
		}
		
	}
	
	@discardableResult
	public func newObject() -> T? {
//		let newObject = T(context: viewContext)
//		try? viewContext.obtainPermanentIDs(for: [newObject])
//		save()
		CoreDataStorage.shared.performBackground { privateContext in
			let newObject = T(context: privateContext)
			try? privateContext.save()
		}
		return nil
	}
	
	public func newObject<Value>(with value: Value, for keyPath: ReferenceWritableKeyPath<T, Value>) -> T {
		let newObject = T(context: viewContext)
		newObject[keyPath: keyPath] = value
		save()
		return newObject
	}
	
//	public func newObject(configurationBlock: (T) -> ()) {
//		let newObject = self.newObject()
//		configurationBlock(newObject)
//		save()
//	}
	
	public func set<Value>(value: Value,
						   for keyPath: ReferenceWritableKeyPath<T, Value>,
						   in object: T,
						   updateRelationships: Bool = false) {
		object[keyPath: keyPath] = value
		save()
//		if updateRelationships {
//			updateRelations(of: object)
//		}
	}
	
	public func delete(object: T) {
		viewContext.delete(object)
		save()
	}
	
	// Batch operation
	
	public func delete(objects: [T]) {
		
		let objectIDs = objects.compactMap{ $0.objectID }
		
		CoreDataStorage.shared.performBackground { privateContext in
			objectIDs.forEach{
				let object = privateContext.object(with: $0)
				privateContext.delete(object)
			}
			try? privateContext.save()
		}
		
	}
	
	public func set<Value>(value: Value, for keyPath: ReferenceWritableKeyPath<T, Value>, to objects: [T]) {
		objects.forEach {
			$0[keyPath: keyPath] = value
		}
		save()
	}
}

extension ObjectFactory where T : Duplicatable {
	@discardableResult
	func duplicate(object: T) -> T {
		let duplicatedObject = object.duplicate()
		try? viewContext.obtainPermanentIDs(for: [duplicatedObject])
		save()
		return duplicatedObject
	}
	@discardableResult
	func duplicate(objects: [T]) -> [T] {
		let duplicatedObjects = objects.compactMap { $0.duplicate() }
		try? viewContext.obtainPermanentIDs(for: duplicatedObjects)
		save()
		return duplicatedObjects
	}
}
