//
//  SidebarView Menu Extension.swift
//  Done-macOS
//
//  Created by Anton Cherkasov on 21.10.2021.
//

import AppKit

extension NSUserInterfaceItemIdentifier {
	static let menuNewList = NSUserInterfaceItemIdentifier("menu_new_list")
}

extension SidebarViewController {
	
	func createEditMenu() -> NSMenu {
		
		let menu = NSMenu(title: "Edit")
		// ******** New List ********
		let newList = NSMenuItem()
		newList.identifier = .menuNewList
		newList.title = NSLocalizedString(.menuNewList, comment: "")
		newList.action = #selector(SidebarViewController.newList(_:))
		newList.keyEquivalent = "n"
		menu.addItem(newList)
//		// ******** Duplicate ********
//		let duplicate = NSMenuItem()
//		duplicate.title = NSLocalizedString(.menuDuplicateTask, comment: "")
//		duplicate.action = #selector(ContentViewController.duplicate(_:))
//		duplicate.keyEquivalent = "d"
//		menu.addItem(duplicate)
		// ******** Separator ********
		menu.addItem(NSMenuItem.separator())
		
		let renameList = NSMenuItem()
		renameList.title = NSLocalizedString(.menuRenameList, comment: "")
		renameList.action = #selector(SidebarViewController.renameList(_:))
		renameList.keyEquivalent = .carriageReturnKey
		menu.addItem(renameList)
		// ******** Separator ********
		menu.addItem(NSMenuItem.separator())
		let deleteList = NSMenuItem()
		deleteList.title = NSLocalizedString(.menuDeleteList, comment: "")
		deleteList.action = #selector(SidebarViewController.delete(_:))
		deleteList.keyEquivalent = .backspaceKey
		menu.addItem(deleteList)
		return menu
	}
	
}

extension SidebarViewController {
	@objc func newList(_ sender: Any?) {
		presenter.newObject()
	}
	
	@objc func delete(_ sender: Any?) {
		let selectedRows = outlineView.clickedOrSelectedIntersection
		let items = selectedRows.map{ outlineView.item(atRow: $0) }
		guard items.count <= 1 else {
			fatalError("Dont support multiselection")
		}
		presenter.delete(object: items.first)
	}
	
	@objc func renameList(_ sender: Any?) {
		
	}
	
	@objc func duplicateList(_ sender: Any?) {
		
	}
}
