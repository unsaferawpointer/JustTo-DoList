//
//  File.swift
//  Done-macOS
//
//  Created by Anton Cherkasov on 22.10.2021.
//

import Foundation

extension NSRect {
	var maxSquare: NSRect {
		let side = min(height, width)
		let x = (width - side)/2
		let y = (height - side)/2
		let origin = CGPoint(x: x, y: y)
		let size = CGSize(width: side, height: side)
		return NSRect(origin: origin, size: size)
	}
}
