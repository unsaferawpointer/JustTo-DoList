//
//  ObjectFactory.swift
//  
//
//  Created by Anton Cherkasov on 29.07.2021.
//

import Foundation
import CoreData

protocol Duplicatable {
	associatedtype Element
	func duplicate() -> Element
}

public class ObjectFactory<T: NSManagedObject> {
	
	public private (set) var persistentContainer: NSPersistentContainer
	var errorHandler: ((Error) -> ())?
	
	public init(persistentContainer: NSPersistentContainer) {
		self.persistentContainer = persistentContainer
	}
	
}

extension ObjectFactory {
	
//	public func save() {
//		do {
//			try viewContext.save()
//		} catch {
//			errorHandler?(error)
//		}
//	}
	
	private func performInBackground<C: Sequence>(for objects: C, block: @escaping ((NSManagedObjectContext, T) -> ())) where C.Element == T {
		let objectIDs = objects.compactMap{ $0.objectID }
		persistentContainer.performBackgroundTask { [weak self] privateContext in
			for objectID in objectIDs {
				guard let object = privateContext.object(with: objectID) as? T else {
					fatalError("object with objectID = \(objectID) must be \(String(describing: T.self))")
				}
				block(privateContext, object)
			}
			do {
				try privateContext.save()
			} catch {
				self?.errorHandler?(error)
			}
		}
	}
	
	public func newObject() {
		persistentContainer.performBackgroundTask {  privateContext in
			let _ = T(context: privateContext)
			try? privateContext.save()
		}
	}
	
	public func newObject<Value>(with value: Value, for keyPath: ReferenceWritableKeyPath<T, Value>) {
		persistentContainer.performBackgroundTask {  privateContext in
			let newObject = T(context: privateContext)
			newObject[keyPath: keyPath] = value
			try? privateContext.save()
		}
	}
	
	public func newObject(configurationBlock: @escaping (T) -> ()) {
		persistentContainer.performBackgroundTask { [weak self] privateContext in
			let newObject = T(context: privateContext)
			configurationBlock(newObject)
			do {
				try privateContext.save()
			} catch {
				self?.errorHandler?(error)
			}
		}
	}
	
	public func set<Value>(value: Value,
						   for keyPath: ReferenceWritableKeyPath<T, Value>,
						   in object: T,
						   updateRelationships: Bool = false) {
		performInBackground(for: [object]) { context, object in
			object[keyPath: keyPath] = value
		}
	}
	
	public func delete(object: T) {
		performInBackground(for: [object]) { context, object in
			context.delete(object)
		}
	}
	
	// Batch operation
	
	public func delete(objects: Set<T>) {
		performInBackground(for: objects) { context, object in
			context.delete(object)
		}
	}
	
	public func set<Value>(value: Value, for keyPath: ReferenceWritableKeyPath<T, Value>, to objects: Set<T>) {
		performInBackground(for: objects) { context, object in
			object[keyPath: keyPath] = value
		}
	}
}

extension ObjectFactory where T : Duplicatable {
	
	func duplicate(object: T) {
		performInBackground(for: [object]) { context, object in
			let _ = object.duplicate()
		}
	}
	
	func duplicate(objects: Set<T>) {
		performInBackground(for: objects) { context, object in
			let _ = object.duplicate()
		}
	}
}
