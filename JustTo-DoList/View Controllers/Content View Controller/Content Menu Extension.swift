//
//  Menu Extension.swift
//  CompactToDo
//
//  Created by Anton Cherkasov on 05.05.2021.
//

import AppKit

extension NSUserInterfaceItemIdentifier {
	static let contextMenuNewTask = NSUserInterfaceItemIdentifier("context_menu_new_task")
}

extension ContentViewController {
	
	var contextMenu: NSMenu {
		// ******** Keys ********
		let carriageReturnKey = String(utf16CodeUnits: [unichar(NSCarriageReturnCharacter)], count: 1)
		let backspaceKey = String(utf16CodeUnits: [unichar(NSBackspaceCharacter)], count: 1)
		
		let menu = NSMenu()
		menu.delegate = self
		
		// ******** New Task ********
		let newTask = NSMenuItem()
		newTask.identifier = .contextMenuNewTask
		newTask.title = NSLocalizedString(.menuNewTask, comment: "")
		newTask.action = #selector(newTask(_:))
		newTask.keyEquivalent = "n"
		menu.addItem(newTask)
		
		// ******** Duplicate ********
		
		let duplicate = NSMenuItem()
		duplicate.title = NSLocalizedString(.menuDuplicateTask, comment: "")
		duplicate.action = #selector(duplicate(_:))
		duplicate.keyEquivalent = "d"
		menu.addItem(duplicate)
		
		// ******** Separator ********
		menu.addItem(NSMenuItem.separator())
		
		// ******** Mark completed ********
		let markCompleted = NSMenuItem()
		markCompleted.title = NSLocalizedString(.menuMarkTaskCompleted, comment: "")
		markCompleted.action = #selector(markCompleted(_:) as (Any?) -> ())
		markCompleted.keyEquivalent = carriageReturnKey
		menu.addItem(markCompleted)
		
		// ******** Mark uncompleted ********
		let markUncompleted = NSMenuItem()
		markUncompleted.title = NSLocalizedString(.menuMarkTaskIncomplete, comment: "")
		markUncompleted.action = #selector(markIncomplete(_:))
		markUncompleted.keyEquivalent = carriageReturnKey
		markUncompleted.keyEquivalentModifierMask = [.command, .shift]
		menu.addItem(markUncompleted)
		
		// ******** Separator ********
		menu.addItem(NSMenuItem.separator())
		
		// ******** My Day ********
		let moveToMyDay = NSMenuItem()
		moveToMyDay.title = NSLocalizedString(.menuMoveToMyDay, comment: "")
		moveToMyDay.action = #selector(moveToMyDay(_:))
		moveToMyDay.keyEquivalent = carriageReturnKey
		moveToMyDay.keyEquivalentModifierMask = [.command, .shift]
		menu.addItem(moveToMyDay)
		
		let removeFromMyDay = NSMenuItem()
		removeFromMyDay.title = NSLocalizedString(.menuRemoveFromMyDay, comment: "")
		removeFromMyDay.action = #selector(removeFromMyDay(_:))
		removeFromMyDay.keyEquivalent = carriageReturnKey
		removeFromMyDay.keyEquivalentModifierMask = [.command, .shift]
		menu.addItem(removeFromMyDay)
		
		// ******** Separator ********
		menu.addItem(NSMenuItem.separator())
		
		// ******** Favorites ********
		let toFavorites = NSMenuItem()
		toFavorites.title = NSLocalizedString(.menuMoveTaskToFavorites, comment: "")
		toFavorites.action = #selector(toFavorites(_:))
		menu.addItem(toFavorites)
		
		let fromFavorites = NSMenuItem()
		fromFavorites.action = #selector(fromFavorites(_:))
		fromFavorites.title = NSLocalizedString(.menuMoveTaskFromFavorites, comment: "")
		menu.addItem(fromFavorites)
		
		// ******** Separator ********
		menu.addItem(NSMenuItem.separator())
		
		// ******** Delete ********
		let delete = NSMenuItem()
		delete.title = NSLocalizedString(.menuDeleteTask, comment: "")
		delete.keyEquivalent = backspaceKey
		delete.action = #selector(delete(_:))
		menu.addItem(delete)
		
		return menu
	}
	
}

extension ContentViewController : NSMenuDelegate {
	
	func menuWillOpen(_ menu: NSMenu) {
		let clickedRow = tableView.clickedRow
		
		//        if clickedRow >= 0, dataSource.sectionIdentifier(forRow: clickedRow) != nil {
		//            menu.items.forEach{ $0.isHidden = true }
		//        } else {
		//            menu.items.forEach{ $0.isHidden = false }
		//        }
	}
	
	func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
		print(#function)
		print("item = \(item)")
	}
	
	func menu(_ menu: NSMenu, update item: NSMenuItem, at index: Int, shouldCancel: Bool) -> Bool {
		return true
	}
	
	func menuNeedsUpdate(_ menu: NSMenu) {
		print(#function)
		print("menu = \(menu)")
		
		//        for item in menu.items {
		//            if item.identifier == NSUserInterfaceItemIdentifier("move_to") {
		//                item.submenu?.removeAllItems()
		//                print("move_to")
		//                do {
		//                    let fetchRequest : NSFetchRequest<List>  = List.fetchRequest()
		//                    fetchRequest.sortDescriptors = [NSSortDescriptor.init(keyPath: \List.name, ascending: true)]
		//                    if let folders = try? CoreDataManager.shared.viewContext.fetch(fetchRequest) {
		//
		//                        for index in 0..<folders.count {
		//                            print(index)
		//                            let newItem = NSMenuItem(title: folders[index].name, action: #selector(setList(_:)), keyEquivalent: "")
		//                            newItem.tag = index
		//                            newItem.representedObject = folders[index]
		//                            item.submenu?.addItem(newItem)
		//
		//                        }
		//                    }
		//                }
		//            }
		//        }
		
		
		
		
		
		//        for item in menu.items {
		//            if item.identifier?.rawValue == "group_by" {
		//
		//            } else {
		//                item.isEnabled = clickedSelectedIntersectedTasks().isEmpty == false
		//            }
		//        }
	}
}



extension ContentViewController : NSMenuItemValidation {
	func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		if menuItem.identifier == .contextMenuNewTask {
			return true
		}
		return tableView.clickedOrSelectedIntersection.isEmpty == false
	}
}

// ******** Context Menu ********

extension ContentViewController {
	
	@IBAction
	func newTask(_ sender: Any?) {
		presenter.newObject()
	}
	
	@IBAction
	func duplicate(_ sender: Any?) {
		let indexSet = tableView.clickedOrSelectedIntersection
		presenter.duplicateTasks(for: indexSet)
	}
	
	@IBAction
	func markCompleted(_ sender: Any?) {
		let indexSet = tableView.clickedOrSelectedIntersection
		presenter.set(value: true, for: \.isDone, indexSet: indexSet)
	}
	
	@IBAction
	func markIncomplete(_ sender: Any?) {
		let indexSet = tableView.clickedOrSelectedIntersection
		presenter.set(value: false, for: \.isDone, indexSet: indexSet)
	}
	
	@IBAction
	func moveToMyDay(_ sender: Any?) {
		let indexSet = tableView.clickedOrSelectedIntersection
		presenter.set(value: true, for: \.isMyDay, indexSet: indexSet)
	}
	
	@IBAction
	func removeFromMyDay(_ sender: Any?) {
		let indexSet = tableView.clickedOrSelectedIntersection
		presenter.set(value: false, for: \.isMyDay, indexSet: indexSet)
	}
	
	@IBAction
	func toFavorites(_ sender: Any?) {
		let indexSet = tableView.clickedOrSelectedIntersection
		presenter.set(value: true, for: \.isFavorite, indexSet: indexSet)
	}
	
	@IBAction
	func fromFavorites(_ sender: Any?) {
		let indexSet = tableView.clickedOrSelectedIntersection
		presenter.set(value: false, for: \.isFavorite, indexSet: indexSet)
	}
	
	@IBAction
	func delete(_ sender: Any?) {
		let indexSet = tableView.clickedOrSelectedIntersection
		presenter.deleteTasks(for: indexSet)
	}
}