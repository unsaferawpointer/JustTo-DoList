//
//  ContentPresenter.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 24.08.2021.
//

import AppKit
import CoreData

protocol ContentPresenterDelegate : AnyObject {
	func presenterDidChangeContent()
	func presenterWillChangeContent()
	func presenterDidInsert(indexSet: IndexSet)
	func presenterDidRemove(indexSet: IndexSet)
	func presenterDidSelect(indexSet: IndexSet)
	func presenterDidUpdate(indexSet: IndexSet)
	func presenterDidReloadContent()
}

class ContentPresenter<T: NSManagedObject> {
	
	enum ChangeType {
		case insert
		case remove
		case update
	}
	
	struct Change : Hashable {
		let type: ChangeType
		let object: T
		let index: Int
	}
	
	weak var delegate: ContentPresenterDelegate?
	
	let store: Store<T>
	let factory = ObjectFactory<T>.init(persistentContainer: CoreDataStorage.shared.persistentContainer)
	
	init(sortDescriptors: [NSSortDescriptor]) {
		store = Store<T>(viewContext: CoreDataStorage.shared.mainContext, sortBy: sortDescriptors)
		store.delegate = self
	}
	
	// TableView State
	private var selected: Set<T> = []
	private var changes: Set<Change> = []
	
	var isEditing = false

	func selectionDidChanged(newSelection selection: IndexSet) {
		if isEditing == false {
			selected = Set(selection.map{ store.objects[$0] })
			print("selected = \(selected)")
		}
		
	}
	
	#warning("Dont implemented")
	func reloadData() {
		store.performFetch(with: nil, sortDescriptors: [])
	}
	
}

extension ContentPresenter : StoreDataSource {
	
	var objects: [T] {
		return store.objects
	}
	
	var numberOfObjects: Int {
		return store.numberOfObjects
	}
	
	var numberOfSections: Int {
		return store.numberOfSections
	}
	
	func performFetch(with predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]) throws {
		store.performFetch(with: predicate, sortDescriptors: sortDescriptors)
	}
	
}

extension ContentPresenter {
	func selectionIsEmpty() -> Bool {
		return selected.isEmpty
	}
}

extension ContentPresenter : StoreDelegate {
	
	func storeWillChangeContent() {
		isEditing = true
	}
	
	func storeDidRemove(object: NSManagedObject, at index: Int) {
		let change = Change(type: .remove, object: object as! T, index: index)
		changes.insert(change)
	}
	
	func storeDidInsert(object: NSManagedObject, at index: Int) {
		let change = Change(type: .insert, object: object as! T, index: index)
		changes.insert(change)
	}
	
	func storeDidUpdate(object: NSManagedObject, at index: Int) {
		let change = Change(type: .update, object: object as! T, index: index)
		changes.insert(change)
	}
	
	func storeDidMove(object: NSManagedObject, from oldIndex: Int, to newIndex: Int) {
		let insertion = Change(type: .insert, object: object as! T, index: newIndex)
		let deletion = Change(type: .remove, object: object as! T, index: oldIndex)
		changes.insert(insertion)
		changes.insert(deletion)
	}
	
	func storeDidChangeContent() {
		
		let removals = changes.filter{ $0.type == .remove }
		let insertions = changes.filter{ $0.type == .insert }
		let update = changes.filter{ $0.type == .update }
		
		let removedIndexSet = IndexSet(removals.compactMap{ $0.index })
		let insertedIndexSet = IndexSet(insertions.compactMap{ $0.index })
		let updatedIndexSet = IndexSet(update.compactMap{ $0.index })
		
		delegate?.presenterWillChangeContent()
		delegate?.presenterDidRemove(indexSet: removedIndexSet)
		delegate?.presenterDidInsert(indexSet: insertedIndexSet)
		delegate?.presenterDidUpdate(indexSet: updatedIndexSet)
		delegate?.presenterDidChangeContent()
		
		let removedObjects = Set(removals.compactMap{ $0.object })
		let insertedObjects = Set(insertions.compactMap{ $0.object })
		
		let movedObjects = removedObjects.intersection(insertedObjects)
		let selectedMovedObjects = movedObjects.intersection(selected)
		let selectedMovedIndices = selectedMovedObjects.compactMap { store.objects.firstIndex(of: $0)}
		let selectedMovedIndexSet = IndexSet(selectedMovedIndices)
		delegate?.presenterDidSelect(indexSet: selectedMovedIndexSet)
		
		changes.removeAll()
		isEditing = false
	}
	
	func storeDidReloadContent() {
		delegate?.presenterDidReloadContent()
	}
	
}

extension ContentPresenter where T == Task {
	
	func newTask() {
		print(#function)
		factory.newObject()
	}
	
	
	func duplicate() {
		factory.duplicate(objects: selected)
	}
	
	
	func markCompleted() {
		factory.set(value: true, for: \.transientIsDone, to: selected)
	}
	
	
	func markIncomplete() {
		factory.set(value: false, for: \.transientIsDone, to: selected)
	}
	
	
	func toFavorites() {
		factory.set(value: true, for: \.isFavorite, to: selected)
	}
	
	
	func fromFavorites() {
		factory.set(value: false, for: \.isFavorite, to: selected)
	}
	
	
	func delete() {
		factory.delete(objects: selected)
	}
	
	func pasterboardItem(for row: Int) -> NSPasteboardWriting {
		let task = store.objects[row]
		let pasterboardItem = NSPasteboardItem()
		pasterboardItem.setString(task.text, forType: .string)
		return pasterboardItem
	}
}
