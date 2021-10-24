//
//  SidebarViewPresenter.swift
//  Done
//
//  Created by Anton Cherkasov on 20.10.2021.
//

import Foundation
import CoreDataStore
import CoreData

enum SidebarItem {
	case inbox
	case favorites
	case completed
	case list(value: List)
}

class Node {
	var title: String = "Title"
	var children: [Node] = []
	weak var parent: Node? = nil
}

class StoreNode: Node {
	
}

enum ItemBase {
	
	case inbox
	case favorites
	case completed
	
	var title: String {
		switch self {
		case .inbox:
			return NSLocalizedString(.sidebarInbox, comment: "")
		case .favorites:
			return NSLocalizedString(.sidebarFavorites, comment: "")
		case .completed:
			return NSLocalizedString(.sidebarCompleted, comment: "")
		}
	}
	
	var predicate: NSPredicate? {
		switch self {
		case .inbox:
			return nil
		case .favorites:
			return NSPredicate(format: "isFavorite = %@", argumentArray: [true])
		case .completed:
			return NSPredicate(format: "isDone = %@", argumentArray: [true])
		}
	}
}

class DividerItem {
	
}

class Item {
	var base: ItemBase
	init(base: ItemBase) {
		self.base = base
	}
}

class ListSection {
	var store: Store<List> = .init(viewContext: CoreDataManager.shared.mainContext, sortBy: [NSSortDescriptor(keyPath: \List.name, ascending: true)])
	init() {
		try? store.performFetch(with: nil, sortDescriptors: [])
	}
}

class BasicSection {
	var items = [Item(base: .inbox), Item(base: .favorites), Item(base: .completed)]
}

protocol SidebarView : AnyObject {
	
}

protocol OutlineView : AnyObject {
	func didReload()
	func willChangeContent()
	func didChangeContent()
	func removeItems(at indexSet: IndexSet, inParent parent: Any?)
	func insertItems(at indexSet: IndexSet, inParent parent: Any?)
	func reload(item: Any?)
}

class SidebarViewPresenter {
	
	var sections: [Any] = [Item(base: .inbox), Item(base: .favorites), Item(base: .completed)]
	
	let factory: ObjectFactory<List>
	weak var view: OutlineView?
	var listSection: ListSection
	
	init() {
		let viewContext = CoreDataManager.shared.mainContext
		factory = .init(viewContext: viewContext)
		listSection = ListSection()
		listSection.store.delegate = self
		sections.append(listSection)
	}
}

extension SidebarViewPresenter: StoreDelegate {
	func storeWillChangeContent() {
		view?.willChangeContent()
	}
	
	func storeDidRemove(object: NSManagedObject, at index: Int) {
		view?.removeItems(at: IndexSet(integer: index), inParent: listSection)
	}
	
	func storeDidInsert(object: NSManagedObject, at index: Int) {
		view?.insertItems(at: IndexSet(integer: index), inParent: listSection)
	}
	
	func storeDidUpdate(object: NSManagedObject, at index: Int) {
		view?.reload(item: object)
	}
	
	func storeDidMove(object: NSManagedObject, from oldIndex: Int, to newIndex: Int) {
		view?.removeItems(at: IndexSet(integer: oldIndex), inParent: listSection)
		view?.insertItems(at: IndexSet(integer: newIndex), inParent: listSection)
	}
	
	func storeDidChangeContent() {
		view?.didChangeContent()
	}
	
	func storeDidReloadContent() {
		view?.didReload()
	}
}

extension SidebarViewPresenter {
	func select(object: Any?) {
		NotificationCenter.default.post(name: .sidebarDidChangeSelectedItem, object: nil, userInfo: ["selected_item" :object])
	}
}

extension SidebarViewPresenter {
	func rename(object: Any?) {
		
	}
	func delete(object: Any?) {
		guard let list = object as? List else {
			fatalError("Dont support \(object.self)")
		}
		factory.delete(object: list)
	}
	func newObject() {
		factory.newObject()
	}
	func dropObjects(withURLs urls: [URL], to parent: Any?) {
		guard let list = parent as? List else { return }
		let persistentStoreCoordinator = CoreDataManager.shared.persistentContainer.persistentStoreCoordinator
		let objectIDs = urls.compactMap { persistentStoreCoordinator.managedObjectID(forURIRepresentation: $0) }
		let objects = objectIDs.compactMap{ try? CoreDataManager.shared.mainContext.object(with: $0) as? Task }
		objects.forEach{ $0.list = list }
		try? CoreDataManager.shared.mainContext.save()
	}
}

#if os(macOS)
extension SidebarViewPresenter {
	func item(child index: Int, ofItem item: Any?) -> Any {
		if let section = item as? BasicSection {
			return section.items[index]
		} else if let section = item as? ListSection {
			return section.store[index]
		}
		return sections[index]
	}
	func numberOfChildren(ofItem item: Any?) -> Int {
		if let section = item as? BasicSection {
			return section.items.count
		} else if let section = item as? ListSection {
			return section.store.numberOfObjects
		}
		return sections.count
	}
	func isItemExpandable(item: Any) -> Bool {
		if let section = item as? BasicSection {
			return section.items.count > 0
		} else if let section = item as? ListSection {
			return section.store.numberOfObjects > 0
		}
		return false
	}
	func isHeader(item: Any) -> Bool {
		if let section = item as? BasicSection {
			return true
		} else if let section = item as? ListSection {
			return true
		}
		return false
	}
}
#endif
