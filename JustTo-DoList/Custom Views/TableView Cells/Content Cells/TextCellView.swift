//
//  TextCellView.swift
//  CompactToDo
//
//  Created by Anton Cherkasov on 18.06.2021.
//

import Cocoa
import Combine


class TextCellView: NSView {
	
	var textField: NSTextField!
	
	var subscription: AnyCancellable?
	
	func bind(name: NSBindingName, to object: Any, withkeyPath keyPath: String) {
		//textField.bind(name, to: object, withKeyPath: keyPath, options: nil)
	}
	
	var handler: ((String) -> ())?
	
	// #START	******** Init Block ********
	init() {
		super.init(frame: .zero)
		configureViews()
		configureConstraints()
	}
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		configureViews()
		configureConstraints()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		configureViews()
		configureConstraints()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		subscription?.cancel()
		textField.unbind(.value)
		textField.unbind(.attributedString)
	}
	
	private func configureViews() {
		self.translatesAutoresizingMaskIntoConstraints = false
		
		self.textField = NSTextField()
		self.addSubview(textField)
		// Configure NSTextField
		textField.target = self
		textField.action = #selector(cellDidChangeText(_:))
		textField.stringValue = ""
		textField.usesSingleLineMode = true
		textField.isBordered = false
		textField.drawsBackground = false
		textField.lineBreakMode = .byTruncatingTail
		textField.cell?.sendsActionOnEndEditing = true
	}
	
	private func configureConstraints() {
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
		textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		self.centerYAnchor.constraint(equalTo: textField.centerYAnchor).isActive = true
		self.leadingAnchor.constraint(equalTo: textField.leadingAnchor).isActive = true
		self.trailingAnchor.constraint(equalTo: textField.trailingAnchor).isActive = true
	}
	
	// #END		******** Init Block ********
	
	func set(textStyle style: NSFont.TextStyle) {
		textField.font = NSFont.preferredFont(forTextStyle: style, options: [:])
	}
	
}

extension TextCellView : NSTextFieldDelegate {
	@objc
	func cellDidChangeText(_ sender: NSTextField) {
		let text = sender.stringValue
		handler?(text)
	}
}
