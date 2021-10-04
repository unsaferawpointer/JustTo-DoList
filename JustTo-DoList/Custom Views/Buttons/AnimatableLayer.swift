//
//  AnimatableLayer.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 20.09.2021.
//

import AppKit

struct AnimationTheme {
	var selectedColor: NSColor
	var unselectedColor: NSColor
	var lightColor: NSColor
	var darkColor: NSColor
}

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
		_properties.append(UnsafeAnimationProperty(keyPath: "fillColor", value: fillColor))
		_properties.append(UnsafeAnimationProperty(keyPath: "strokeColor", value: strokeColor))
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
			let values = properties.map { $0.value }
			let animation = CAKeyframeAnimation(keyPath: keyPath)
			animation.keyTimes = keyTimes
			animationGroup.animations?.append(animation)
			if let colors = values as? [NSColor?] {
				let convertedColors = converted(colors: colors)
				animation.values = isSelected ? convertedColors.map{ $0?.cgColor } : colors.map{ $0?.cgColor }
				if let lastColor = (isSelected ? convertedColors.map{ $0?.cgColor } : colors.map{ $0?.cgColor }).last  {
					setValue(lastColor, forKeyPath: keyPath)
				}
			} else {
				animation.values = values
				if let lastValue = values.last {
					setValue(lastValue, forKeyPath: keyPath)
				}
			}
		}
		
		return animationGroup
	}
	
//	func isColor(keyPath: String) -> Bool {
//		return keyPath == "fillColor" || keyPath == "strokeColor"
//	}
	
	func converted(colors: [NSColor?]) -> [NSColor?] {
		return colors.map { color in
			return self.converted(color: color)
		}
	}
	
	func converted(color: NSColor?) -> NSColor? {
		#warning("Dont implemented")
		
		return color != nil ? NSColor.white : nil
	}
	
	func invalidate() {
		stopAnimation()
		let currentState = animationIsInverted ? states.reversed() : states
		guard let first = currentState.first else {
			return
		}
		perform(withAnimation: false) {
			for property in first.properties {
				if let color = property.value as? NSColor {
					let currentColor = isSelected ? converted(color: color)?.cgColor : color.cgColor
					setValue(currentColor, forKeyPath: property.keyPath)
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
	
	private func perform(withAnimation: Bool, block: () -> Void) {
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


