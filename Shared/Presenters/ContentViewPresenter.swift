//
//  ContentViewPresenter.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 07.10.2021.
//

import Foundation
import CoreData
import CoreDataStore

extension NSNotification.Name {
	static let sidebarDidChangeSelectedItem = NSNotification.Name("sidebarDidChangeSelectedItem")
}

protocol ContentCellRepresentable : AnyObject {
	func configureCell(with task: Task)
}

protocol TableView : AnyObject {
	func willReloadContent()
	func didReloadContent()
	func willChangeContent()
	func didChangeContent()
	func didRemoveItems(at indexSet: IndexSet)
	func didInsertItems(at indexSet: IndexSet)
	func didUpdateItems(at indexSet: IndexSet)
	func didSelectItems(at indexSet: IndexSet)
	func didChangeTasksCounts(incomplete: Int, all: Int)
	func scrollTo(row: Int)
	func getSelectedRows() -> IndexSet
	#if os(macOS)
	func getClickedRow() -> Int
	#endif
}

protocol DragAndDropView: AnyObject {
	func startExecuting()
	func stopExecuting()
	func update(progress: Double)
}

protocol ContentView: TableView, DragAndDropView {
	func showWarningAllert(with text: String)
}

class ContentViewPresenter {
	
	weak var view: ContentView?
	
	var sortDescriptors = [NSSortDescriptor(keyPath: \Task.isDone, ascending: true),
						   NSSortDescriptor(keyPath: \Task.completionDate, ascending: true),
						   NSSortDescriptor(keyPath: \Task.isFavorite, ascending: false),
						   NSSortDescriptor(keyPath: \Task.creationDate, ascending: true),
						   NSSortDescriptor(keyPath: \Task.text, ascending: true),
						   NSSortDescriptor(keyPath: \Task.typeMask, ascending: true)]
	
	private (set) var store: AccumulateChangesStore<Task>
	private (set) var factory: ObjectFactory<Task>
	
	var undoManager : UndoManager? {
		CoreDataManager.shared.mainContext.undoManager
	}
	
	private var selectedTasks: Set<Task> {
		var expandedIndexSet = view?.getSelectedRows() ?? IndexSet()
		if let clickedRow = view?.getClickedRow(), clickedRow >= 0 {
			if !expandedIndexSet.contains(clickedRow) {
				expandedIndexSet = IndexSet(integer: clickedRow)
			}
		}
		return Set(expandedIndexSet.map{ store[$0] })
	}
	
	init() {
		let viewContext = CoreDataManager.shared.mainContext
		store = .init(viewContext: viewContext, sortDescriptors: sortDescriptors)
		factory = .init(viewContext: viewContext)
		store.delegate = self
		factory.errorHandler = { [weak self] error in
			self?.view?.showWarningAllert(with: error.localizedDescription)
		}
		NotificationCenter.default.addObserver(self, selector: #selector(sidebarDidChangePredicate(_:)), name: .sidebarDidChangeSelectedItem, object: nil)
	}
	
	@objc func sidebarDidChangePredicate(_ notification: NSNotification) {
		let item = notification.userInfo?["selected_item"]
		let predicate = getPredicate(for: item)
		try? store.performFetch(with: predicate, sortDescriptors: [])
	}
	
	func getPredicate(for object: Any?) -> NSPredicate? {
		if let list = object as? List {
			let predicate = NSPredicate(format: "list = %@", argumentArray: [list])
			return predicate
		} else if let item = object as? Item {
			return item.base.predicate
		}
		return nil
	}
}

extension ContentViewPresenter {
	
	var numberOfObjects: Int {
		return store.numberOfObjects
	}
	var objects: [Task] {
		return store.objects
	}
	
	func performFetch(with predicate: NSPredicate?, andSortDescriptors sortDescriptors: [NSSortDescriptor]) {
		do {
			try store.performFetch(with: predicate, sortDescriptors: sortDescriptors)
		} catch {
			view?.showWarningAllert(with: error.localizedDescription)
		}
	}
	
	var incompleteCount : Int {
		return store.objects.filter{ $0.isDone == false }.count
	}

	private func updateTasksCounts() {
		
		view?.didChangeTasksCounts(incomplete: incompleteCount, all: store.numberOfObjects)
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
		updateTasksCounts()
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
	func configure(cell: ContentCellRepresentable, at row: Int) {
		let task = store[row]
		cell.configureCell(with: task)
	}
}

import AppKit
// Drop And Drop Support
extension ContentViewPresenter {
	func pasterboardPresentationForTask(at row: Int) -> NSPasteboardWriting? {
		let task = store.objects[row]
		let text = "\(task.text)\n"
		let pasterboardItem = NSPasteboardItem()
		pasterboardItem.setString(text, forType: .string)
		let url = task.objectID.uriRepresentation().absoluteString
		pasterboardItem.setString(url, forType: .taskID)
		return pasterboardItem
	}
	
	func registeredDraggedTypes() -> [NSPasteboard.PasteboardType] {
		return [.string]
	}
	
	func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
		view?.startExecuting()
		let importer = TasksImporter { [weak self] progress in
			self?.view?.update(progress: progress)
		} completionBlock: { [weak self] in
			self?.view?.stopExecuting()
		}
		if let text = sender.draggingPasteboard.string(forType: .string) {
			importer.importItems(from: text)
		}
		return true
	}
	
	func cancelImporting() {
		
	}
}

extension ContentViewPresenter {
	
}

