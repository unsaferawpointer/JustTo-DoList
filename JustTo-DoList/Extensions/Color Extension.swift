//
//  Color Extension.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 23.09.2021.
//

import AppKit

extension NSColor {
	var luminance: CGFloat {
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		getRed(&red, green: &green, blue: &blue, alpha: nil)
		
		return (0.2126 * red) + (0.7152 * green) + (0.0722 * blue)
	}
	
	func sameBrightness(from color: NSColor) -> NSColor {
		
		let hue = color.hueComponent
		let saturation = color.saturationComponent
		
		return NSColor(calibratedHue: hue, saturation: saturation, brightness: brightnessComponent, alpha: 1.0)
	}
}
