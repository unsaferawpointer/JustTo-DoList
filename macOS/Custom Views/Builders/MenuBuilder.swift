//
//  MainMenuBuilder.swift
//  Done-macOS
//
//  Created by Anton Cherkasov on 16.10.2021.
//

import Foundation
import AppKit

class MenuBuilder : NSObject {
	
	var menu = NSMenu()
	
	func createEditMenu() -> NSMenu {
		let menu = NSMenu(title: "Edit")
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
		delete.action = #selector(ContentViewController.delete(_:))
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
