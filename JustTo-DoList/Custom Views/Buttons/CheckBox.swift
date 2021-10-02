//
//  CheckBox.swift
//  MiniTaskList
//
//  Created by Anton Cherkasov on 26.05.2021.
//

import AppKit

extension NSAppearance {
	static func withAppAppearance<T>(_ closure: () throws -> T) rethrows -> T {
		let previousAppearance = NSAppearance.current
		NSAppearance.current = NSApp.effectiveAppearance
		defer {
			NSAppearance.current = previousAppearance
		}
		return try closure()
	}
}

class TickButton: AnimationButton {
	
	var backgroundLayer = AnimationLayer()
	
	override func configureFrames() {
		configureBackgroundLayer()
		configureTickLayer()
	}
	
	private func configureBackgroundLayer() {
		let square = getMaxSquare(for: bounds)
		backgroundLayer.path = createSuperEllipse(in: square)
		
		var firstState = AnimationState()
		firstState.shapeState.fillColor = nil
		firstState.shapeState.strokeEnd = 0.0
		firstState.shapeState.strokeColor = .secondaryLabelColor
		firstState.scale = 1.0
		
		var thirdState = AnimationState()
		thirdState.shapeState.fillColor = nil
		thirdState.shapeState.strokeEnd = 1.0
		thirdState.shapeState.strokeColor = .secondaryLabelColor
		thirdState.scale = 1.0
		
		backgroundLayer.add(state: firstState, withDuration: 0.5)
		backgroundLayer.add(state: thirdState, withDuration: 0.5)
		
		backgroundLayer.animationIsInverted = isOn
		backgroundLayer.frame = self.bounds
	}
	
	private func configureTickLayer() {
		let square = getMaxSquare(for: bounds)
		animatableLayer.path = createTick(in: square)
		
		var firstState = AnimationState()
		firstState.shapeState.fillColor = nil
		firstState.shapeState.strokeEnd = 0.0
		firstState.shapeState.strokeColor = .secondaryLabelColor
		firstState.scale = 1.0
		
		var thirdState = AnimationState()
		thirdState.shapeState.fillColor = nil
		thirdState.shapeState.strokeEnd = 1.0
		thirdState.shapeState.strokeColor = .secondaryLabelColor
		thirdState.scale = 1.0
		
		animatableLayer.add(state: firstState, withDuration: 0.5)
		animatableLayer.add(state: thirdState, withDuration: 0.5)
		
		animatableLayer.animationIsInverted = isOn
		animatableLayer.frameAnimationDelegate = self
		animatableLayer.frame = self.bounds
	}
	
	func createSuperEllipse(in normalRect: NSRect) -> CGMutablePath {
		let insetsRect = NSInsetRect(normalRect, 1.5/2, 1.5/2)
		let path = CGMutablePath.superEllipse(forRect: insetsRect, cornerRadius: 4.0)
		return path
	}
	
	func createTick(in normalRect: NSRect) -> CGMutablePath {
		let offset: CGFloat = 4.0
		let sideLength = min(normalRect.height - offset * 2, normalRect.width  - offset * 2)
		let scalingFactor: CGFloat = sideLength / 6.0
		let tickPath = CGMutablePath()
		tickPath.move(to: CGPoint(x: 1 * scalingFactor + offset, y: 3 * scalingFactor + offset))
		tickPath.addLine(to: CGPoint(x: 2.5 * scalingFactor + offset, y: 1.5 * scalingFactor + offset))
		tickPath.addLine(to: CGPoint(x: 5.5 * scalingFactor + offset, y: 4.5 * scalingFactor + offset))
		return tickPath
	}
}
