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
		return presenter.store.numberOfObjects
	}
	
	func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
		let sortDescriptors = tableView.sortDescriptors
		presenter.store.performFetch(with: nil, sortDescriptors: sortDescriptors)
	}
	
	func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
		presenter.pasterboardItem(for: row)
	}
	
	func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
		return .copy
	}
}

extension ContentViewController : ContentPresenterDelegate {
	
	func presenterWillChangeContent() {
		tableView.beginUpdates()
	}
	
	func presenterDidInsert(indexSet: IndexSet) {
		tableView.insertRows(at: indexSet, withAnimation: .slideRight)
	}
	
	func presenterDidRemove(indexSet: IndexSet) {
		tableView.removeRows(at: indexSet, withAnimation: .slideLeft)
	}
	
	func presenterDidUpdate(indexSet: IndexSet) {
		let columnIndexes = IndexSet(integersIn: 0..<tableView.numberOfColumns)
		tableView.reloadData(forRowIndexes: indexSet, columnIndexes: columnIndexes)
	}
	
	func presenterDidChangeContent() {
		tableView.endUpdates()
	}
	
	func presenterDidReloadContent() {
		tableView.reloadData()
	}
	
	func presenterDidSelect(indexSet: IndexSet) {
		tableView.selectRowIndexes(indexSet, byExtendingSelection: true)
	}
}
