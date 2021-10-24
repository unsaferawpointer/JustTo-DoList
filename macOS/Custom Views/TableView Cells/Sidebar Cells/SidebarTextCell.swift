//
//  SidebarTextCell.swift
//  Done-macOS
//
//  Created by Anton Cherkasov on 21.10.2021.
//

import Cocoa

class SidebarTextCell: NSTableCellView {
	
	var completionHandler: ((String) -> ())?
	var budge: NSButton!
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setup()
	}
	
	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
		setup()
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		// Drawing code here.
	}
	
	private func setup() {
		let _textField = NSTextField()
		self.textField = _textField
		_textField.stringValue = "Lists"
		_textField.drawsBackground = false
		_textField.isBordered = false
		_textField.lineBreakMode = .byTruncatingTail
		_textField.font = NSFont.preferredFont(forTextStyle: .body, options: [:])
		textField?.target = self
		textField?.action = #selector(titleDidChanged(_:))
		self.addSubview(_textField)
	}
	
	private func configureConstraints() {
		guard let _textField = textField, let _imageView = imageView else {
			fatalError("textField or imageView dont exist")
		}
		_textField.translatesAutoresizingMaskIntoConstraints = false
		_textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
		_textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		_textField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		_textField.leadingAnchor.constraint(equalTo: _imageView.trailingAnchor, constant: 7.0).isActive = true
		
		_imageView.translatesAutoresizingMaskIntoConstraints = false
		_imageView.setContentHuggingPriority(.required, for: .horizontal)
		_imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
		_imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		_imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		
		budge.translatesAutoresizingMaskIntoConstraints = false
		budge.setContentHuggingPriority(.required, for: .horizontal)
		budge.setContentCompressionResistancePriority(.required, for: .horizontal)
		budge.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		budge.leadingAnchor.constraint(equalTo: _textField.trailingAnchor).isActive = true
		budge.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
	}
	
	func bindText(to object: Any, withKeyPath keyPath: String, options: [NSBindingOption : Any]?) {
		textField?.bind(.value, to: object, withKeyPath: keyPath, options: options)
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		textField?.unbind(.value)
	}
	
}

extension SidebarTextCell {
	@objc
	func titleDidChanged(_ sender: NSTextField) {
		completionHandler?(sender.stringValue)
	}
}

