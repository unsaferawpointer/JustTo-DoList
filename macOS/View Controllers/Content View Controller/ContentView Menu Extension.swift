//
//  Menu Extension.swift
//  CompactToDo
//
//  Created by Anton Cherkasov on 05.05.2021.
//

import AppKit

extension ContentViewController {
	
	func createContextMenu() -> NSMenu {
		let builder = MenuBuilder()
		let menu = builder.createEditMenu()
		return menu
	}
	
}

extension ContentViewController : NSMenuDelegate {
	
	func menuWillOpen(_ menu: NSMenu) {
	}
	
	func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
	}
	
	func menu(_ menu: NSMenu, update item: NSMenuItem, at index: Int, shouldCancel: Bool) -> Bool {
		return true
	}
	
	func menuNeedsUpdate(_ menu: NSMenu) {
	}
}



extension ContentViewController : NSMenuItemValidation {
	func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		if menuItem.identifier == .contextMenuNewTask {
			return true
		}
		if menuItem.identifier == .mainMenuUndo {
			return presenter.undoManager?.canUndo ?? false
		} else if menuItem.identifier == .mainMenuRedo {
			return presenter.undoManager?.canRedo ?? false
		}
		return tableView.clickedOrSelectedIntersection.isEmpty == false
	}
}
