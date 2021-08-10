//
//  CGMutablePath Extension.swift
//  CompactToDo
//
//  Created by Anton Cherkasov on 28.07.2021.
//

import Foundation

extension CGMutablePath {
	static func superEllipse(forRect rect: CGRect, cornerRadius: CGFloat) -> CGMutablePath {
		let radius = 1.2 * cornerRadius
		let path = CGMutablePath()
		
		let topRightStart = CGPoint(x: rect.maxX - radius, y: rect.minY)
		let topRightAnchor = CGPoint(x: rect.maxX, y: rect.minY)
		let topRightEnd = CGPoint(x: rect.maxX, y: rect.minY + radius)
		
		let bottomRightStart = CGPoint(x: rect.maxX, y: rect.maxY - radius)
		let bottomRightAnchor = CGPoint(x: rect.maxX, y: rect.maxY)
		let bottomRightEnd = CGPoint(x: rect.maxX - radius, y: rect.maxY)
		
		let bottomLeftStart = CGPoint(x: rect.minX + radius, y: rect.maxY)
		let bottomLeftAnchor = CGPoint(x: rect.minX, y: rect.maxY)
		let bottomLeftEnd = CGPoint(x: rect.minX, y: rect.maxY - radius)
		
		let topLeftStart = CGPoint(x: rect.minX, y: rect.minY + radius)
		let topLeftAnchor = CGPoint(x: rect.minX, y: rect.minY)
		let topLeftEnd = CGPoint(x: rect.minX + radius, y: rect.minY)
		
		path.move(to: topRightStart)
		path.addQuadCurve(to: topRightEnd, control: topRightAnchor)
		path.addLine(to: bottomRightStart)
		path.addQuadCurve(to: bottomRightEnd, control: bottomRightAnchor)
		path.addLine(to: bottomLeftStart)
		path.addQuadCurve(to: bottomLeftEnd, control: bottomLeftAnchor)
		path.addLine(to: topLeftStart)
		path.addQuadCurve(to: topLeftEnd, control: topLeftAnchor)
		path.closeSubpath()
		
		return path
	}
}


