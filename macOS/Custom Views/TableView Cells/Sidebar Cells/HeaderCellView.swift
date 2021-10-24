//
//  HeaderCellView.swift
//  CompactToDo
//
//  Created by Anton Cherkasov on 22.04.2021.
//

import Cocoa

class HeaderCellView: NSTableCellView {
    
    var actionButton : NSButton!
    
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
        
        //self.translatesAutoresizingMaskIntoConstraints = false
        
        let titleTextField = NSTextField()
        self.textField = titleTextField
        titleTextField.stringValue = "Header Header Header Header Header Header Header Header Header Header Header"
        titleTextField.maximumNumberOfLines = 1
        titleTextField.lineBreakMode = .byTruncatingTail
        titleTextField.drawsBackground = false
        titleTextField.isEditable = false
        titleTextField.isBordered = false
        titleTextField.textColor = .secondaryLabelColor
        titleTextField.controlSize = .regular
        titleTextField.font = NSFont.preferredFont(forTextStyle: .body, options: [:])
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        self.addSubview(titleTextField)
        
//        self.actionButton = NSButton()
//        actionButton.isBordered = false
//		actionButton.bezelStyle = .inline
//        actionButton.showsBorderOnlyWhileMouseInside = true
//        actionButton.image = NSImage(systemSymbolName: "plus", accessibilityDescription: nil)
//        actionButton.imageScaling = .scaleNone
//        actionButton.symbolConfiguration = .none
//		actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
//		actionButton.setContentHuggingPriority(.required, for: .horizontal)
//        actionButton.translatesAutoresizingMaskIntoConstraints = false
//        actionButton.isHidden = true
//        self.addSubview(actionButton)
        
//        let trailing = NSLayoutConstraint(item: actionButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -7)
//        trailing.priority = .defaultHigh
//        self.addConstraint(trailing)
//
//        self.addConstraint(NSLayoutConstraint(item: actionButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
//
//        self.addConstraint(NSLayoutConstraint(item: titleTextField, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
//
//
//
//        let leading = NSLayoutConstraint(item: titleTextField, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 4)
//        leading.priority = .defaultHigh
//        self.addConstraint(leading)
//
//        let titleTextFieldLeading = NSLayoutConstraint(item: titleTextField, attribute: .trailing, relatedBy: .equal, toItem: actionButton, attribute: .leading, multiplier: 1, constant: -4)
//        titleTextFieldLeading.priority = .defaultLow
//        self.addConstraint(titleTextFieldLeading)

        
    }
    
}
