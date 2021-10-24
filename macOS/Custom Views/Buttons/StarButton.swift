//
//  StarButton.swift
//  Done-macOS
//
//  Created by Anton Cherkasov on 18.10.2021.
//

import AppKit

class StarButton: NSView, ToggleableButton {
	
	var backgroundStyle: NSView.BackgroundStyle = .normal {
		didSet {
			stopAnimation()
			performWithEffectiveAppearance {
				invalidateColors()
			}
		}
	}
	
	var handler: ((Bool) -> Void)?
	
	var isOn: Bool = false {
		didSet {
			invalidateColors()
		}
	}
	
	var isOnColor: CGColor {
		return backgroundStyle == .normal ? NSColor.systemYellow.cgColor : selectedColor
	}
	var isOffColor: CGColor {
		return backgroundStyle == .normal ? NSColor.tertiaryLabelColor.cgColor : selectedColor
	}
	
	var selectedColor: CGColor {
		return NSColor.alternateSelectedControlTextColor.cgColor
	}
	
	var lineWidth:		CGFloat = 1.2
	var animationDuration = 0.18
	
	var starLayer: CAShapeLayer!
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		initLayers()
		setupGesture()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func performWithEffectiveAppearance(_ block: () -> Void) {
		let oldAppearance = NSAppearance.current
		NSAppearance.current = effectiveAppearance
		block()
		NSAppearance.current = oldAppearance
	}
	
	func initLayers() {
		wantsLayer = true
		layer?.masksToBounds = false
		starLayer = CAShapeLayer()
		starLayer.lineWidth = lineWidth
		layer?.addSublayer(starLayer)
	}
	
	private func invalidateColors() {
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		starLayer.strokeColor = isOn ? isOnColor : isOffColor
		starLayer.fillColor = isOn ? isOnColor : nil
		CATransaction.commit()
	}
	
	override func updateLayer() {
		super.updateLayer()
		invalidateColors()
	}
	
	override func layout() {
		super.layout()
		let square = bounds.maxSquare
		let insetsRect = NSInsetRect(square, lineWidth/2, lineWidth/2)
		let starPath = CGMutablePath.star(in: insetsRect, corners: 5, smoothness: 0.5)
		starLayer.path = starPath
		starLayer.frame = bounds
	}
	
	override var intrinsicContentSize: NSSize {
		return NSSize(width: 18.0, height: 18.0)
	}
	
	private func setupGesture() {
		let gesture = NSClickGestureRecognizer(target: self, action: #selector(clicked(_:)))
		gesture.numberOfClicksRequired = 1
		self.addGestureRecognizer(gesture)
	}
	
	private func createAnimation<Value>(for keyPath: KeyPath<CAShapeLayer, Value>, to toValue: Value) -> CABasicAnimation {
		let literalKeyPath = NSExpression(forKeyPath: keyPath).keyPath
		let animation = CABasicAnimation(keyPath: literalKeyPath)
		animation.isRemovedOnCompletion = true
		if let fromValue = starLayer?.presentation()?.value(forKeyPath: literalKeyPath) {
			animation.fromValue = fromValue
		}
		animation.toValue = toValue
		starLayer.setValue(toValue, forKeyPath: literalKeyPath)
		return animation
	}
	
	private func createAnimationGroup() {
		let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
		scaleAnimation.values = [1.0, 1.5, 1.0]
		scaleAnimation.keyTimes = [0.1, 0.2, 0.9]
		scaleAnimation.calculationMode = .linear
		
		let fillAnimation = createAnimation(for: \.fillColor, to: isOn ? nil : isOnColor)
		let strokeAnimation = createAnimation(for: \.strokeColor, to: isOn ? isOffColor : isOnColor)
		let shadowAnimation = createAnimation(for: \.shadowColor, to: isOn ? isOffColor : isOnColor)
		
		let animationGroup = CAAnimationGroup()
		animationGroup.animations = [scaleAnimation, fillAnimation, strokeAnimation, shadowAnimation]
		animationGroup.delegate = self
		animationGroup.duration = animationDuration
		animationGroup.isRemovedOnCompletion = true
		animationGroup.fillMode = .forwards
		CATransaction.begin()
		starLayer?.add(animationGroup, forKey: "animation")
		CATransaction.commit()
	}
	
	private func startAnimation() {
		guard starLayer.animation(forKey: "animation") == nil else {
			return
		}
		createAnimationGroup()
	}
	
	func stopAnimation() {
		starLayer.removeAllAnimations()
	}
	
	@objc
	func clicked(_ sender: Any?) {
		startAnimation()
	}
}

extension StarButton : CAAnimationDelegate {
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		if flag {
			handler?(!isOn)
		}
	}
}


