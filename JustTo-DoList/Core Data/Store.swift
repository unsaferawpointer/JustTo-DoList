//
//  NotesStore.swift
//  Just Notepad
//
//  Created by Anton Cherkasov on 12.06.2021.
//
#if os(macOS)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif

import CoreData

public protocol StoreDataSource {
	associatedtype T: NSManagedObject
	var objects: [T] { get }
	var numberOfObjects: Int { get }
	var numberOfSections: Int { get }
	func performFetch(with predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]) throws
}

extension StoreDataSource {
	func objects(for indexSet: IndexSet) -> [T] {
		return indexSet.compactMap{ objects[$0]}
	}
	var objectsIDs: [NSManagedObjectID] {
		return objects.compactMap { $0.objectID }
	}
}

public protocol StoreDelegate : AnyObject {
	func storeWillChangeContent()
	func storeDidRemove(object: NSManagedObject, at index: Int)
	func storeDidInsert(object: NSManagedObject, at index: Int)
	func storeDidUpdate(object: NSManagedObject, at index: Int)
	func storeDidMove(object: NSManagedObject, from oldIndex: Int, to newIndex: Int)
	func storeDidChangeContent()
	func storeDidReloadContent()
}

public class Store<T: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
	
	struct SortDescriptor<Value> {
		var keyPath: ReferenceWritableKeyPath<T, Value>
		var asceding: Bool = true
		init(keyPath: ReferenceWritableKeyPath<T, Value>, asceding: Bool) {
			self.keyPath = keyPath
			self.asceding = asceding
		}
	}
	
	public weak var delegate: StoreDelegate?
	
	private var fetchedResultController: NSFetchedResultsController<T>
	private var viewContext: NSManagedObjectContext
	
	public var errorHandler: ((Error) -> ())?
	
	public init(viewContext: NSManagedObjectContext, sortBy sortDescriptors: [NSSortDescriptor]) {
		self.viewContext = viewContext
		let fetchRequest: NSFetchRequest<T> = NSFetchRequest<T>.init(entityName: T.className())
		fetchRequest.sortDescriptors = sortDescriptors
		
		self.fetchedResultController = NSFetchedResultsController.init(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
		
		super.init()
		
		self.fetchedResultController.delegate = self
	}
	
	public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate?.storeWillChangeContent()
		print(#function)
	}
	
	//#if os(macOS)
	public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		print(#function)
		print("oldPath = \(indexPath) newPath = \(newIndexPath)")
		guard let object = anObject as? T else {
			fatalError("\(anObject) is not \(T.className())")
		}
		switch type {
		case .insert:
			print(".insert")
			if let newIndex = newIndexPath?.item {
				delegate?.storeDidInsert(object: object, at: newIndex)
			}
		case .delete:
			print(".delete")
			if let oldIndex = indexPath?.item {
				delegate?.storeDidRemove(object: object, at: oldIndex)
			}
		case .move:
			print(".move")
			if let oldIndex = indexPath?.item, let newIndex = newIndexPath?.item {
				delegate?.storeDidMove(object: object, from: oldIndex, to: newIndex)
			}
		case .update:
			print(".update")
			if let oldIndex = indexPath?.item {
				delegate?.storeDidUpdate(object: object, at: oldIndex)
			}
		@unknown default:
			fatalError()
		}
	}
	//#endif
	
	public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate?.storeDidChangeContent()
		print(#function)
	}
	
}

extension Store : StoreDataSource {
	public var numberOfObjects : Int {
		return fetchedResultController.fetchedObjects?.count ?? 0
	}
	
	public var numberOfSections: Int {
		return fetchedResultController.sections?.count ?? 0
	}

	public var objects: [T] {
		return fetchedResultController.fetchedObjects ?? []
	}
	
	/// Perform fetch and call 'storeDidReloadContent' of the delegate
	public func performFetch(with predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = []) {
		fetchedResultController.fetchRequest.predicate = predicate
		if !sortDescriptors.isEmpty {
			fetchedResultController.fetchRequest.sortDescriptors = sortDescriptors
		}
		do {
			try fetchedResultController.performFetch()
		} catch {
			errorHandler?(error)
		}
		delegate?.storeDidReloadContent()
	}
	
}


