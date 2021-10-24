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

class TickButton: NSView, ToggleableButton {
	
	var backgroundStyle: NSView.BackgroundStyle = .normal {
		didSet {
			stopAnimation()
			performWithEffectiveAppearance {
				invalidateColors()
			}
		}
	}
	
	var handler: ((Bool) -> Void)?
	
	func stopAnimation() {
		tickLayer.removeAllAnimations()
	}
	
	var isOn: Bool = false {
		didSet {
			invalidateState()
		}
	}
	
	var tickColor: CGColor {
		return backgroundStyle == .normal ? NSColor.secondaryLabelColor.cgColor : selectedColor
	}
	
	var ellipseColor: CGColor {
		return backgroundStyle == .normal ? NSColor.tertiaryLabelColor.cgColor : selectedColor
	}
	
	var selectedColor: CGColor {
		return NSColor.alternateSelectedControlTextColor.cgColor
	}
	
	var tickLayer: CAShapeLayer!
	var ellipseLayer: CAShapeLayer!
	
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
		ellipseLayer = CAShapeLayer()
		ellipseLayer.lineWidth = 0.8
		layer?.addSublayer(ellipseLayer)
		tickLayer = CAShapeLayer()
		tickLayer.lineWidth = 2.0
		layer?.addSublayer(tickLayer)
	}
	
	override func updateLayer() {
		super.updateLayer()
		invalidateColors()
	}
	
	private func invalidateState() {
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		tickLayer.strokeEnd = isOn ? 1.0 : 0.0
		CATransaction.commit()
	}
	
	private func invalidateColors() {
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		tickLayer.strokeColor = tickColor
		tickLayer.fillColor = nil
		
		ellipseLayer.strokeColor = ellipseColor
		ellipseLayer.fillColor = nil
		CATransaction.commit()
	}
	
	override var intrinsicContentSize: NSSize {
		return NSSize(width: 18.0, height: 18.0)
	}
	
	private func setupGesture() {
		let gesture = NSClickGestureRecognizer(target: self, action: #selector(clicked(_:)))
		gesture.numberOfClicksRequired = 1
		self.addGestureRecognizer(gesture)
	}
	
	override func layout() {
		super.layout()
		let square = bounds.maxSquare
		let ellipsePath = createSuperEllipse(in: square)
		ellipseLayer?.path = ellipsePath
		let tickPath = createTick(in: square)
		tickLayer?.path = tickPath
	}
	
	private func createAnimation<Value>(layer: CAShapeLayer, for keyPath: KeyPath<CAShapeLayer, Value>, to toValue: Value) -> CABasicAnimation {
		let literalKeyPath = NSExpression(forKeyPath: keyPath).keyPath
		let animation = CABasicAnimation(keyPath: literalKeyPath)
		animation.isRemovedOnCompletion = true
		if let fromValue = layer.presentation()?.value(forKeyPath: literalKeyPath) {
			animation.fromValue = fromValue
		}
		animation.toValue = toValue
		layer.setValue(toValue, forKeyPath: literalKeyPath)
		return animation
	}
	
	private func createAnimationGroup() {
		
//		let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
//		scaleAnimation.values = [1.0, 1.5, 1.0]
//		scaleAnimation.keyTimes = [0.1, 0.2, 0.9]
//		scaleAnimation.calculationMode = .linear
		
		let opacityAnimation = createAnimation(layer: tickLayer, for: \.opacity, to: isOn ? 0.0 : 1.0)
		let strokeAnimation = createAnimation(layer: tickLayer, for: \.strokeEnd, to: isOn ? 0.0 : 1.0)
		
		let animationGroup = CAAnimationGroup()
		animationGroup.animations = [opacityAnimation, strokeAnimation]
		animationGroup.delegate = self
		animationGroup.duration = 0.18
		animationGroup.isRemovedOnCompletion = true
		animationGroup.fillMode = .forwards
		CATransaction.begin()
		tickLayer.add(animationGroup, forKey: "animation")
		CATransaction.commit()
	}
	
	private func startAnimation() {
		guard tickLayer.animation(forKey: "animation") == nil else {
			return
		}
		createAnimationGroup()
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
	
	@objc
	func clicked(_ sender: Any?) {
		startAnimation()
	}
}

extension TickButton : CAAnimationDelegate {
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		if flag {
			handler?(!isOn)
		}
	}
}
