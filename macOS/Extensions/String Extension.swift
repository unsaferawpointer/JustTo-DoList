//
//  String Extension.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 07.10.2021.
//

import AppKit

extension String {
	static let carriageReturnKey = String(utf16CodeUnits: [unichar(NSCarriageReturnCharacter)], count: 1)
	static let backspaceKey = String(utf16CodeUnits: [unichar(NSBackspaceCharacter)], count: 1)
	
	static var navigationItemMyDay = "navigation_item_my_day"
	static var navigationItemFavorites = "navigation_item_favorites"
	static var navigationItemCompleted = "navigation_item_completed"
	static var navigationItemAll = "navigation_item_all"
	
	static var headerFavorites = "header_favorites"
	static var headerLists = "header_lists"
	
	// Menu
	
	static let newList = "new_list"
	
	static var menuNewTask = "menu_new_task"
	static var menuDeleteTask = "menu_delete_task"
	static var menuDuplicateTask = "menu_duplicate_task"
	
	static var menuMarkTaskCompleted = "menu_mark_task_completed"
	static var menuMarkTaskIncomplete = "menu_mark_task_incomplete"
	
	static var menuMoveToMyDay = "menu_move_to_my_day"
	static var menuRemoveFromMyDay = "menu_remove_from_my_day"
	
	static var menuMoveTaskToFavorites = "menu_move_task_to_favorites"
	static var menuMoveTaskFromFavorites = "menu_move_task_from_favorites"
	
	static var menuMoveTo = "menu_move_to"
	
	static let menuNewList = "menu_new_list"
	static let menuDeleteList = "menu_delete_list"
	static let menuRenameList = "menu_rename_list"
	
	// Main Menu
	static var mainMenuItemAbout = "main_menu_item_about"
	static var mainMenuItemPreferences = "main_menu_item_preferences"
	static var mainMenuItemQuit = "main_menu_item_quit"
	
	static var mainMenuUndo = "main_menu_undo"
	static var mainMenuRedo = "main_menu_redo"
	static let selectAll = "menu_select_all"
	
	// Sidebar View
	static var sidebarInbox = "sidebar_inbox"
	static var sidebarFavorites = "sidebar_favorites"
	static var sidebarCompleted = "sidebar_completed"
}
