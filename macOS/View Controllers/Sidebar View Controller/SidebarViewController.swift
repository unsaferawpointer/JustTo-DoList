//
//  SidebarViewController.swift
//  Done-macOS
//
//  Created by Anton Cherkasov on 20.10.2021.
//

import Cocoa

class SidebarViewController: NSViewController {
	
	var presenter = SidebarViewPresenter.init()
	
	lazy var scrollView : NSScrollView = {
		let _scrollView = NSScrollView()
		_scrollView.drawsBackground = false
		_scrollView.hasHorizontalScroller = false
		_scrollView.hasVerticalScroller = true
		_scrollView.documentView = outlineView
		_scrollView.scrollerKnobStyle = .default
		_scrollView.autohidesScrollers = true
		return _scrollView
	}()
	
	lazy var outlineView: NSOutlineView = {
		let _outlinewView = NSOutlineView()
		//_outlinewView.frame = scrollView.bounds
		_outlinewView.style = .sourceList
		_outlinewView.headerView = nil
		_outlinewView.rowSizeStyle = .default
		_outlinewView.floatsGroupRows = false
		_outlinewView.usesAutomaticRowHeights = true
		_outlinewView.allowsMultipleSelection = false
		_outlinewView.allowsEmptySelection = false
		_outlinewView.usesAlternatingRowBackgroundColors = false
		
		let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "col"))
		_outlinewView.addTableColumn(col)
		_outlinewView.allowsColumnResizing = true
		return _outlinewView
	}()
	
	override func loadView() {
		self.view = NSView()
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		presenter.view = self
		configureConstraints()
		outlineView.delegate = self
		outlineView.dataSource = self
		outlineView.menu = createEditMenu()
//		for i in 0..<10 {
//			let list = List(context: CoreDataStorage.shared.mainContext)
//		}
//		try? CoreDataStorage.shared.mainContext.save()
		outlineView.reloadData()
		outlineView.sizeLastColumnToFit()
		outlineView.registerForDraggedTypes([.taskID])
    }
	
	override func viewWillAppear() {
		super.viewWillAppear()
		outlineView.expandItem(presenter.sections, expandChildren: true)
		//outlineView.hideRows(at: IndexSet(integer: 0), withAnimation: .slideDown)
	}
	
	private func configureConstraints() {
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(scrollView)
		NSLayoutConstraint.activate([
			view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			view.topAnchor.constraint(equalTo: scrollView.topAnchor),
			view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
		])
	}
    
}

extension SidebarViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		return presenter.item(child: index, ofItem: item)
	}
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		return presenter.numberOfChildren(ofItem: item)
	}
	
	func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
		if let list = item as? List, index == -1 {
			return .move
		}
		return []
	}
	
	func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
		guard let list = item as? List, index == -1 else {
			return true
		}
		guard let absoluteStringURL =  info.draggingPasteboard.string(forType: .taskID),
		let url = URL(string: absoluteStringURL) else {
			return false
		}
		
		presenter.dropObjects(withURLs: [url], to: list)
		
		return false
	}
}

extension SidebarViewController: NSOutlineViewDelegate {
	
	func outlineViewSelectionDidChange(_ notification: Notification) {
		let selectedRow = outlineView.selectedRow
		guard selectedRow >= 0 else { return }
		let item = outlineView.item(atRow: selectedRow)
		presenter.select(object: item)
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		
		if let list = item as? List {
			let cell = SidebarLabelCell()
			cell.textField?.stringValue = list.name ?? ""
			cell.completionHandler =  { newText in
				list.name = newText
				try! CoreDataManager.shared.mainContext.save()
			}
			return cell
		} else if let section = item as? BasicSection {
			let cell = SidebarTextCell()
			cell.textField?.stringValue = "Done"
			return cell
		} else if let section = item as? ListSection {
			let cell = SidebarTextCell()
			cell.textField?.stringValue = "Lists"
			return cell
		} else if let item = item as? Item {
			let cell = SidebarTextCell()
			cell.textField?.stringValue = item.base.title
			return cell
		}
		return nil
	}
	
	func outlineView(_ outlineView: NSOutlineView, shouldCollapseItem item: Any) -> Bool {
		return false
	}
	
	func outlineView(_ outlineView: NSOutlineView, shouldExpandItem item: Any) -> Bool {
		return true
	}
	
	func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
		return item is Item || item is List
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return presenter.isItemExpandable(item: item)
	}
	func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
		return item is BasicSection || item is ListSection
	}
	
	func outlineView(_ outlineView: NSOutlineView, tintConfigurationForItem item: Any) -> NSTintConfiguration? {
		return .init(preferredColor: .controlAccentColor)
	}
}

extension SidebarViewController: OutlineView {
	func didReload() {
		outlineView.reloadData()
	}
	
	func willChangeContent() {
		outlineView.beginUpdates()
	}
	
	func didChangeContent() {
		outlineView.endUpdates()
	}
	
	func removeItems(at indexSet: IndexSet, inParent parent: Any?) {
		outlineView.removeItems(at: indexSet, inParent: parent, withAnimation: .slideDown)
	}
	
	func insertItems(at indexSet: IndexSet, inParent parent: Any?) {
		outlineView.insertItems(at: indexSet, inParent: parent, withAnimation: .slideUp)
	}
	
	func reload(item: Any?) {
		outlineView.reloadItem(item)
	}
}
