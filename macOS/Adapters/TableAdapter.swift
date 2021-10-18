//
//  File.swift
//  Done-macOS
//
//  Created by Anton Cherkasov on 16.10.2021.
//

import AppKit

protocol TableModel {
	var count: Int { get }
	var cellConfigurator: (NSTableView, Int, NSUserInterfaceItemIdentifier?) -> NSView { get set }
	var dragAndDropConfigurator: (NSTableView, Int) -> NSPasteboardWriting? { get set }
	var reorderConfigurator: (NSTableView, Int, [NSSortDescriptor]) { get set }
}

class TableAdapter: NSObject {
	var model: TableModel!
}

extension TableAdapter: NSTableViewDataSource {
	// Basic Data Source
	func numberOfRows(in tableView: NSTableView) -> Int {
		return model.count
	}
	// Reordering
	func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
		
	}
	// Drag and Drop Operation
	func tableView(_ tableView: NSTableView, updateDraggingItemsForDrag draggingInfo: NSDraggingInfo) {
		
	}
	
	func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
		
	}
	
	func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
		return true
	}
	
	func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forRowIndexes rowIndexes: IndexSet) {
		
	}
	
	func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
		return .copy
	}
	
	func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
		return model.dragAndDropConfigurator(tableView, row)
	}
}

extension TableAdapter : NSTableViewDelegate {
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		return model.cellConfigurator(tableView, row, tableColumn?.identifier)
	}
}
