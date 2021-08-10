//
//  TableView Delegate.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 10.08.2021.
//

import AppKit

extension ContentViewController {
	func textCell(in tableView: NSTableView,
				  for task: Task) -> TextCellView {
		let id = NSUserInterfaceItemIdentifier("text_cell")
		var cell = tableView.makeView(withIdentifier: id, owner: nil) as? TextCellView
		if cell == nil {
			cell = TextCellView()
			cell?.set(textStyle: .headline)
			cell?.identifier = id
		}
		cell?.handler = { [weak self] newText in
			self?.factory.set(value: newText, for: \.text, in: task)
		}
		if task.isDone {
			var attributes: [NSAttributedString.Key : Any?] = [:]
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineBreakMode = .byTruncatingTail
			attributes[.foregroundColor] = NSColor.secondaryLabelColor
			attributes[.strikethroughStyle] = 1
			attributes[.paragraphStyle] = paragraphStyle
			let attrString = NSAttributedString(string: task.text, attributes: attributes)
			cell?.textField.attributedStringValue = attrString
		} else {
			cell?.textField?.stringValue = task.text
			cell?.textField?.textColor = .controlTextColor
		}
		return cell!
	}
	
	func checkboxCell(in tableView: NSTableView,
					  for task: Task) -> SwitchCellView {
		let id = NSUserInterfaceItemIdentifier("checkbox_cell")
		var cell = tableView.makeView(withIdentifier: id, owner: nil) as? SwitchCellView
		if cell == nil {
			let button = CheckBox()
			cell = SwitchCellView(button: button)
			cell?.identifier = id
		}
		cell?.completionHandler = { [weak self] isOn in
			CoreDataStorage.shared.mainContext.performAndWait {
				task.setCompletion(isOn)
				try! CoreDataStorage.shared.mainContext.save()
			}
		}
		cell?.set(isOn: task.isDone)
		return cell!
	}
	
	func listCell(in tableView: NSTableView,
				  for task: Task) -> TextCellView {
		let id = NSUserInterfaceItemIdentifier("list_cell")
		var cell = tableView.makeView(withIdentifier: id, owner: nil) as? TextCellView
		if cell == nil {
			cell = TextCellView()
			cell?.set(textStyle: .subheadline)
			cell?.identifier = id
		}
		
		cell?.textField?.textColor = .secondaryLabelColor
		return cell!
	}
	
	func favoriteCell(in tableView: NSTableView,
					  for task: Task) -> SwitchCellView {
		let id = NSUserInterfaceItemIdentifier("favorite_cell")
		var cell = tableView.makeView(withIdentifier: id, owner: nil) as? SwitchCellView
		if cell == nil {
			let starButton = StarButton()
			cell = SwitchCellView(button: starButton)
			cell?.identifier = .checkboxCell
		}
		
		let objectID = task.objectID
		cell?.completionHandler = { newValue in
			task.isFavorite = newValue
			try! CoreDataStorage.shared.mainContext.save()
		}
		cell?.set(isOn: task.isFavorite)
		return cell!
	}
}

extension ContentViewController : NSTableViewDelegate {
	
	func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
		if let id = tableColumn?.identifier, id == .textColumn {
			return true
		}
		return false
	}
	
	func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		return true
	}
	
	func tableView(_ tableView: NSTableView, shouldSelect tableColumn: NSTableColumn?) -> Bool {
		return true
	}
	
	func tableView(_ tableView: NSTableView, shouldShowCellExpansionFor tableColumn: NSTableColumn?, row: Int) -> Bool {
		return true
	}
	
	
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard let id = tableColumn?.identifier else { return nil }
		let task = store.objects[row]
		switch id {
		case .checkboxColumn:
			let cell = checkboxCell(in: tableView, for: task)
			return cell
		case .textColumn:
			let cell = textCell(in: tableView, for: task)
			return cell
		case .listColumn:
			let cell = listCell(in: tableView, for: task)
			return cell
		case .isFavoriteColumn:
			let cell = favoriteCell(in: tableView, for: task)
			return cell
		default:
			return nil
		}
		return NSView()
	}
	
}
