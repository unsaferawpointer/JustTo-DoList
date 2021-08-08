//
//  Builder.swift
//  CompactToDo
//
//  Created by Anton Cherkasov on 28.07.2021.
//

import AppKit

class TableViewBuilder {
	
	enum ColumnStyle {
		
		case fixed(size: Size)
		case flexible(size: Size)
		
		enum Size {
			case oneSymbol
			case primary
			case secondary
			
			var minWidth : CGFloat? {
				switch self {
				case .oneSymbol:
					return 50.0
				case .primary, .secondary:
					return 120.0
				}
			}
			
			var maxWidth : CGFloat? {
				switch self {
				case .oneSymbol:
					return 50.0
				case .primary:
					return nil
				case .secondary:
					return 200.0
				}
			}
		}
		
		var minWidth : CGFloat? {
			switch self {
			case .fixed(let size):
				return size.minWidth
			case .flexible(let size):
				return size.minWidth
			}
		}
		
		var maxWidth : CGFloat? {
			switch self {
			case .fixed(let size):
				return size.maxWidth
			case .flexible(let size):
				return size.maxWidth
			}
		}
		
		var resizingMask : NSTableColumn.ResizingOptions {
			switch self {
			case .fixed:
				return []
			case .flexible:
				return [.autoresizingMask, .userResizingMask]
			}
		}
		
		var alignment : NSTextAlignment {
			switch self {
			case .fixed(let size):
				switch size {
				case .oneSymbol:
					return .natural
				default:
					return .natural
				}
			case .flexible:
				return .natural
			}
		}
	}
	
	let rowHeight : CGFloat = 36.0
	
	private var tableView = NSTableView()
	
	init() {
		configure()
	}
	
	func configure() {
		tableView.style = .inset
		tableView.selectionHighlightStyle = .regular
		tableView.rowHeight = rowHeight
		tableView.rowSizeStyle = .custom
		tableView.floatsGroupRows = false
		tableView.usesAutomaticRowHeights = false
		tableView.allowsMultipleSelection = true
		tableView.backgroundColor = NSColor.clear
		tableView.usesAlternatingRowBackgroundColors = true
		tableView.allowsColumnResizing = true
		tableView.columnAutoresizingStyle = .reverseSequentialColumnAutoresizingStyle
	}
	
	func addColumn(_ title: String,
					identifier: NSUserInterfaceItemIdentifier,
					style: ColumnStyle,
					sortDescriptor: NSSortDescriptor) {
		let column = NSTableColumn(identifier: identifier)
		column.title = title
		column.headerCell.alignment = style.alignment
		if let width = style.minWidth {
			column.minWidth = width
		}
		if let width = style.maxWidth {
			column.maxWidth = width
		}
		column.resizingMask = style.resizingMask
		column.sortDescriptorPrototype = sortDescriptor
		tableView.addTableColumn(column)
	}
	
	func retrieveTableView() -> NSTableView {
		return tableView
	}
	
}
