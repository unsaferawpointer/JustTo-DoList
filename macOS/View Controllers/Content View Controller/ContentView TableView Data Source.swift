//
//  Data Source.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 10.08.2021.
//

import AppKit
import CoreData
import CoreDataStore

extension ContentViewController : NSTableViewDataSource {
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return presenter.numberOfObjects
	}
	
	func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
		let sortDescriptors = tableView.sortDescriptors
		presenter.performFetch(with: nil, andSortDescriptors: sortDescriptors)
	}
	
	func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forRowIndexes rowIndexes: IndexSet) {
		session.draggingFormation = .stack
	}
	
	func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
		return presenter.pasterboardPresentationForTask(at: row)
	}
	
	func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
		return .generic
	}
	
	func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
		return true
	}
}
