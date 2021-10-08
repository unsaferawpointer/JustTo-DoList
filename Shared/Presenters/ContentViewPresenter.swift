//
//  ContentViewPresenter.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 07.10.2021.
//

import Foundation
import CoreData
import CoreDataStore
import AppKit

protocol ContentView : AnyObject {
	func willReloadContent()
	func didReloadContent()
	func willChangeContent()
	func didChangeContent()
	func didRemoveItems(at indexSet: IndexSet)
	func didInsertItems(at indexSet: IndexSet)
	func didUpdateItems(at indexSet: IndexSet)
	func didSelectItems(at indexSet: IndexSet)
	func didChangeIncompletedTasksCount(newCount: Int)
	func showWarningAllert(with text: String)
	func scrollTo(row: Int)
	func getSelectedRows() -> IndexSet
	#if os(macOS)
	func getClickedRow() -> Int
	#endif
}

class ContentViewPresenter {
	
	weak var view: ContentView?
	
	var sortDescriptors = [NSSortDescriptor(keyPath: \Task.isDone, ascending: true),
						   NSSortDescriptor(keyPath: \Task.completionDate, ascending: true),
						   NSSortDescriptor(keyPath: \Task.isFavorite, ascending: false),
						   NSSortDescriptor(keyPath: \Task.creationDate, ascending: true),
						   NSSortDescriptor(keyPath: \Task.text, ascending: true),
						   NSSortDescriptor(keyPath: \Task.typeMask, ascending: true)]
	
	private var store: AccumulateChangesStore<Task>
	var factory: ObjectFactory<Task>
	
	private var selectedTasks: Set<Task> {
		var expandedIndexSet = view?.getSelectedRows() ?? IndexSet()
		let clickedRow = view?.getClickedRow() ?? (-1)
		if clickedRow >= 0 {
			if !expandedIndexSet.contains(clickedRow) {
				expandedIndexSet = IndexSet(integer: clickedRow)
			}
		}
		return Set(expandedIndexSet.map{ store[$0] })
	}
	
	//private var newestTask: Task? // Last added task
	
	init() {
		let viewContext = CoreDataStorage.shared.mainContext
		store = .init(viewContext: viewContext, sortDescriptors: sortDescriptors)
		factory = .init(viewContext: viewContext)
		store.delegate = self
		factory.errorHandler = { [weak self] error in
			self?.view?.showWarningAllert(with: error.localizedDescription)
		}
	}
	
	func performFetch(with predicate: NSPredicate?, andSortDescriptors sortDescriptors: [NSSortDescriptor]) {
		do {
			try store.performFetch(with: predicate, sortDescriptors: sortDescriptors)
		} catch {
			view?.showWarningAllert(with: error.localizedDescription)
		}
	}
}

extension ContentViewPresenter {
	var numberOfObjects: Int {
		return store.numberOfObjects
	}
	var objects: [Task] {
		return store.objects
	}
}

extension ContentViewPresenter {
	func newTask() {
		factory.newObject()
	}
	func deleteTasks() {
		factory.delete(objects: selectedTasks)
	}
	func duplicateTasks() {
		factory.delete(objects: selectedTasks)
	}
	func moveToFavorites() {
		factory.set(value: true, for: \.isFavorite, to: selectedTasks)
	}
	func moveFromFavorites() {
		factory.set(value: false, for: \.isFavorite, to: selectedTasks)
	}
	func markCompleted() {
		factory.set(value: true, for: \.transientIsDone, to: selectedTasks)
	}
	func markIncomplete() {
		factory.set(value: false, for: \.transientIsDone, to: selectedTasks)
	}
}

extension ContentViewPresenter : AccumulateChangesStoreDelegate {

	func getSelectedRows() -> IndexSet {
		return view?.getSelectedRows() ?? IndexSet()
	}
	
	func accumulateChangesStoreWillChangeContent() {
		view?.willChangeContent()
	}
	
	func accumulateChangesStoreDidChangeContent() {
		view?.didChangeContent()
	}
	
	func accumulateChangesStoreDidInsert(indexSet: IndexSet) {
		view?.didInsertItems(at: indexSet)
	}
	
	func accumulateChangesStoreDidRemove(indexSet: IndexSet) {
		view?.didRemoveItems(at: indexSet)
	}
	
	func accumulateChangesStoreDidUpdate(indexSet: IndexSet) {
		view?.didUpdateItems(at: indexSet)
	}
	
	func accumulateChangesStoreDidReloadContent() {
		view?.didReloadContent()
	}
	
	func accumulateChangesStoreDidSelect(indexSet: IndexSet) {
		view?.didSelectItems(at: indexSet)
	}
}

extension ContentViewPresenter {
	func pasterboardPresentationForTask(at row: Int) -> NSPasteboardWriting? {
		let task = store.objects[row]
		let pasterboardItem = NSPasteboardItem()
		pasterboardItem.setString(task.text, forType: .string)
		return pasterboardItem
	}
}