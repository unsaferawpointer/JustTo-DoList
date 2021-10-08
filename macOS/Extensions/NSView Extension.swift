//
//  NSView Extension.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 08.10.2021.
//

import AppKit

extension NSView {
	var snapshot: NSImage {
		guard let bitmapRep = bitmapImageRepForCachingDisplay(in: bounds) else { return NSImage() }
		bitmapRep.size = bounds.size
		cacheDisplay(in: bounds, to: bitmapRep)
		let image = NSImage(size: bounds.size)
		image.addRepresentation(bitmapRep)
		return image
	}
}
