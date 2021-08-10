//
//  StarButton.swift
//  CompactToDo
//
//  Created by Anton Cherkasov on 30.07.2021.
//

import AppKit

class StarButton: NSView, SwitchButtonProtocol {
	
	private var isOn: Bool = false
	private var transientIsOn: Bool = false
	var handler: ((Bool) -> ())?
	
	struct UIStateOptions : OptionSet {
		let rawValue: Int
		static let isDark = UIStateOptions(rawValue: 1 << 0)
		static let selected = UIStateOptions(rawValue: 1 << 1)
	}
	
	var state: UIStateOptions = []
	
	var sound = NSSound(named: "sound")
	
	var animationDuration 	= 0.2
	var lineWidth: CGFloat	= 1.2
	
	var outlineLayer: CAShapeLayer!
	
	func degree2radian(a : CGFloat) -> CGFloat {
		let b = .pi * a/180
		return b
	}
	
	func polygonPointArray(sides: Int, x: CGFloat, y: CGFloat, radius: CGFloat, adjustment: CGFloat = 0.0) -> [CGPoint] {
		let angle = degree2radian(a: 360/CGFloat(sides))
		let cx = x // x origin
		let cy = y // y origin
		let r  = radius // radius of circle
		var i = sides
		var points = [CGPoint]()
		while points.count <= sides {
			let xpo = cx - r * cos(angle * CGFloat(i)+degree2radian(a: adjustment))
			let ypo = cy - r * sin(angle * CGFloat(i)+degree2radian(a: adjustment))
			points.append(CGPoint(x: xpo, y: ypo))
			i -= 1
		}
		return points
	}
	
	func path(in rect: CGRect, corners: Int, smoothness: CGFloat) -> CGMutablePath {
		// ensure we have at least two corners, otherwise send back an empty path
		guard corners >= 2 else { return CGMutablePath() }
		
		// draw from the center of our rectangle
		let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
		
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
		
	}
	
	private func updateLayers() {
		updateLayerColors()
	}
	
	private func updateLayerColors() {
		
		if state.contains(.selected) {
			outlineLayer.fillColor = transientIsOn ? NSColor.white.cgColor : NSColor.clear.cgColor
			outlineLayer.strokeColor = transientIsOn ? NSColor.white.cgColor : NSColor.white.cgColor
			outlineLayer.shadowColor = transientIsOn ? NSColor.white.cgColor : NSColor.white.cgColor
		} else {
			outlineLayer.fillColor = transientIsOn ? NSColor.systemYellow.cgColor : NSColor.clear.cgColor
			outlineLayer.strokeColor = transientIsOn ? NSColor.systemYellow.cgColor : NSColor.gray.cgColor
			outlineLayer.shadowColor = transientIsOn ? NSColor.systemYellow.cgColor : NSColor.gray.cgColor
		}
		
	}
	
	func set(isOn: Bool) {
		removeAllAnimations()
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		self.transientIsOn = isOn
		self.isOn = isOn
		updateLayers()
		CATransaction.commit()
	}
	
	// Generate CGPath after layout
	override func layout() {
		super.layout()
		let normalRect = rectangle(in: self.bounds)
		outlineLayer.path = star(in: normalRect)
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
	
	func star(in normalRect: NSRect, offset: CGFloat = 0.0) -> CGMutablePath {
		let insetsRect = NSInsetRect(normalRect, lineWidth/2, lineWidth/2)
		let path = self.path(in: insetsRect, corners: 5, smoothness: 0.5)
		return path
	}
	
	override var intrinsicContentSize: NSSize {
		return NSSize(width: 18.0, height: 18.0)
	}
	
	func removeAllAnimations() {
		outlineLayer.removeAllAnimations()
	}
	
	func animate() {
		
		transientIsOn.toggle()
		sound?.stop()
		
		removeAllAnimations()
		
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		updateLayerColors()
		CATransaction.commit()
		
		let fillColorAnimation = CAKeyframeAnimation(keyPath: #keyPath(CAShapeLayer.fillColor))
		if state.contains(.selected) {
			fillColorAnimation.values = transientIsOn ? [CGColor.clear, CGColor.clear, NSColor.white.cgColor] : [NSColor.white.cgColor, NSColor.white.cgColor, CGColor.clear]
		} else {
			fillColorAnimation.values = transientIsOn ? [CGColor.clear, CGColor.clear, NSColor.systemYellow.cgColor] : [NSColor.systemYellow.cgColor, NSColor.systemYellow.cgColor, CGColor.clear]
		}
		
		fillColorAnimation.keyTimes = [0.1, 0.7, 1]
		
		let strokeColorAnimation = CAKeyframeAnimation(keyPath: #keyPath(CAShapeLayer.strokeColor))
		if state.contains(.selected) {
			strokeColorAnimation.values = transientIsOn ? [NSColor.white.cgColor, NSColor.white.cgColor, NSColor.white.cgColor] : [NSColor.white.cgColor, NSColor.white.cgColor, NSColor.white.cgColor]
		} else {
			strokeColorAnimation.values = transientIsOn ? [NSColor.gray.cgColor, NSColor.gray.cgColor, NSColor.systemYellow.cgColor] : [NSColor.systemYellow.cgColor, NSColor.systemYellow.cgColor, NSColor.gray.cgColor]
		}

		strokeColorAnimation.keyTimes = [0.1, 0.7, 1]
		
		let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
		scaleAnimation.values = transientIsOn ? [1.0, 1.2, 1.0] : [1.0, 1.2, 1.0]
		scaleAnimation.keyTimes = [0.1, 0.4, 1.0]
		
		let shadowColorAnimation = CAKeyframeAnimation(keyPath: #keyPath(CAShapeLayer.shadowColor))
		shadowColorAnimation.values = transientIsOn ? [NSColor.gray.cgColor, NSColor.gray.cgColor, NSColor.systemYellow.cgColor] : [NSColor.systemYellow.cgColor, NSColor.systemYellow.cgColor, NSColor.gray.cgColor]
		shadowColorAnimation.keyTimes = [0.1, 0.85, 1]
		
		let outlineGroupAnimation = CAAnimationGroup()
		outlineGroupAnimation.duration = animationDuration
		outlineGroupAnimation.isRemovedOnCompletion = true
		outlineGroupAnimation.delegate = self
		outlineGroupAnimation.animations = [fillColorAnimation,
											strokeColorAnimation,
											scaleAnimation,
											shadowColorAnimation]
		
		CATransaction.begin()
		outlineLayer.add(outlineGroupAnimation, forKey: "outlineOpacity")
		CATransaction.commit()
	}
	
	func set(selected: Bool) {
		if selected {
			state.insert(.selected)
		} else {
			state.remove(.selected)
		}
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		updateLayers()
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

extension StarButton : CAAnimationDelegate {
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		if flag {
			self.isOn = transientIsOn
			self.handler?(isOn)
			if isOn { sound?.play() }
		}
	}
}



