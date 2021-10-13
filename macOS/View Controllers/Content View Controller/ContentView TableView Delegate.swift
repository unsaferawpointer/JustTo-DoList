//
//  TableView Delegate.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 10.08.2021.
//

import AppKit

extension ContentViewController {
	
	func create(viewFor tableColumn: NSTableColumn?, task: Task) -> NSView {
		guard let columnId = tableColumn?.identifier else {
			return NSView()
		}
		switch columnId {
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
			return NSView()
		}
	}
	
	private func makeCell<T: NSTableCellView>(ofType: T.Type, in tableView: NSTableView, withRawID rawID: String, initBlock: (() -> T)? = nil) -> T {
		let id = NSUserInterfaceItemIdentifier(rawID)
		var cell = tableView.makeView(withIdentifier: id, owner: nil) as? T
		if cell == nil {
			if let initBlock = initBlock {
				cell = initBlock()
			} else {
				cell = T()
			}
			cell?.identifier = id
		}
		return cell!
	}
	
	func textCell(in tableView: NSTableView, for task: Task) -> TextCellView {
		let cell = makeCell(ofType: TextCellView.self, in: tableView, withRawID: "textCell")
		cell.set(textStyle: .headline)
		cell.handler = { [weak self] newText in
			self?.presenter.factory.set(value: newText, for: \.text, in: task)
		}
		if task.isDone {
			var attributes: [NSAttributedString.Key : Any?] = [:]
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineBreakMode = .byTruncatingTail
			attributes[.foregroundColor] = NSColor.secondaryLabelColor
			attributes[.strikethroughStyle] = 1
			attributes[.paragraphStyle] = paragraphStyle
			let attrString = NSAttributedString(string: task.text, attributes: attributes)
			cell.textField?.attributedStringValue = attrString
		} else {
			cell.textField?.stringValue = task.text
			cell.textField?.textColor = .controlTextColor
		}
		return cell
	}
	
	func checkboxCell(in tableView: NSTableView, for task: Task) -> ToggleCellView {
		let cell = makeCell(ofType: ToggleCellView.self, in: tableView, withRawID: "checkboxCell") {
			let button = TickButton()
			return ToggleCellView(button: button)
		}
		cell.completionHandler = { [weak self] isOn in
			self?.presenter.factory.set(value: isOn, for: \.transientIsDone, in: task)
		}
		cell.set(isOn: task.transientIsDone)
		return cell
	}
	
	func listCell(in tableView: NSTableView,
				  for task: Task) -> TextCellView {

		let cell = makeCell(ofType: TextCellView.self, in: tableView, withRawID: "listCell")
		cell.set(textStyle: .subheadline)
		cell.textField?.textColor = .secondaryLabelColor
		return cell
	}
	
	func favoriteCell(in tableView: NSTableView, for task: Task) -> ToggleCellView {
		let id = NSUserInterfaceItemIdentifier("favorite_cell")
		var cell = tableView.makeView(withIdentifier: id, owner: nil) as? ToggleCellView
		if cell == nil {
			let starButton = AnimationButton(frame: CGRect(x: 0, y: 0, width: 18.0, height: 18.0))
			cell = ToggleCellView(button: starButton)
			cell?.identifier = id
		}
		cell?.completionHandler = { [weak self] newValue in
			self?.presenter.factory.set(value: newValue, for: \.isFavorite, in: task)
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
		return false
	}
	
	func tableView(_ tableView: NSTableView, shouldShowCellExpansionFor tableColumn: NSTableColumn?, row: Int) -> Bool {
		return false
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard let id = tableColumn?.identifier else { return nil }
		let task = presenter.objects[row]
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
