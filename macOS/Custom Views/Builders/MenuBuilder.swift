//
//  MainMenuBuilder.swift
//  Done-macOS
//
//  Created by Anton Cherkasov on 16.10.2021.
//

import Foundation
import AppKit

extension NSUserInterfaceItemIdentifier {
	static let contextMenuNewTask = NSUserInterfaceItemIdentifier("context_menu_new_task")
	static let mainMenuRedo = NSUserInterfaceItemIdentifier("main_menu_redo")
	static let mainMenuUndo = NSUserInterfaceItemIdentifier("main_menu_undo")
}

class MenuBuilder : NSObject {
	
	var menu = NSMenu()
	
	func createEditMenu() -> NSMenu {
		
		let menu = NSMenu(title: "Edit")
		let undo = NSMenuItem()
		undo.identifier = .mainMenuUndo
		undo.title = NSLocalizedString(.mainMenuUndo, comment: "")
		undo.action = #selector(ContentViewController.undo(_:))
		undo.keyEquivalent = "z"
		menu.addItem(undo)
		let redo = NSMenuItem()
		redo.identifier = .mainMenuRedo
		redo.title = NSLocalizedString(.mainMenuRedo, comment: "")
		redo.action = #selector(ContentViewController.redo(_:))
		redo.keyEquivalent = "Z"
		menu.addItem(redo)
		// ******** Separator ********
		menu.addItem(NSMenuItem.separator())
		// ******** New Task ********
		let newTask = NSMenuItem()
		newTask.identifier = .contextMenuNewTask
		newTask.title = NSLocalizedString(.menuNewTask, comment: "")
		newTask.action = #selector(ContentViewController.newTask(_:))
		newTask.keyEquivalent = "n"
		menu.addItem(newTask)
		// ******** Duplicate ********
		let duplicate = NSMenuItem()
		duplicate.title = NSLocalizedString(.menuDuplicateTask, comment: "")
		duplicate.action = #selector(ContentViewController.duplicate(_:))
		duplicate.keyEquivalent = "d"
		menu.addItem(duplicate)
		// ******** Separator ********
		menu.addItem(NSMenuItem.separator())
		let selectAll = NSMenuItem()
		selectAll.title = NSLocalizedString("menu_select_all", comment: "")
		selectAll.target = nil
		selectAll.action = #selector(NSTableView.selectAll(_:))
		menu.addItem(selectAll)
		// ******** Separator ********
		menu.addItem(NSMenuItem.separator())
		// ******** Mark completed / incomplete ********
		let markCompleted = NSMenuItem()
		markCompleted.title = NSLocalizedString(.menuMarkTaskCompleted, comment: "")
		markCompleted.action = #selector(ContentViewController.markCompleted(_:))
		markCompleted.keyEquivalent = .carriageReturnKey
		menu.addItem(markCompleted)
		let markUncompleted = NSMenuItem()
		markUncompleted.title = NSLocalizedString(.menuMarkTaskIncomplete, comment: "")
		markUncompleted.action = #selector(ContentViewController.markIncomplete(_:))
		markUncompleted.keyEquivalent = .carriageReturnKey
		markUncompleted.keyEquivalentModifierMask = [.command, .shift]
		menu.addItem(markUncompleted)
		// ******** Separator ********
		menu.addItem(NSMenuItem.separator())
		// ******** Favorites ********
		let toFavorites = NSMenuItem()
		toFavorites.title = NSLocalizedString(.menuMoveTaskToFavorites, comment: "")
		toFavorites.action = #selector(ContentViewController.toFavorites(_:))
		menu.addItem(toFavorites)
		let fromFavorites = NSMenuItem()
		fromFavorites.action = #selector(ContentViewController.fromFavorites(_:))
		fromFavorites.title = NSLocalizedString(.menuMoveTaskFromFavorites, comment: "")
		menu.addItem(fromFavorites)
		// ******** Separator ********
		menu.addItem(NSMenuItem.separator())
		// ******** Delete ********
		let delete = NSMenuItem()
		delete.title = NSLocalizedString(.menuDeleteTask, comment: "")
		delete.keyEquivalent = .backspaceKey
		delete.action = Selector("delete:")
		menu.addItem(delete)
		return menu
	}
	
	func createMainMenu() -> NSMenu {
		let menu = NSMenu(title: "Done")
		// ******** About ********
		let about = NSMenuItem()
		about.title = NSLocalizedString(.mainMenuItemAbout, comment: "")
		about.action = nil
		menu.addItem(about)
		// ******** Separator ********
		menu.addItem(NSMenuItem.separator())
		// ******** Preferences ********
		let preferences = NSMenuItem()
		preferences.title = NSLocalizedString(.mainMenuItemPreferences, comment: "")
		preferences.action = nil
		preferences.keyEquivalent = ","
		menu.addItem(preferences)
		// ******** Separator ********
		menu.addItem(NSMenuItem.separator())
		// ******** Quit ********
		let quit = NSMenuItem()
		quit.title = NSLocalizedString(.mainMenuItemQuit, comment: "")
		quit.action = nil
		quit.keyEquivalent = "q"
		menu.addItem(quit)
		return menu
	}
}
