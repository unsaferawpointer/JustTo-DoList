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
	
	var dropView: DestinationView!
	
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
		builder.addColumn("List",
						  identifier: .listColumn,
						  style: .flexible(size: .secondary),
						  sortDescriptor: NSSortDescriptor(keyPath: \Task.list?.name, ascending: true))
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
		dropView = DestinationView(draggedTypes: presenter.registeredDraggedTypes())
		dropView.dropDelegate = self
		view = dropView
		configureConstraints()
	}
	
	private func configureConstraints() {
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(scrollView)
		NSLayoutConstraint.activate([
			view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			view.topAnchor.constraint(equalTo: scrollView.topAnchor),
			view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
		])
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.dataSource = self
		tableView.delegate = self
		
//		tableView.headerView = nil
		
		initContextMenu()
		presenter.performFetch(with: nil, andSortDescriptors: [])
		tableView.setDraggingSourceOperationMask([.copy, .delete], forLocal: false)
		tableView.sizeLastColumnToFit()
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		updateTitleAndSubtitle()
	}
	
	private func initContextMenu() {
		tableView.menu = createContextMenu()
		tableView.target = self
	}
	
	private func updateTitleAndSubtitle() {
		#warning("Dont localized")
		view.window?.title = "Inbox"
		//view.window?.subtitle = "\(presenter.numberOfObjects) tasks, \(presenter.incompleteCount) incomplete"
	}
}

extension ContentViewController : ContentView {
	
	// Drag And Drop support
	func startExecuting() {
		dropView.startExecuting()
	}
	
	func stopExecuting() {
		dropView.stopExecuting()
	}
	
	func update(progress: Double) {
		dropView.update(progress: progress)
	}
	
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
		tableView.removeRows(at: indexSet, withAnimation: .slideDown)
	}
	
	func didInsertItems(at indexSet: IndexSet) {
		tableView.insertRows(at: indexSet, withAnimation: .slideUp)
	}
	
	func didUpdateItems(at indexSet: IndexSet) {
		let columnIndexes = IndexSet(integersIn: 0..<tableView.numberOfColumns)
		tableView.reloadData(forRowIndexes: indexSet, columnIndexes: columnIndexes)
	}
	
	func didSelectItems(at indexSet: IndexSet) {
		tableView.selectRowIndexes(indexSet, byExtendingSelection: true)
	}
	//TODO: localize title and subtitle
	func didChangeTasksCounts(incomplete: Int, all: Int) {
		updateTitleAndSubtitle()
	}
	
	func showWarningAllert(with text: String) {
		#warning("Dont implemented")
	}
	
	func scrollTo(row: Int) {
		tableView.scrollRowToVisible(row)
	}
	
}

extension ContentViewController : DestinationViewDelegate {
	
	func placeholderTitleFor(draggedType: NSPasteboard.PasteboardType) -> String {
		return "Drag and Drop here..."
	}
	
	func placeholderImageFor(draggedType: NSPasteboard.PasteboardType) -> NSImage? {
		return NSImage(systemSymbolName: "arrow.down.app", accessibilityDescription: nil)
	}
	
	func destinationViewPerformDragOperation(destinationView: DestinationView, sender: NSDraggingInfo) -> Bool {
		presenter.performDragOperation(sender)
	}
	
	func cancelExecuting() {
		
	}
	
}
