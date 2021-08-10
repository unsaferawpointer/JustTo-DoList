//
//  ContentViewController.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 08.08.2021.
//

import Cocoa
import CoreData

extension NSUserInterfaceItemIdentifier {
	// Columns Item Identifier
	static let completionDateColumn		= NSUserInterfaceItemIdentifier("completionDateColumn")
	static let creationDateColumn		= NSUserInterfaceItemIdentifier("creationDateColumn")
	static let listColumn				= NSUserInterfaceItemIdentifier("listColumn")
	static let checkboxColumn				= NSUserInterfaceItemIdentifier("checkboxColumn")
	static let textColumn				= NSUserInterfaceItemIdentifier("textColumn")
	static let isFavoriteColumn			= NSUserInterfaceItemIdentifier("isFavoriteColumn")
	static let myDayColumn				= NSUserInterfaceItemIdentifier("myDayColumn")
	// Cells Item Identifier
	static let checkboxCell				= NSUserInterfaceItemIdentifier("checkboxCell")
	static let favoriteCell				= NSUserInterfaceItemIdentifier("favoriteCell")
}

class ContentViewController: NSViewController {
	
	lazy var tableView : NSTableView = {
		let builder = TableViewBuilder()
		builder.addColumn("􀆅",
						  identifier: .checkboxColumn,
						  style: .fixed(size: .oneSymbol),
						  sortDescriptor: NSSortDescriptor(keyPath: \Task.isDone, ascending: true))
		builder.addColumn(NSLocalizedString("tableview_column_task", comment: ""),
						  identifier: .textColumn,
						  style: .flexible(size: .primary),
						  sortDescriptor: NSSortDescriptor(keyPath: \Task.text, ascending: true))
//		builder.addColumn("Список",
//						  identifier: .listColumn,
//						  style: .flexible(size: .secondary),
//						  sortDescriptor: NSSortDescriptor(keyPath: \Task.list?.name, ascending: true))
		builder.addColumn("􀋂",
						  identifier: .isFavoriteColumn,
						  style: .fixed(size: .oneSymbol),
						  sortDescriptor: NSSortDescriptor(keyPath: \Task.isFavorite, ascending: true))
		let _tableView = builder.retrieveTableView()
		return _tableView
	}()
	
	override func loadView() {
		setupRootView()
		setupScrollView()
	}
	
	func setupRootView() {
		self.view = NSView()
		self.view.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setupScrollView() {
		
		let scrollView = NSScrollView()
		scrollView.backgroundColor = NSColor.clear
		scrollView.hasHorizontalScroller = false
		scrollView.hasVerticalScroller = true
		
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(scrollView)
		self.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
		self.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
		self.view.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
		self.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
		scrollView.documentView = tableView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.sizeLastColumnToFit()
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		self.view.window?.title = "Inbox"
		self.view.window?.subtitle = "12 Tasks, 5 completed"
	}
	
}

