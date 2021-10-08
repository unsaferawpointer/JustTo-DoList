//
//  ContentViewController.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 08.08.2021.
//

import Cocoa
import CoreData
import CoreDataStore

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
		
	let presenter: ContentViewPresenter
	
	lazy var scrollView : NSScrollView = {
		let _scrollView = NSScrollView()
		_scrollView.drawsBackground = true
		_scrollView.hasHorizontalScroller = false
		_scrollView.hasVerticalScroller = true
		_scrollView.documentView = tableView
		return _scrollView
	}()
	
	lazy var tableView : NSTableView = {
		let builder = TableViewBuilder(style: .content)
		builder.addColumn("􀆅",
						  identifier: .checkboxColumn,
						  style: .fixed(size: .oneSymbol),
						  sortDescriptor: NSSortDescriptor(keyPath: \Task.isDone, ascending: true))
		builder.addColumn(localizedString: "tableview_column_task",
						  identifier: .textColumn,
						  style: .flexible(size: .primary),
						  sortDescriptor: NSSortDescriptor(keyPath: \Task.text, ascending: true))
//		builder.addColumn(localizedString: "tableview_column_list",
//						  identifier: .listColumn,
//						  style: .flexible(size: .secondary),
//						  sortDescriptor: NSSortDescriptor(keyPath: \Task.typeMask, ascending: true))
		builder.addColumn("􀋂",
						  identifier: .isFavoriteColumn,
						  style: .fixed(size: .oneSymbol),
						  sortDescriptor: NSSortDescriptor(keyPath: \Task.isFavorite, ascending: true))
		let _tableView = builder.retrieveTableView()
		return _tableView
	}()
	
	init(presenter: ContentViewPresenter) {
		self.presenter = presenter
		super.init(nibName: nil, bundle: nil)
		self.presenter.view = self
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		view = NSView()
		configureConstraints()
	}
	
	private func configureConstraints() {
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(scrollView)
		view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
		view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
		view.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
		view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.dataSource = self
		tableView.delegate = self
		
		initContextMenu()
		presenter.performFetch(with: nil, andSortDescriptors: [])
		tableView.setDraggingSourceOperationMask([.copy, .delete], forLocal: false)
		tableView.sizeLastColumnToFit()
	}
	
	private func initContextMenu() {
		tableView.menu = createContextMenu()
		tableView.target = self
	}
}

extension ContentViewController : ContentView {
	
	func getSelectedRows() -> IndexSet {
		return tableView.selectedRowIndexes
	}
	
	func getClickedRow() -> Int {
		return tableView.clickedRow
	}
	
	func willReloadContent() {
		fatalError("Dont implemented")
	}
	
	func didReloadContent() {
		tableView.reloadData()
	}
	
	func willChangeContent() {
		tableView.beginUpdates()
	}
	
	func didChangeContent() {
		tableView.endUpdates()
	}
	
	func didRemoveItems(at indexSet: IndexSet) {
		tableView.removeRows(at: indexSet, withAnimation: .slideLeft)
	}
	
	func didInsertItems(at indexSet: IndexSet) {
		tableView.insertRows(at: indexSet, withAnimation: .slideRight)
	}
	
	func didUpdateItems(at indexSet: IndexSet) {
		let columnIndexes = IndexSet(integersIn: 0..<tableView.numberOfColumns)
		tableView.reloadData(forRowIndexes: indexSet, columnIndexes: columnIndexes)
	}
	
	func didSelectItems(at indexSet: IndexSet) {
		tableView.selectRowIndexes(indexSet, byExtendingSelection: true)
	}
	
	func didChangeIncompletedTasksCount(newCount: Int) {
		view.window?.subtitle = "\(newCount)"
	}
	
	func showWarningAllert(with text: String) {
		#warning("Dont implemented")
	}
	
	func scrollTo(row: Int) {
		tableView.scrollRowToVisible(row)
	}
	
}
