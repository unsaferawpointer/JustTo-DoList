//
//  Data Source.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 10.08.2021.
//

import AppKit
import CoreData

//extension ContentViewController : NSTableViewDataSource {
//	func numberOfRows(in tableView: NSTableView) -> Int {
//		return store.numberOfObjects
//	}
//}

extension ContentViewController {
	
	var selectedTasks: [Task] {
		let indexSet = tableView.clickedOrSelectedIntersection
		
		return indexSet.compactMap{ dataSource.itemIdentifier(forRow: $0) }
			.compactMap{ viewContext.object(with: $0) as? Task }
	}
	
	func configureDataSource() {
		let dataSource : NSTableViewDiffableDataSource<String, NSManagedObjectID> = .init(tableView: tableView) { table, column, index, objectID in
//			let request = NSFetchRequest<Task>()
//			request.entity = Task.entity()
//			request.predicate = NSPredicate(format: "id = %@", argumentArray: [objectID])
			
			guard let task = try? self.viewContext.existingObject(with: objectID) as? Task else {
				return NSView()
			}
			let cell = self.create(viewFor: column, task: task)
			return cell
		}
		dataSource.defaultRowAnimation = .effectGap
		dataSource.sectionHeaderViewProvider = { (table, index, identifier) -> NSView in
			let container = NSView()
			container.translatesAutoresizingMaskIntoConstraints = false
			let label = NSTextField(labelWithString: identifier)
			label.font = NSFont.preferredFont(forTextStyle: .headline, options: [:])
			label.textColor = .secondaryLabelColor
			label.translatesAutoresizingMaskIntoConstraints = false
			container.addSubview(label)
			container.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
			container.leadingAnchor.constraint(equalTo: label.leadingAnchor).isActive = true
			container.trailingAnchor.constraint(equalTo: label.trailingAnchor).isActive = true
			return container
		}
		
		self.dataSource = dataSource
		
	}
	
}

extension ContentViewController : StoreDelegate {
	
	func storeWillChangeContent() {
		//tableView.beginUpdates()
	}
	
	func storeDidInsert(section: NSFetchedResultsSectionInfo, at index: Int) {
		
	}
	
	func storeDidDelete(section: NSFetchedResultsSectionInfo, at index: Int) {
		
	}
	
	func storeDidDelete(object: NSManagedObject, at index: Int) {
//		tableView.removeRows(at: IndexSet(integer: index), withAnimation: .effectFade)
	}
	
	func storeDidInsert(object: NSManagedObject, at index: Int) {
//		tableView.insertRows(at: IndexSet(integer: index), withAnimation: .effectFade)
	}
	
	func storeDidUpdate(object: NSManagedObject, at index: Int) {
//		let columnIndexes = IndexSet(integersIn: 0..<tableView.numberOfColumns)
//		tableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: columnIndexes)
	}
	
	func storeDidMove(object: NSManagedObject, from oldIndex: Int, to newIndex: Int) {
//		tableView.moveRow(at: oldIndex, to: newIndex)
	}
	
	func storeDidChangeContent() {
//		tableView.endUpdates()
		var newSnapshot = NSDiffableDataSourceSnapshot<String, NSManagedObjectID>()
		
		let completed = store.objects.filter{ $0.isDone == true }.compactMap{ $0.objectID }
		
		newSnapshot.appendSections(["current"])
		newSnapshot.appendItems(store.objects.filter{ $0.isDone == false }.compactMap{ $0.objectID }, toSection: "current")
		if !completed.isEmpty {
			newSnapshot.appendSections(["completed"])
			newSnapshot.appendItems(completed, toSection: "completed")
		}
		
		print("before Selected = \(tableView.selectedRowIndexes))")
		DispatchQueue.main.async { [weak self] in
			self?.dataSource.apply(newSnapshot, animatingDifferences: true)
		}
		
		print("after Selected = \(tableView.selectedRowIndexes))")
	}
	
	func storeDidReloadContent() {
		
		var snapshot = NSDiffableDataSourceSnapshot<String, NSManagedObjectID>()
		
		let completed = store.objects.filter{ $0.isDone == true }.compactMap{ $0.objectID }
		
		snapshot.appendSections(["current"])
		snapshot.appendItems(store.objects.filter{ $0.isDone == false }.compactMap{ $0.objectID }, toSection: "current")
		if !completed.isEmpty {
			snapshot.appendSections(["completed"])
			snapshot.appendItems(completed, toSection: "completed")
		}
		
		print("before Selected = \(tableView.selectedRowIndexes))")
		
		dataSource.apply(snapshot, animatingDifferences: false)
		print("after Selected = \(tableView.selectedRowIndexes))")
		
	}
	
	func storeDidChangeContent(with snapshot: NSDiffableDataSourceSnapshotReference) {
		
		
	}
	
}
