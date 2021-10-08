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
		createWindow()
		windowController = MainWindowController(window: window)
		windowController?.shouldCascadeWindows = false
		windowController?.showWindow(self)
		setupMainMenu()
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
	
	private func createWindow() {
		let size = CGSize(width: 600, height: 600)
		let rect = NSRect(origin: .zero, size: size)
		var styleMask: NSWindow.StyleMask = []
		styleMask.insert(.miniaturizable)
		styleMask.insert(.closable)
		styleMask.insert(.resizable)
		styleMask.insert(.titled)
		styleMask.insert(.fullSizeContentView)
		styleMask.insert(.unifiedTitleAndToolbar)
		window = NSWindow(contentRect: rect,
						  styleMask: styleMask,
						  backing: .buffered,
						  defer: false)
		window?.center()
		window?.titleVisibility = .visible
		window?.titlebarAppearsTransparent = false
		window?.setFrameAutosaveName("main_window")
		window?.isRestorable = true
		window?.identifier = NSUserInterfaceItemIdentifier("main_window")
		window?.toolbarStyle = .unified
		window?.tabbingMode = .disallowed
		window?.titlebarSeparatorStyle = .automatic
		window?.contentViewController = MainSplitViewController()
		let toolbar = NSToolbar()
		toolbar.sizeMode = .regular
		toolbar.displayMode = .iconOnly
		toolbar.delegate = self
		window?.toolbar = toolbar
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
	static let addTask		= NSToolbarItem.Identifier(rawValue: "newTask")
	static let searchField	= NSToolbarItem.Identifier(rawValue: "searchField")
}

extension NSNotification.Name {
	static let newTask		= NSNotification.Name("newTask")
}

extension AppDelegate : NSToolbarDelegate {
	
	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return [.toggleSidebar, .flexibleSpace, .addTask]
	}
	
	func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return [.toggleSidebar, .flexibleSpace, .addTask]
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
				let button = NSButton(image: image, target: nil, action: #selector(newTask(_:)))
				button.bezelStyle = .recessed
				button.showsBorderOnlyWhileMouseInside = true
				button.isBordered = true
				button.controlSize = .large
				toolbarItem?.view = button
			}
		}
		return toolbarItem
	}
	
	@objc func newTask(_ sender: Any?) {
		NSApp.sendAction(#selector(newTask(_:)), to: nil, from: self)
	}
	
}


