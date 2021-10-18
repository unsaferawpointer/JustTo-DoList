//
//  DestinationView.swift
//  Just Notepad
//
//  Created by Anton Cherkasov on 14.06.2021.
//

import Cocoa

protocol DestinationViewDelegate: AnyObject {
	func placeholderTitleFor(draggedType: NSPasteboard.PasteboardType) -> String
	func placeholderImageFor(draggedType: NSPasteboard.PasteboardType) -> NSImage?
	func destinationViewPerformDragOperation(destinationView: DestinationView, sender: NSDraggingInfo) -> Bool
}

class DestinationView: NSView {
	
	weak var dropDelegate: DestinationViewDelegate?
	var onDrop: Bool = false
	var isExecuting: Bool = false {
		didSet {
			updateViewsVisibility()
		}
	}
	
	private (set) var placeholderView: NSView?
	private (set) var progressIndicator: NSProgressIndicator?
	private (set) var label: NSTextField?
	private (set) var imageView: NSImageView?
	
	init(frame frameRect: NSRect, draggedTypes: [NSPasteboard.PasteboardType]) {
		super.init(frame: frameRect)
		registerForDraggedTypes(draggedTypes)
		configurePlaceholder()
	}
	
	convenience init(draggedTypes: [NSPasteboard.PasteboardType]) {
		self.init(frame: .zero, draggedTypes: draggedTypes)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func updateViewsVisibility() {
		for view in subviews {
			if view != placeholderView {
				view.isHidden = onDrop || isExecuting
			} else {
				placeholderView?.isHidden = !onDrop && !isExecuting
			}
		}
		progressIndicator?.doubleValue = 0.0
	}
	
	private func configurePlaceholder() {
		
		let placeholderView = BackgroundView()
		self.placeholderView = placeholderView
		placeholderView.wantsLayer = true
		let square = CAShapeLayer()
		placeholderView.layer?.addSublayer(square)
		
		self.addSubview(placeholderView)
		placeholderView.translatesAutoresizingMaskIntoConstraints = false
		placeholderView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor).isActive = true
		placeholderView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor).isActive = true
		placeholderView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
		placeholderView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor).isActive = true
		
		let imageView = NSImageView(frame: .zero)
		self.imageView = imageView
		imageView.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 88.0, weight: .ultraLight, scale: .small)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentTintColor = .tertiaryLabelColor
		
		let label = NSTextField(labelWithString: "")
		self.label = label
		label.font = NSFont.systemFont(ofSize: 17.0, weight: .light)
		label.textColor = .secondaryLabelColor
		
		let indicator = NSProgressIndicator()
		self.progressIndicator = indicator
		indicator.translatesAutoresizingMaskIntoConstraints = false
		indicator.style = .bar
		indicator.minValue = 0.0
		indicator.maxValue = 1.0
		indicator.isIndeterminate = false
		indicator.doubleValue = 0.0

		let cancelButton = NSButton(title: "Cancel", target: nil, action: nil)
		cancelButton.translatesAutoresizingMaskIntoConstraints = false
		cancelButton.keyEquivalent = .carriageReturnKey
		
		let stackView = NSStackView(views: [imageView, label, indicator, cancelButton])
		stackView.orientation = .vertical
		stackView.spacing = 12.0
		stackView.translatesAutoresizingMaskIntoConstraints = false
		placeholderView.addSubview(stackView)
		
		placeholderView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
		placeholderView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor).isActive = true
	}
	
	override func updateLayer() {
		super.updateLayer()
	}
	
	override func layout() {
		super.layout()
		let square = placeholderView?.layer?.sublayers?[0] as! CAShapeLayer
		let roundedCornerSquare = CGPath(roundedRect: NSInsetRect(placeholderView!.bounds, 24.0, 24.0), cornerWidth: 8.0, cornerHeight: 8.0, transform: nil)
		square.path = roundedCornerSquare
		square.lineDashPattern = [10.0, 4.0]
		square.lineWidth = 2.0
		square.fillColor = nil
		square.strokeColor = NSColor.tertiaryLabelColor.cgColor
		(placeholderView?.layer as? CAShapeLayer)?.path = roundedCornerSquare
	}
	
	override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
		onDrop = true
		let draggedTypes = sender.draggingPasteboard.types ?? []
		print(draggedTypes)
		if draggedTypes.count > 1 {
			let title = dropDelegate?.placeholderTitleFor(draggedType: draggedTypes[0]) ?? ""
			label?.stringValue = title
			let image = dropDelegate?.placeholderImageFor(draggedType: draggedTypes[0])
			imageView?.image = image
		}
		
		updateViewsVisibility()
		return [.copy]
	}
	
	override func draggingExited(_ sender: NSDraggingInfo?) {
		onDrop = false
		updateViewsVisibility()
	}
	
	override public func draggingUpdated(_: NSDraggingInfo) -> NSDragOperation {
		return .copy
	}
	
	override public func prepareForDragOperation(_: NSDraggingInfo) -> Bool {
		// finished with dragging so remove any highlighting
		onDrop = false
		updateViewsVisibility()
		return true
	}
	
	override internal func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
		return dropDelegate?.destinationViewPerformDragOperation(destinationView: self, sender: sender) ?? false
	}
	
}

extension DestinationView : DragAndDropView {
	
	func showDragAndDropPlaceholder() {
		isExecuting = true
	}
	
	func hideDragAndDropPlaceHolder() {
		isExecuting = false
	}
	
	func update(progress: Double) {
		progressIndicator?.doubleValue = progress
	}
	
}
