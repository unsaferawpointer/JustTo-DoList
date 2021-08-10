//
//  MainWindowController.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 08.08.2021.
//

import Cocoa



class MainWindowController: NSWindowController {
	
	override init(window: NSWindow?) {
		super.init(window: window)
		print(#function)
		//self.window?.toolbar = NSToolbar()
		//self.window?.toolbar?.delegate = self
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func windowDidLoad() {
		print(#function)
		super.windowDidLoad()
		
	}
	
}

//extension MainWindowController : NSToolbarDelegate {
//	
//	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
//		return [.addTask, .searchField]
//	}
//	
//	func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
//		return [.addTask, .searchField]
//	}
//	
//	func toolbar(_ toolbar: NSToolbar,
//				 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
//				 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
//		var toolbarItem: NSToolbarItem?
//		
//		/** Create a new NSToolbarItem instance and set its attributes based on
//		the provided item identifier.
//		*/
//		print(#function)
//		if itemIdentifier == .addTask {
//			// 1) Font style toolbar item.
//			toolbarItem = NSSearchToolbarItem(itemIdentifier: .searchField)
//		} else if itemIdentifier == .searchField {
//			// 2) Font size toolbar item.
//			toolbarItem = NSToolbarItem(itemIdentifier: .searchField)
//			toolbarItem?.target = nil
//			toolbarItem?.image = NSImage(systemSymbolName: "plus", accessibilityDescription: nil)
//		}
//		
//		return toolbarItem
//	}
//	
//	func customToolbarItem(
//		itemForItemIdentifier itemIdentifier: String,
//		label: String,
//		paletteLabel: String,
//		toolTip: String,
//		itemContent: AnyObject) -> NSToolbarItem? {
//		
//		let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(rawValue: itemIdentifier))
//		
//		toolbarItem.label = label
//		toolbarItem.paletteLabel = paletteLabel
//		toolbarItem.toolTip = toolTip
//		toolbarItem.target = self
//		
//		// Set the right attribute, depending on if we were given an image or a view.
//		if itemContent is NSImage {
//			if let image = itemContent as? NSImage {
//				toolbarItem.image = image
//			}
//		} else if itemContent is NSView {
//			if let view = itemContent as? NSView {
//				toolbarItem.view = view
//			}
//		} else {
//			assertionFailure("Invalid itemContent: object")
//		}
//		
//		// We actually need an NSMenuItem here, so we construct one.
//		let menuItem: NSMenuItem = NSMenuItem()
//		menuItem.submenu = nil
//		menuItem.title = label
//		toolbarItem.menuFormRepresentation = menuItem
//		
//		return toolbarItem
//	}
//}
