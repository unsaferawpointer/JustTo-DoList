//
//  AnimatableLayer.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 20.09.2021.
//

import AppKit

/// Don`t use this struct directly`
struct UnsafeAnimationProperty {
	let keyPath: String
	let value: Any?
}

protocol Animatable {
	var properties: [UnsafeAnimationProperty] { get }
}

struct ShadowState : Animatable {
	
	var shadowColor: NSColor?	 = nil
	var shadowOpacity: Float	 = 0.25
	var shadowOffset: CGSize	 = .zero
	var shadowRadius: CGFloat 	 = 3.0
	var shadowPath: CGPath?		 = nil
	
	var properties: [UnsafeAnimationProperty] {
		var _properties = [UnsafeAnimationProperty]()
		_properties.append(UnsafeAnimationProperty(keyPath: "shadowColor", value: shadowColor))
		_properties.append(UnsafeAnimationProperty(keyPath: "shadowOpacity", value: shadowOpacity))
		_properties.append(UnsafeAnimationProperty(keyPath: "shadowOffset", value: shadowOffset))
		_properties.append(UnsafeAnimationProperty(keyPath: "shadowRadius", value: shadowRadius))
		_properties.append(UnsafeAnimationProperty(keyPath: "shadowPath", value: shadowPath))
		return _properties
	}
}

struct ShapeState : Animatable {
	
	var fillColor: NSColor?		 = nil
	var strokeColor: NSColor?	 = .black
	var strokeStart: CGFloat	 = 0.0
	var strokeEnd: CGFloat		 = 1.0
	var lineWidth: CGFloat		 = 1.5
	var miterLimit: CGFloat		 = 0.0
	var lineDashPhase: CGFloat	 = 0.0
	
	var properties: [UnsafeAnimationProperty] {
		var _properties = [UnsafeAnimationProperty]()
		_properties.append(UnsafeAnimationProperty(keyPath: "fillColor", value: fillColor?.cgColor))
		_properties.append(UnsafeAnimationProperty(keyPath: "strokeColor", value: strokeColor?.cgColor))
		_properties.append(UnsafeAnimationProperty(keyPath: "strokeStart", value: strokeStart))
		_properties.append(UnsafeAnimationProperty(keyPath: "strokeEnd", value: strokeEnd))
		_properties.append(UnsafeAnimationProperty(keyPath: "lineWidth", value: lineWidth))
		_properties.append(UnsafeAnimationProperty(keyPath: "miterLimit", value: miterLimit))
		_properties.append(UnsafeAnimationProperty(keyPath: "lineDashPhase", value: lineDashPhase))
		return _properties
	}
}

struct AnimationState : Animatable {
	
	var opacity: Float			= 1.0
	var scale: NSNumber 		= 1.0
	
	var shadowState: ShadowState = ShadowState()
	var shapeState: ShapeState = ShapeState()
	
	var properties: [UnsafeAnimationProperty] {
		var _properties = [UnsafeAnimationProperty]()
		_properties.append(UnsafeAnimationProperty(keyPath: "opacity", value: opacity))
		_properties.append(UnsafeAnimationProperty(keyPath: "transform.scale", value: scale))
		_properties.append(contentsOf: shapeState.properties)
		_properties.append(contentsOf: shadowState.properties)
		return _properties
	}
}

//struct State {
//	var properties: [UnsafeAnimationProperty] = []
//}
//
//extension State {
//	mutating func add<T>(keyPath: ReferenceWritableKeyPath<CAShapeLayer, T>, value: T) {
//		let strKeyPath = NSExpression(forKeyPath: keyPath).keyPath
//		let unsafeAnimationProperty = UnsafeAnimationProperty(keyPath: strKeyPath, value: value)
//		properties.append(unsafeAnimationProperty)
//	}
//	mutating func add(keyPath: String, value: Any?) {
//		let unsafeAnimationProperty = UnsafeAnimationProperty(keyPath: keyPath, value: value)
//		properties.append(unsafeAnimationProperty)
//	}
//}

class AnimationLayer : CAShapeLayer {
	
	var isAnimating: Bool 			= false
	var isSelected: Bool 			= false {
		didSet {
			invalidate()
		}
	}
	var animationIsInverted: Bool 	= false
	
	private var states: [Animatable] = []
	private var keyTimes: [NSNumber] = []
	
	weak var frameAnimationDelegate : AnimationLayerDelegate?
	
	func add(state: Animatable, withDuration keyTime: NSNumber) {
		keyTimes.append(keyTime)
		states.append(state)
	}
	
	private func createAnimation() -> CAAnimationGroup {
		
		let currentStates = animationIsInverted ? states.reversed() : states
		let properties = currentStates.map { $0.properties }.flatMap{ $0 }
		let dictionary = Dictionary(grouping: properties) { $0.keyPath }
		
		let animationGroup = CAAnimationGroup()
		animationGroup.animations = []
		animationGroup.delegate = self
		animationGroup.duration = 0.25
	
		for (keyPath, properties) in dictionary {
			var values = properties.map { $0.value }
			if let colors = values as? [CGColor?], isSelected && isColor(keyPath: keyPath){
				values = converted(colors: colors)
			}
			let animation = CAKeyframeAnimation(keyPath: keyPath)
			animation.values = values
			animation.keyTimes = keyTimes
			animationGroup.animations?.append(animation)
			if let lastValue = values.last {
				setValue(lastValue, forKeyPath: keyPath)
			}
		}
		
		return animationGroup
	}
	
	func isColor(keyPath: String) -> Bool {
		return keyPath == "fillColor" || keyPath == "strokeColor"
	}
	
	func converted(colors: [CGColor?]) -> [CGColor?] {
		return colors.map { color in
			return self.converted(color: color)
		}
	}
	
	func converted(color: CGColor?) -> CGColor? {
		#warning("Dont implemented")
		return NSColor.controlColor.cgColor
	}
	
	func invalidate() {
		stopAnimation()
		let currentState = animationIsInverted ? states.reversed() : states
		guard let first = currentState.first else {
			return
		}
		perform(withAnimation: false) {
			for property in first.properties {
				if isColor(keyPath: property.keyPath) && isSelected {
					if property.value != nil {
						let convertedColor = converted(color: property.value as! CGColor)
						setValue(convertedColor, forKeyPath: property.keyPath)
					} else {
						setValue(nil, forKeyPath: property.keyPath)
					}
				} else {
					setValue(property.value, forKeyPath: property.keyPath)
				}
			}
		}
	}
	
	func startAnimation() {
		guard !isAnimating else {
			return
		}
		let animation = createAnimation()
		perform(withAnimation: true) {
			add(animation, forKey: nil)
		}
	}
	
	func stopAnimation() {
		removeAllAnimations()
	}
	
	private func perform(withAnimation: Bool, block: () -> ()) {
		CATransaction.begin()
		CATransaction.setDisableActions(!withAnimation)
		block()
		CATransaction.commit()
	}
}

extension AnimationLayer : CAAnimationDelegate {
	func animationDidStart(_ anim: CAAnimation) {
		isAnimating = true
	}
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		isAnimating = false
		if flag {
			frameAnimationDelegate?.animationDidFinished()
		}
	}
}



protocol AnimationLayerDelegate: AnyObject {
	func animationDidFinished()
}

//class AnimatableLayersGroup {
//	var animatableLayers: [AnimatableLayer] = []
//
//	func start() {
//		for animatableLayer in animatableLayers {
//			animatableLayer.startAnimation()
//		}
//	}
//
//	func stop() {
//
//	}
//
//	func animationGroupStarted() {
//
//	}
//
//	func animationGroupFinished() {
//
//	}
//}

//class AnimatableLayer : CAShapeLayer {
//
//	weak var frameAnimationDelegate : AnimationLayerDelegate?
//
//	var frames: [State] = [] {
//		didSet {
//			invalidate()
//		}
//	}
//	var frameIndex = 0
//
//	var isAnimating: Bool = false
//	var animationIsInverted: Bool = false
//
//	var isSelected: Bool = false {
//		didSet {
//			invalidate()
//		}
//	}
//
//	init(firstState: State) {
//		super.init()
//		frames.append(firstState)
//	}
//
//	required init?(coder: NSCoder) {
//		fatalError("init(coder:) has not been implemented")
//	}
//
//	// Use first frame to init state of the layer
//	func startAnimation() {
//		guard !isAnimating else {
//			return
//		}
//
//		if animationIsInverted {
//			frameIndex = frames.count - 1
//			previousFrame()
//		} else {
//			frameIndex = 0
//			nextFrame()
//		}
//	}
//
//	func invalidate() {
//		if animationIsInverted {
//			guard let lastState = frames.last else {
//				return
//			}
//			invalidate(lastState)
//		} else {
//			guard let firstState = frames.first else {
//				return
//			}
//			invalidate(firstState)
//		}
//	}
//
//	private func invalidate(_ state: State) {
//
//		for property in frames.first!.properties {
//			setValue(property.value, forKeyPath: property.keyPath)
//		}
//
//		perform(withAnimation: false) {
//			for property in state.properties {
//				if property.keyPath == "fillColor" ||
//					property.keyPath == "strokeColor", property.value != nil {
//					if isSelected {
//						setValue(NSColor.controlColor.cgColor, forKeyPath: property.keyPath)
//					} else {
//						setValue(property.value, forKeyPath: property.keyPath)
//					}
//				} else {
//					setValue(property.value, forKeyPath: property.keyPath)
//				}
//
//			}
//		}
//	}
//
//	func previousFrame() {
//		if hasPreviousFrame() {
//			frameIndex -= 1
//		} else {
//			return
//		}
//		createAnimation(for: frameIndex)
//	}
//
//	func nextFrame() {
//		if hasNextFrame() {
//			frameIndex += 1
//		} else {
//			return
//		}
//		createAnimation(for: frameIndex)
//	}
//
//	func hasPreviousFrame() -> Bool {
//		return frameIndex > 0
//	}
//
//	func hasNextFrame() -> Bool {
//		return frameIndex + 1 < frames.count
//	}
//
//	func stopAnimation() {
//		isAnimating = false
//
//		#if DEBUG
//		if let _ = animation(forKey: "basic") {
//			fatalError("Error. Animation must be nil")
//		}
//		#endif
//
//		removeAllAnimations()
//	}
//
//	private func perform(withAnimation: Bool, block: () -> ()) {
//		CATransaction.begin()
//		CATransaction.setDisableActions(!withAnimation)
//		block()
//		CATransaction.commit()
//	}
//
//	private func createAnimation(for index: Int) {
//
//		let frame = frames[index]
//
//			let animationGroup = CAAnimationGroup()
//			animationGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)
//			animationGroup.fillMode = .forwards
//			var animations = [CAAnimation]()
//			animationGroup.animations = []
//			animationGroup.isRemovedOnCompletion = true
//			for property in frame.properties {
//				let animation = CABasicAnimation(keyPath: property.keyPath)
//				let fromValue = self.value(forKeyPath: property.keyPath)
//				animation.fromValue = fromValue
//				if property.keyPath == "fillColor" ||
//					property.keyPath == "strokeColor", property.value != nil {
//					if isSelected {
//						animation.toValue = NSColor.controlColor.cgColor
//						self.setValue(NSColor.controlColor.cgColor, forKeyPath: property.keyPath)
//					} else {
//						animation.toValue = property.value
//						self.setValue(property.value, forKeyPath: property.keyPath)
//					}
//				} else {
//					animation.toValue = property.value
//					self.setValue(property.value, forKeyPath: property.keyPath)
//				}
//
//				animations.append(animation)
//
//			}
//			animationGroup.animations = animations
//			animationGroup.duration = frame.duration
//			animationGroup.delegate = self
//
//			perform(withAnimation: true) {
//				add(animationGroup, forKey: "basic")
//			}
//	}
//
//}

//extension AnimatableLayer: CAAnimationDelegate {
//
//	func animationDidStart(_ anim: CAAnimation) {
//		isAnimating = true
//	}
//
//	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//		if flag {
//			if !hasNextFrame() {
//				isAnimating = false
//				frameIndex = animationIsInverted ? frames.count - 1 : 0
//				frameAnimationDelegate?.animationDidFinished()
//			} else {
//				nextFrame()
//			}
//		} else {
//			isAnimating = false
//			frameAnimationDelegate?.animationDidStop(frameAtIndex: frameIndex)
//		}
//	}
//}
