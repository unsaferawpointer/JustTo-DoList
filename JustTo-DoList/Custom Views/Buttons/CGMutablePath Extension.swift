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
	
	static func star(in rect: CGRect, corners: Int, smoothness: CGFloat) -> CGMutablePath {
		// ensure we have at least two corners, otherwise send back an empty path
		guard corners >= 2 else { return CGMutablePath() }
		
		// draw from the center of our rectangle
		let center = CGPoint(x: rect.midX, y: rect.midY)
		
		// start from directly upwards (as opposed to down or to the right)
		var currentAngle = -CGFloat.pi / 2
		
		// calculate how much we need to move with each star corner
		let angleAdjustment = .pi * 2 / CGFloat(corners * 2)
		
		// figure out how much we need to move X/Y for the inner points of the star
		let innerX = center.x * smoothness
		let innerY = center.y * smoothness
		
		// we're ready to start with our path now
		let path = CGMutablePath()
		
		// move to our initial position
		path.move(to: CGPoint(x: center.x * cos(currentAngle), y: center.y * sin(currentAngle)))
		
		// track the lowest point we draw to, so we can center later
		var bottomEdge: CGFloat = 0
		
		// loop over all our points/inner points
		for corner in 0..<corners * 2  {
			// figure out the location of this point
			let sinAngle = sin(currentAngle)
			let cosAngle = cos(currentAngle)
			let bottom: CGFloat
			
			// if we're a multiple of 2 we are drawing the outer edge of the star
			if corner.isMultiple(of: 2) {
				// store this Y position
				bottom = center.y * sinAngle
				
				// …and add a line to there
				path.addLine(to: CGPoint(x: center.x * cosAngle, y: bottom))
			} else {
				// we're not a multiple of 2, which means we're drawing an inner point
				
				// store this Y position
				bottom = innerY * sinAngle
				
				// …and add a line to there
				path.addLine(to: CGPoint(x: innerX * cosAngle, y: bottom))
			}
			
			// if this new bottom point is our lowest, stash it away for later
			if bottom > bottomEdge {
				bottomEdge = bottom
			}
			
			// move on to the next corner
			currentAngle += angleAdjustment
		}
		path.closeSubpath()
		// figure out how much unused space we have at the bottom of our drawing rectangle
		let unusedSpace = (rect.height / 2 - bottomEdge) / 2
		
		// create and apply a transform that moves our path down by that amount, centering the shape vertically
		let transform = CGAffineTransform(translationX: center.x, y: center.y + unusedSpace)
			.rotated(by: .pi)
			.scaledBy(x: 1/1.2, y: 1/1.2)
		
		let result = CGMutablePath()
		result.addPath(path, transform: transform)
		return result
	}
	
}


