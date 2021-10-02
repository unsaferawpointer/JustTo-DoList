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
	
	var viewContext: NSManagedObjectContext {
		return CoreDataStorage.shared.mainContext
	}
	
	let presenter = ContentPresenter<Task>.init(sortDescriptors:
														[NSSortDescriptor(keyPath: \Task.isDone, ascending: true),
														 NSSortDescriptor(keyPath: \Task.completionDate, ascending: true),
														 NSSortDescriptor(keyPath: \Task.isFavorite, ascending: false),
														 NSSortDescriptor(keyPath: \Task.creationDate, ascending: true),
														 NSSortDescriptor(keyPath: \Task.text, ascending: true),
														 NSSortDescriptor(keyPath: \Task.typeMask, ascending: true)]
	)
	
	let factory = ObjectFactory<Task>.init(persistentContainer: CoreDataStorage.shared.persistentContainer)
	
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
	
	override func loadView() {
		setupRootView()
		setupScrollView()
		
	}
	
	func setupRootView() {
		let backgroundView = NSView()
//		backgroundView.blendingMode = .behindWindow
//		backgroundView.material = .dark
		self.view = backgroundView
		//self.view.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setupScrollView() {
		let scrollView = NSScrollView()
		scrollView.backgroundColor = NSColor.clear
		scrollView.drawsBackground = true
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
		tableView.dataSource = self
		tableView.delegate = self
		initContextMenu()
		addObservers()
		presenter.delegate = self
		presenter.reloadData()
		tableView.sizeLastColumnToFit()
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
	}
	
	private func addObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(newTask(_:)), name: .newTask, object: nil)
	}
	
	private func initContextMenu() {
		tableView.menu = createContextMenu()
		tableView.target = self
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		configureTitles()
	}
	
	private func configureTitles() {
		self.view.window?.title = "Inbox"
		self.view.window?.subtitle = "12 Tasks, 5 completed"
	}
	
}
