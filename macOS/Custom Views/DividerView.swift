//
//  DividerView.swift
//  Done-macOS
//
//  Created by Anton Cherkasov on 21.10.2021.
//

import Cocoa

class DividerView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
		
		NSColor.tertiaryLabelColor.setStroke()
		let startLine = NSPoint(x: dirtyRect.minX, y: dirtyRect.midY)
		let endLine = NSPoint(x: dirtyRect.maxX, y: dirtyRect.midY)
		let bezierPath = NSBezierPath()
		bezierPath.move(to: startLine)
		bezierPath.line(to: endLine)
		bezierPath.lineWidth = 0.5
		bezierPath.stroke()
        // Drawing code here.
    }
    
}
