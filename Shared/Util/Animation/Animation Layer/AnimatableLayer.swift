//
//  AnimatableLayer.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 20.09.2021.
//

import AppKit

extension NSColor {
	func tintedColor() -> NSColor {
		var h = CGFloat(), s = CGFloat(), b = CGFloat(), a = CGFloat()
		let rgbColor = usingColorSpace(.deviceRGB)
		rgbColor?.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
		return NSColor(hue: h, saturation: s, brightness: b == 0 ? 0.2 : b * 0.8, alpha: a)
	}
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
	var shadowOpacity: Float	 = 0.15
	var shadowOffset: CGSize	 = .zero
	var shadowRadius: CGFloat 	 = 2.0
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
	var strokeStart: NSNumber	 = 0.0
	var strokeEnd: NSNumber		 = 1.0
	var lineWidth: CGFloat		 = 1.2
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
	
	var opacity: NSNumber		= 1.0
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

class AnimationLayersGroup {
	
	var isAnimating = false
	
	weak var delegate: AnimationLayerDelegate?
	
	private(set) var layers: [AnimationLayer] = []
	private var counter: Int = 0
	
	func add(layer: AnimationLayer) {
		layers.append(layer)
		layer.frameAnimationDelegate = self
	}
	
	func add(layers: [AnimationLayer]) {
		self.layers.append(contentsOf: layers)
		layers.forEach{ $0.frameAnimationDelegate = self }
	}
	
	func invalidate() {
		layers.forEach{ $0.invalidate() }
	}
	
	func startAnimation() {
		guard !isAnimating else {
			return
		}
		counter = layers.count
		isAnimating = true
		layers.forEach{ $0.startAnimation() }
	}
	
	func stopAnimation() {
		layers.forEach{ $0.stopAnimation() }
		counter = 0
		isAnimating = false
	}
	
	func set(selected: Bool) {
		layers.forEach{ $0.isSelected = selected }
	}
	
	func set(inverted: Bool) {
		layers.forEach{ $0.animationIsInverted = inverted }
	}
	
}

extension AnimationLayersGroup : AnimationLayerDelegate {
	
	func animationDidStart() {
		
	}
	
	func animationDidFinished() {
		counter -= 1
		if counter == 0 {
			isAnimating = false
			delegate?.animationDidFinished()
		}
	}
}

class AnimationLayer : CAShapeLayer {
	
	var isAnimating: Bool 			= false
	var isSelected: Bool 			= false {
		didSet {
			invalidate()
		}
	}
	
	var animationIsInverted: Bool 	= false {
		didSet {
			invalidate()
		}
	}
	
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
		animationGroup.duration = 4.25
	
		for (keyPath, properties) in dictionary {
			let values = properties.map { $0.value }
			let animation = CAKeyframeAnimation(keyPath: keyPath)
			animation.keyTimes = keyTimes
			animationGroup.animations?.append(animation)
			if let colors = values as? [NSColor?] {
				let convertedColors = converted(colors: colors)
				animation.values = isSelected ? convertedColors.map{ $0?.cgColor } : colors.map { $0?.cgColor }
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
	
	func converted(colors: [NSColor?]) -> [NSColor?] {
		return colors.map { color in
			return self.converted(color: color)
		}
	}
	
	func converted(color: NSColor?) -> NSColor? {
		#warning("Dont implemented")
		return color != nil ? NSColor.alternateSelectedControlTextColor : nil
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
		guard animation(forKey: "animation") == nil else {
			return
		}
		let animation = createAnimation()
		perform(withAnimation: true) {
			add(animation, forKey: "animation")
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
		frameAnimationDelegate?.animationDidStart()
	}
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		isAnimating = false
		if flag {
			frameAnimationDelegate?.animationDidFinished()
		}
	}
}

protocol AnimationLayerDelegate: AnyObject {
	func animationDidStart()
	func animationDidFinished()
}


