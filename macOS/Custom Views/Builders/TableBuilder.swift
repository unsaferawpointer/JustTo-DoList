//
//  Builder.swift
//  CompactToDo
//
//  Created by Anton Cherkasov on 28.07.2021.
//

import AppKit


class TableViewBuilder {
	
	enum TableStyle {
		case sidebar
		case content
	}
	
	var style: TableStyle
	
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
					return .center
				default:
					return .natural
				}
			case .flexible:
				return .natural
			}
		}
	}
	
	private let rowHeight : CGFloat = 36.0
	lazy var tableView : NSTableView =  {
		let _tableView = NSTableView()
		return _tableView
	}()
	
	func addColumn(_ title: String,
					identifier: NSUserInterfaceItemIdentifier,
					style: ColumnStyle,
					sortDescriptor: NSSortDescriptor?) {
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
	
	func addColumn(localizedString: String,
				   identifier id: NSUserInterfaceItemIdentifier,
				   style: ColumnStyle,
				   sortDescriptor: NSSortDescriptor?) {
		let title = NSLocalizedString(localizedString, comment: "")
		addColumn(title, identifier: id, style: style, sortDescriptor: sortDescriptor)
	}
	
	func retrieveTableView() -> NSTableView {
		return tableView
	}
	
	init(style: TableStyle) {
		self.style = style
		switch style {
		case .content:
			configureContentStyle()
		case .sidebar:
			configureSidebarStyle()
		}
	}
	
	private func configureSidebarStyle() {
		#warning("Dont implemented")
	}
	
	private func configureContentStyle() {
		tableView.style = .inset
		tableView.selectionHighlightStyle = .regular
		tableView.rowHeight = rowHeight
		tableView.rowSizeStyle = .custom
		tableView.floatsGroupRows = false
		tableView.usesAutomaticRowHeights = false
		tableView.allowsMultipleSelection = true
		tableView.backgroundColor = NSColor.clear
		tableView.usesAlternatingRowBackgroundColors = true
		tableView.backgroundColor = .clear
		tableView.allowsColumnResizing = true
		tableView.columnAutoresizingStyle = .reverseSequentialColumnAutoresizingStyle
	}
	
}
