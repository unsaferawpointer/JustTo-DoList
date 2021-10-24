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
	func cancelExecuting()
}

class DestinationView: NSView {
	
	weak var dropDelegate: DestinationViewDelegate?
	
	var contentInset: CGFloat = 24.0
	var cornerRadius: CGFloat = 8.0
	
	var onDrop: Bool = false
	var isExecuting: Bool = false
	
	var dropLayer: CAShapeLayer?
	
	private (set) var placeholderView: NSView?
	private (set) var progressIndicator: NSProgressIndicator?
	private (set) var label: NSTextField?
	private (set) var imageView: NSImageView?
	private (set) var cancelButton: NSButton?
	
	init(frame frameRect: NSRect, draggedTypes: [NSPasteboard.PasteboardType]) {
		super.init(frame: frameRect)
		registerForDraggedTypes(draggedTypes)
		initPlaceholder()
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
	
	private func initPlaceholder() {
		let placeholderView = BackgroundView()
		placeholderView.wantsLayer = true
		
		let dropLayer = CAShapeLayer()
		placeholderView.layer?.addSublayer(dropLayer)
		self.placeholderView = placeholderView
		self.dropLayer = dropLayer
		
		self.addSubview(placeholderView)
		placeholderView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			placeholderView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
			placeholderView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
			placeholderView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
			placeholderView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
		])
		
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
		self.cancelButton = cancelButton
		cancelButton.target = self
		cancelButton.action = #selector(cancel(_:))
		cancelButton.translatesAutoresizingMaskIntoConstraints = false
		cancelButton.keyEquivalent = .carriageReturnKey
		
		let stackView = NSStackView(views: [imageView, label, indicator, cancelButton])
		stackView.orientation = .vertical
		stackView.spacing = 12.0
		stackView.translatesAutoresizingMaskIntoConstraints = false
		placeholderView.addSubview(stackView)
		
		NSLayoutConstraint.activate([
			placeholderView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
			placeholderView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor)
		])
	}
	
	override func updateLayer() {
		super.updateLayer()
		dropLayer?.lineDashPattern = [10.0, 4.0]
		dropLayer?.lineWidth = 2.0
		dropLayer?.fillColor = nil
		dropLayer?.strokeColor = NSColor.tertiaryLabelColor.cgColor
	}
	
	override func layout() {
		super.layout()
		if let dropLayer = dropLayer, let bounds = placeholderView?.bounds {
			let insetRect = NSInsetRect(bounds, contentInset, contentInset)
			let roundedRectPath = CGPath(roundedRect: insetRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
			dropLayer.path = roundedRectPath
		}
	}
	
	override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
		print(#function)
		onDrop = true
		guard !isExecuting else {
			return []
		}
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
		print(#function)
		onDrop = false
		guard !isExecuting else {
			return
		}
		cancelButton?.resignFirstResponder()
		updateViewsVisibility()
	}
	
	override public func draggingUpdated(_: NSDraggingInfo) -> NSDragOperation {
		print(#function)
		return .copy
	}
	
	override public func prepareForDragOperation(_: NSDraggingInfo) -> Bool {
		onDrop = false
		guard !isExecuting else {
			return false
		}
		isExecuting = true
		// finished with dragging so remove any highlighting
		updateViewsVisibility()
		return true
	}
	
	override internal func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
		return dropDelegate?.destinationViewPerformDragOperation(destinationView: self, sender: sender) ?? false
	}
	
	@objc func cancel(_ sender: Any?) {
		dropDelegate?.cancelExecuting()
	}
	
}

extension DestinationView : DragAndDropView {
	
	func startExecuting() {
		isExecuting = true
		if onDrop == true {
			updateViewsVisibility()
		}
		onDrop = false
		
	}
	
	func stopExecuting() {
		isExecuting = false
		onDrop = false
		updateViewsVisibility()
	}
	
	func update(progress: Double) {
		progressIndicator?.doubleValue = progress
	}
	
}
