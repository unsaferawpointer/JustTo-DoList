//
//  Data Source.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 10.08.2021.
//

import AppKit
import CoreData

extension ContentViewController : NSTableViewDataSource {
	func numberOfRows(in tableView: NSTableView) -> Int {
		return store.numberOfObjects
	}
}

extension ContentViewController : StoreDelegate {
	
	func storeWillChangeContent() {
		tableView.beginUpdates()
	}
	
	func storeDidInsert(section: NSFetchedResultsSectionInfo, at index: Int) {
		
	}
	
	func storeDidDelete(section: NSFetchedResultsSectionInfo, at index: Int) {
		
	}
	
	func storeDidDelete(object: NSManagedObject, at index: Int) {
		tableView.removeRows(at: IndexSet(integer: index), withAnimation: .effectFade)
	}
	
	func storeDidInsert(object: NSManagedObject, at index: Int) {
		tableView.insertRows(at: IndexSet(integer: index), withAnimation: .effectFade)
	}
	
	func storeDidUpdate(object: NSManagedObject, at index: Int) {
		let columnIndexes = IndexSet(integersIn: 0..<tableView.numberOfColumns)
		tableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: columnIndexes)
	}
	
	func storeDidMove(object: NSManagedObject, from oldIndex: Int, to newIndex: Int) {
		tableView.moveRow(at: oldIndex, to: newIndex)
	}
	
	func storeDidChangeContent() {
		tableView.endUpdates()
	}
	
	func storeDidReloadContent() {
		tableView.reloadData()
	}
	
	func storeDidChangeContent(with snapshot: NSDiffableDataSourceSnapshotReference) {
		
	}
	
}
