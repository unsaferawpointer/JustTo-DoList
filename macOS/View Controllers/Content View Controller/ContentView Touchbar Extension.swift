//
//  ContentViewController Touchbar Extension.swift
//  CompactToDo
//
//  Created by Anton Cherkasov on 04.08.2021.
//

import AppKit

private extension NSTouchBar.CustomizationIdentifier {
	static let touchBar = "com.ToolbarSample.touchBar"
}

extension NSTouchBarItem.Identifier {
	static let complete = NSTouchBarItem.Identifier("com.antoncherkasov.TouchBarItem.complete")
	static let newTask = NSTouchBarItem.Identifier("com.antoncherkasov.TouchBarItem.newTask")
	static let toFavorite = NSTouchBarItem.Identifier("com.antoncherkasov.TouchBarItem.toFavorite")
	static let fromFavorite = NSTouchBarItem.Identifier("com.antoncherkasov.TouchBarItem.fromFavorite")
	static let delete = NSTouchBarItem.Identifier("com.antoncherkasov.TouchBarItem.delete")
}

extension ContentViewController : NSTouchBarDelegate {
	/// - Tag: CreateTouchBar
	override func makeTouchBar() -> NSTouchBar? {
		let touchBar = NSTouchBar()
		touchBar.delegate = self
		touchBar.customizationIdentifier = .touchBar
		touchBar.defaultItemIdentifiers = [.newTask,
										   .fixedSpaceSmall,
										   .toFavorite, .fromFavorite,
										   .fixedSpaceSmall,
										   .delete,
										   NSTouchBarItem.Identifier.otherItemsProxy]
		touchBar.customizationAllowedItemIdentifiers = [.newTask, .complete]
		
		return touchBar
	}
	
	func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
		switch identifier {
		case NSTouchBarItem.Identifier.complete:
			
			let popoverItem = NSPopoverTouchBarItem(identifier: identifier)
			popoverItem.customizationLabel = NSLocalizedString("Font Size", comment: "")
			popoverItem.collapsedRepresentationLabel = NSLocalizedString("Font Size", comment: "")
			
			let secondaryTouchBar = NSTouchBar()
			secondaryTouchBar.delegate = self
			secondaryTouchBar.defaultItemIdentifiers = [.toFavorite]
			
			/** We can setup a different NSTouchBar instance for popoverTouchBar and pressAndHoldTouchBar
			property. Here we just use the same instance.
			*/
			popoverItem.pressAndHoldTouchBar = secondaryTouchBar
			popoverItem.popoverTouchBar = secondaryTouchBar
			
			return popoverItem
			
		case NSTouchBarItem.Identifier.newTask:
			let completionItem = NSCustomTouchBarItem(identifier: identifier)
			completionItem.customizationLabel = NSLocalizedString("Font Style", comment: "")
			
			let button = NSButton(title: "New Task", target: self, action: #selector(newTask(_:)))
			
			completionItem.view = button
			
			return completionItem
			
		case NSTouchBarItem.Identifier.toFavorite:
			
			let toFavoriteItem = NSCustomTouchBarItem(identifier: identifier)
			toFavoriteItem.customizationLabel = NSLocalizedString("Font Style", comment: "")
			
			let button = NSButton(image: NSImage(systemSymbolName: "star.fill", accessibilityDescription: nil)!, target: self, action: #selector(toFavorites(_:)))
			button.contentTintColor = .systemYellow
			
			toFavoriteItem.view = button
			
			return toFavoriteItem
			
		case NSTouchBarItem.Identifier.fromFavorite:
			
			let fromFavoriteItem = NSCustomTouchBarItem(identifier: identifier)
			fromFavoriteItem.customizationLabel = NSLocalizedString("Font Style", comment: "")
			
			let button = NSButton(image: NSImage(systemSymbolName: "star", accessibilityDescription: nil)!, target: self, action: #selector(fromFavorites(_:)))
			button.contentTintColor = .systemYellow
			
			fromFavoriteItem.view = button
			
			return fromFavoriteItem
			
		case NSTouchBarItem.Identifier.delete:
			
			let fromFavoriteItem = NSCustomTouchBarItem(identifier: identifier)
			fromFavoriteItem.customizationLabel = NSLocalizedString("Font Style", comment: "")
			
			let button = NSButton(image: NSImage(systemSymbolName: "trash", accessibilityDescription: nil)!, target: self, action: #selector(delete(_:)))
			button.contentTintColor = .systemYellow
			
			fromFavoriteItem.view = button
			
			return fromFavoriteItem
			
		default: return nil
		}
	}
	
	
}
