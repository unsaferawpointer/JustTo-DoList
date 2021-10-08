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
	
	override func createAnimationLayers() -> [AnimationLayer] {
		return [AnimationLayer(), AnimationLayer()]
	}
	
	override func configureFrames() {
		setupEllipse()
		setupTick()
	}
	
	private func setupEllipse() {
		let square = getMaxSquare(for: bounds)
		animationLayersGroup.layers[1].path = createSuperEllipse(in: square)
		
		
		var firstState = AnimationState()
		firstState.shapeState.fillColor = nil
		firstState.shapeState.strokeColor = .tertiaryLabelColor
		firstState.opacity = 0.0
		
		var thirdState = AnimationState()
		thirdState.shapeState.fillColor = nil
		thirdState.shapeState.strokeColor = .tertiaryLabelColor
		thirdState.opacity = 1.0
		
		animationLayersGroup.layers[1].add(state: thirdState, withDuration: 0.1)
		animationLayersGroup.layers[1].add(state: firstState, withDuration: 0.2)
		
		animationLayersGroup.layers[1].animationIsInverted = isOn
		animationLayersGroup.layers[1].frame = self.bounds
		animationLayersGroup.layers[1].invalidate()
	}
	
	private func setupTick() {
		let square = getMaxSquare(for: bounds)
		animationLayersGroup.layers.first!.path = createTick(in: square)
		
		
		var firstState = AnimationState()
		firstState.shapeState.fillColor = nil
		firstState.opacity = 0.0
		firstState.shapeState.lineWidth = 1.0
		firstState.shapeState.strokeEnd = 0.0
		firstState.shapeState.strokeColor = .tertiaryLabelColor
		
		var secondState = AnimationState()
		secondState.shapeState.fillColor = nil
		secondState.opacity = 0.0
		secondState.scale = 2.0
		secondState.shapeState.lineWidth = 1.0
		secondState.shapeState.strokeEnd = 0.0
		secondState.shapeState.strokeColor = .tertiaryLabelColor
		
		var thirdState = AnimationState()
		thirdState.shapeState.fillColor = nil
		thirdState.shapeState.lineWidth = 1.5
		thirdState.opacity = 1.0
		thirdState.shapeState.strokeEnd = 1.0
		thirdState.shapeState.strokeColor = .secondaryLabelColor
		
		animationLayersGroup.layers.first!.add(state: firstState, withDuration: 0.3)
		animationLayersGroup.layers.first!.add(state: secondState, withDuration: 0.5)
		animationLayersGroup.layers.first!.add(state: thirdState, withDuration: 0.8)
		animationLayersGroup.layers.first!.animationIsInverted = isOn
		animationLayersGroup.layers.first!.frameAnimationDelegate = self
		animationLayersGroup.layers.first!.frame = self.bounds
		animationLayersGroup.layers.first!.invalidate()
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
