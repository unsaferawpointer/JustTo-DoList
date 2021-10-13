//
//  BackgroundView.swift
//  Just Notepad
//
//  Created by Anton Cherkasov on 14.06.2021.
//

import Cocoa

@IBDesignable
class BackgroundView: NSView {
    
    @IBInspectable var color: NSColor = .controlBackgroundColor {
        didSet {
            self.needsDisplay = true
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        color.setFill()
        dirtyRect.fill()
        // Drawing code here.
    }
    
}
