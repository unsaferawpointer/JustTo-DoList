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

protocol SwitchButtonProtocol : NSView {
	func set(selected: Bool)
	func set(isOn: Bool)
	var handler: ((Bool) -> ())? { get set }
	func removeAllAnimations()
}

class CheckBox: NSView, SwitchButtonProtocol {
	
	private var isOn: Bool = false
	private var transientIsOn: Bool = false
	var handler: ((Bool) -> ())?
	
	struct UIStateOptions : OptionSet {
		let rawValue: Int
		static let isDark = UIStateOptions(rawValue: 1 << 0)
		static let selected = UIStateOptions(rawValue: 1 << 1)
	}
	
	var state: UIStateOptions = []
	
	var sound = NSSound(named: "sound.mp3")
	
	var animationDuration 	= 0.15
	var lineWidth: CGFloat	= 1.2
	
	var outlineLayer: CAShapeLayer!
	var tickLayer: CAShapeLayer!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	
	private func setup() {
		setupGesture()
		setupLayers()
	}
	
	private func setupGesture() {
		let gesture = NSClickGestureRecognizer(target: self, action: #selector(tapped(_:)))
		gesture.numberOfClicksRequired = 1
		self.addGestureRecognizer(gesture)
	}
	
	private func setupLayers() {
		self.wantsLayer = true
		// ******** Outline Layer ********
		self.outlineLayer = CAShapeLayer()
		outlineLayer.lineWidth = lineWidth
		outlineLayer.shadowRadius = 2.0
		outlineLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)
		outlineLayer.shadowOpacity = 0.4
		self.layer?.addSublayer(outlineLayer)
		// ******** Tick Layer ********
		self.tickLayer = CAShapeLayer()
		tickLayer.lineWidth = 2.0
		tickLayer.lineCap = .square
		tickLayer.lineJoin = .round
		tickLayer.shadowRadius = 2.0
		tickLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)
		tickLayer.shadowOpacity = 0.4
		self.layer?.addSublayer(tickLayer)
	}
	
	private func updateLayers() {
		updateLayerStrokeEnd()
		updateLayerColors()
		updateLayerOpacity()
	}
	
	private func updateLayerStrokeEnd() {
		tickLayer.strokeEnd = transientIsOn ? 1.0 : 0.0
	}
	
	private func updateLayerOpacity() {
		tickLayer.opacity = transientIsOn ? 1.0 : 0.0
		outlineLayer.opacity = transientIsOn ? 0.0 : 1.0
	}
	
	private func updateLayerColors() {
		outlineLayer.fillColor = nil
		tickLayer.fillColor = nil
		
		NSAppearance.withAppAppearance {
			if state.contains(.selected) {
				let color = NSColor.selectedControlColor.cgColor
				outlineLayer.strokeColor = color
				outlineLayer.shadowColor = color
				tickLayer.strokeColor =  color
				tickLayer.shadowColor = color
			} else {
				let color = NSColor.secondaryLabelColor.cgColor
				outlineLayer.strokeColor = color
				outlineLayer.shadowColor = color
				tickLayer.strokeColor =  color
				tickLayer.shadowColor = color
			}
		}
	}
	
	
	func set(isOn: Bool) {
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		self.transientIsOn = isOn
		self.isOn = isOn
		removeAllAnimations()
		
		updateLayers()
		CATransaction.commit()
	}
	
	// Generate CGPath after layout
	override func layout() {
		super.layout()
		let normalRect = rectangle(in: self.bounds)
		
		tickLayer.path = tickPath(in: normalRect)
		tickLayer.frame = self.bounds
		
		outlineLayer.path = outlinePath(in: normalRect)
		outlineLayer.frame = self.bounds
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
	}
	
	func rectangle(in rect: NSRect) -> NSRect {
		let side = min(rect.height, rect.width)
		let x = (rect.width - side)/2
		let y = (rect.height - side)/2
		let origin = CGPoint(x: x, y: y)
		let size = CGSize(width: side, height: side)
		return NSRect(origin: origin, size: size)
	}
	
	func backgroundPath(in normalRect: NSRect) -> CGMutablePath {
		let insetsRect = NSInsetRect(normalRect, lineWidth/2, lineWidth/2)
		let path = CGMutablePath.superEllipse(forRect: insetsRect, cornerRadius: 4.0)
		return path
	}
	
	func outlinePath(in normalRect: NSRect) -> CGMutablePath {
		let insetsRect = NSInsetRect(normalRect, lineWidth/2, lineWidth/2)
		let path = CGMutablePath.superEllipse(forRect: insetsRect, cornerRadius: 4.0)
		return path
	}
	
	func tickPath(in normalRect: NSRect) -> CGMutablePath {
		
		let offset: CGFloat = 4.0
		let sideLength = min(normalRect.height - offset * 2, normalRect.width  - offset * 2)
		let scalingFactor: CGFloat = sideLength / 6.0
		let tickPath = CGMutablePath()
		tickPath.move(to: CGPoint(x: 1 * scalingFactor + offset, y: 3 * scalingFactor + offset))
		tickPath.addLine(to: CGPoint(x: 2.5 * scalingFactor + offset, y: 1.5 * scalingFactor + offset))
		tickPath.addLine(to: CGPoint(x: 5.5 * scalingFactor + offset, y: 4.5 * scalingFactor + offset))
		
		return tickPath
	}
	
	override var intrinsicContentSize: NSSize {
		return NSSize(width: 18.0, height: 18.0)
	}
	
	private func animation(for keyPath: String, from start: Any, to end: Any) -> CABasicAnimation {
		let animation = CABasicAnimation(keyPath: keyPath)
		animation.fromValue = start
		animation.toValue = end
		animation.duration = animationDuration
		animation.isRemovedOnCompletion = true
		animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
		return animation
	}
	
	private func animation(for keyPath: String, onValue: Any?, offValue: Any?, isOn: Bool, in layer: CALayer) -> CABasicAnimation {
		
		let endValue = isOn ? onValue : offValue
		let startValue = layer.presentation()?.value(forKeyPath: keyPath) ?? endValue
		
		let animation = CABasicAnimation(keyPath: keyPath)
		
		// Setup Finish State
		layer.setValue(endValue, forKeyPath: keyPath)
		animation.fromValue = startValue
		animation.toValue = endValue
		animation.duration = animationDuration
		animation.isRemovedOnCompletion = true
		animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
		return animation
	}
	
	func removeAllAnimations() {
		tickLayer.removeAllAnimations()
		outlineLayer.removeAllAnimations()
	}
	
	func animate() {
		print(#function)
		transientIsOn.toggle()
		sound?.stop()
		
		let tickOpacityAnimation			= self.animation(for: "opacity",
															 onValue: 1.0,
															 offValue: 0.0,
															 isOn: transientIsOn,
															 in: tickLayer)
		tickOpacityAnimation.delegate = self
		
		let tickStrokeEndAnimation			= self.animation(for: "strokeEnd",
															   onValue: 1.0,
															   offValue: 0.0,
															   isOn: transientIsOn,
															   in: tickLayer)
		
		let outlineOpacityAnimation 		= self.animation(for: "opacity",
															 onValue: 0.0,
															 offValue: 1.0,
															 isOn: transientIsOn,
															 in: outlineLayer)
		
		removeAllAnimations()
		
		CATransaction.begin()
		outlineLayer.add(outlineOpacityAnimation, forKey: "outlineOpacity")
		tickLayer.add(tickOpacityAnimation, forKey: "tickOpacity")
		tickLayer.add(tickStrokeEndAnimation, forKey: "tickStrokeEnd")
		CATransaction.commit()
		print("end animate")
	}
	
	func set(selected: Bool) {
		if selected {
			state.insert(.selected)
		} else {
			state.remove(.selected)
		}
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		updateLayerColors()
		CATransaction.commit()
	}
	
	override func viewDidChangeEffectiveAppearance() {
		super.viewDidChangeEffectiveAppearance()
		if effectiveAppearance.name == .darkAqua || effectiveAppearance.name == .vibrantDark {
			state.insert(.isDark)
		} else {
			state.remove(.isDark)
		}
		updateLayerColors()
	}
	
	@objc
	func tapped(_ sender: Any?) {
		print(#function)
		animate()
		
	}
}

extension CheckBox : CAAnimationDelegate {
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		if flag {
			self.isOn = transientIsOn
			self.handler?(isOn)
			if isOn { sound?.play() }
		}
	}
}
