//
//  TextCellView.swift
//  CompactToDo
//
//  Created by Anton Cherkasov on 18.06.2021.
//

import Cocoa
import Combine


class TextCellView: NSTableCellView {
	
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
		//configureConstraints()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		fatalError("Dont implemented")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
	}
	
	private func configureViews() {
		let textField = NSTextField()
		self.textField = textField
		self.addSubview(textField)
		// Configure NSTextField
		textField.target = self
		textField.action = #selector(cellDidChangeText(_:))
		textField.stringValue = ""
		textField.usesSingleLineMode = true
		textField.isBordered = false
		textField.drawsBackground = false
		textField.lineBreakMode = .byTruncatingMiddle
		textField.cell?.sendsActionOnEndEditing = true
	}
	
	private func configureConstraints() {
		textField!.translatesAutoresizingMaskIntoConstraints = false
		textField!.setContentHuggingPriority(.defaultLow, for: .horizontal)
		textField!.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		self.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			self.centerYAnchor.constraint(equalTo: textField!.centerYAnchor),
			self.leadingAnchor.constraint(equalTo: textField!.leadingAnchor),
			self.trailingAnchor.constraint(equalTo: textField!.trailingAnchor)
		])
	}
	
	// #END		******** Init Block ********
	
	func set(textStyle style: NSFont.TextStyle) {
		textField!.font = NSFont.preferredFont(forTextStyle: style, options: [:])
	}
	
}

extension TextCellView : NSTextFieldDelegate {
	@objc
	func cellDidChangeText(_ sender: NSTextField) {
		let text = sender.stringValue
		handler?(text)
	}
}

