//
//  MainSplitViewController.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 08.08.2021.
//

import Cocoa

class MainSplitViewController: NSSplitViewController {
	
	let SIDEBAR_MIN_WIDTH: CGFloat = 120.0
	let SIDEBAR_MAX_WIDTH: CGFloat = 220.0
	
	let CONTENT_MIN_WIDTH: CGFloat = 400.0
	
	init() {
		super.init(nibName: nil, bundle: nil)
		
	}
	
	override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("Dont implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupSplitView()
	}
	
}

extension MainSplitViewController {
	
	private func setupSplitView() {
		splitView.dividerStyle = .thin
		setupSidebarItem()
		setupContentItem()
	}
	
	private func setupSidebarItem() {
		let sidebarVC = DefaultViewController()
		let sidebarItem = NSSplitViewItem(sidebarWithViewController: sidebarVC)
		sidebarItem.canCollapse = true
		sidebarItem.titlebarSeparatorStyle = .none
		sidebarItem.minimumThickness = SIDEBAR_MIN_WIDTH
		sidebarItem.maximumThickness = SIDEBAR_MAX_WIDTH
		let rawHoldingPriority = NSLayoutConstraint.Priority.defaultLow.rawValue + 1
		sidebarItem.holdingPriority = NSLayoutConstraint.Priority.init(rawValue: rawHoldingPriority)
		addSplitViewItem(sidebarItem)
	}
	
	private func setupContentItem() {
		let presenter = ContentViewPresenter()
		let contentVC = ContentViewController(presenter: presenter)
		let contentItem = NSSplitViewItem(contentListWithViewController: contentVC)
		contentItem.allowsFullHeightLayout = true
		contentItem.titlebarSeparatorStyle = .line
		contentItem.minimumThickness = CONTENT_MIN_WIDTH
		contentItem.holdingPriority = .defaultLow
		addSplitViewItem(contentItem)
	}
	
}
