//
//  MainSplitViewController.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 08.08.2021.
//

import Cocoa

class MainSplitViewController: NSSplitViewController {
	
	init() {
		super.init(nibName: nil, bundle: nil)
		setupUI()
	}
	
	override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("Dont implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
	}
	
}

extension MainSplitViewController {
	
	private func setupUI() {
		splitView.dividerStyle = .thin
		setupSidebarItem()
		setupContentItem()
	}
	
	private func setupSidebarItem() {
		let sidebarVC = ViewController()
		let sidebarItem = NSSplitViewItem(sidebarWithViewController: sidebarVC)
		sidebarItem.canCollapse = true
		sidebarItem.minimumThickness = 120.0
		sidebarItem.maximumThickness = 220.0
		let rawHoldingPriority = NSLayoutConstraint.Priority.defaultLow.rawValue + 1
		sidebarItem.holdingPriority = NSLayoutConstraint.Priority.init(rawValue: rawHoldingPriority)
		addSplitViewItem(sidebarItem)
	}
	
	private func setupContentItem() {
		let contentVC = ContentViewController()
		let contentItem = NSSplitViewItem(contentListWithViewController: contentVC)
		contentItem.allowsFullHeightLayout = true
		contentItem.titlebarSeparatorStyle = .none
		contentItem.minimumThickness = 400.0
		contentItem.holdingPriority = .defaultLow
		addSplitViewItem(contentItem)
	}
	
}
