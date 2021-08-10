//
//  AppDelegate.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 08.08.2021.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

	private var window: NSWindow?
	private var windowController: NSWindowController?

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
		
		let size = CGSize(width: 600, height: 600)
		let rect = NSRect(origin: .zero, size: size)
		
		var styleMask: NSWindow.StyleMask = []
		styleMask.insert(.miniaturizable)
		styleMask.insert(.closable)
		styleMask.insert(.resizable)
		styleMask.insert(.titled)
		styleMask.insert(.fullSizeContentView)

		window = NSWindow(contentRect: rect,
						  styleMask: styleMask,
						  backing: .buffered,
						  defer: false)
		window?.center()
		window?.setFrameAutosaveName("main_window")
		window?.isRestorable = true
		window?.identifier = NSUserInterfaceItemIdentifier("main_window")
		window?.toolbarStyle = .unified
		window?.titlebarSeparatorStyle = .automatic
		window?.titleVisibility = .visible
		window?.contentViewController = MainSplitViewController()
		windowController = MainWindowController(window: window)
		windowController?.shouldCascadeWindows = false
		windowController?.showWindow(nil)
		
		let toolbar = NSToolbar()
		toolbar.sizeMode = .regular
		toolbar.displayMode = .iconOnly
		toolbar.delegate = self
		window?.toolbar = toolbar
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}
	
	func setupMainMenu() {
		let menu = NSMenu()
		menu.addItem(NSMenuItem(title: "Задания", action: nil, keyEquivalent: ""))
		//NSApplication.shared.mainMenu = menu
		NSApp.menu = menu
	}
	

//	func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
//	    // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
//	    return persistentContainer.viewContext.undoManager
//	}

	func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
	    // Save changes in the application's managed object context before the application terminates.
		let canTerminate = CoreDataStorage.shared.canTerminate(sender)
		return canTerminate ? .terminateNow : .terminateCancel
	}

}

private extension NSToolbarItem.Identifier {
	static let addTask		= NSToolbarItem.Identifier(rawValue: "addTask")
	static let searchField	= NSToolbarItem.Identifier(rawValue: "searchField")
}

extension AppDelegate : NSToolbarDelegate {
	
	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return [.toggleSidebar, .flexibleSpace, .searchField, .addTask]
	}
	
	func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return [.toggleSidebar, .flexibleSpace, .searchField, .addTask]
	}
	
	func toolbar(_ toolbar: NSToolbar,
				 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
				 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
		var toolbarItem: NSToolbarItem?
		if itemIdentifier == .searchField {
			let searchFieldItem = NSSearchToolbarItem(itemIdentifier: .searchField)
			searchFieldItem.searchField.centersPlaceholder = true
			searchFieldItem.searchField.placeholderString = NSLocalizedString("toolbar_searchfield_placeholder", comment: "")
			toolbarItem = searchFieldItem
			
		} else if itemIdentifier == .addTask {
			toolbarItem = NSToolbarItem(itemIdentifier: .addTask)
			if let image = NSImage(systemSymbolName: "plus", accessibilityDescription: nil) {
				let button = NSButton(image: image, target: nil, action: #selector(addTask(_:)))
				button.bezelStyle = .recessed
				button.showsBorderOnlyWhileMouseInside = true
				button.isBordered = true
				button.controlSize = .large
				toolbarItem?.view = button
			}
		}
		return toolbarItem
	}
	
	@objc func addTask(_ sender: Any?) {
		
	}
	
}


