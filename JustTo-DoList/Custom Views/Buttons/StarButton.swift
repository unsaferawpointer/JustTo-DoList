//
//  StarButton.swift
//  CompactToDo
//
//  Created by Anton Cherkasov on 30.07.2021.
//

import AppKit

class AnimationButton: NSView, ToggleableButton {
	
	//
	func set(isOn: Bool) {
		self.isOn = isOn
	}
	
	var backgroundStyle: NSView.BackgroundStyle = .normal {
		didSet {
			if backgroundStyle == .emphasized {
				animatableLayer.isSelected = true
			} else {
				animatableLayer.isSelected = false
			}
			
		}
	}
	
	var handler: ((Bool) -> ())?
	
	func forceStopAnimation() {
		animatableLayer.stopAnimation()
	}
	//
	
	var isOn: Bool = false {
		didSet {
			animatableLayer.animationIsInverted = isOn
		}
	}
	
	var animatableLayer : AnimationLayer!
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		configureAnimationLayer()
		setupGesture()
	}
	
	private func configureAnimationLayer() {
		let animationLayer = AnimationLayer()
		self.animatableLayer = animationLayer
		self.wantsLayer = true
		self.layer?.addSublayer(animationLayer)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layout() {
		super.layout()
		configureFrames()
	}
	
	override func viewDidChangeEffectiveAppearance() {
		super.viewDidChangeEffectiveAppearance()
		configureFrames()
	}
	
	override var intrinsicContentSize: NSSize {
		return NSSize(width: 21.0, height: 21.0)
	}
	
	private func setupGesture() {
		let gesture = NSClickGestureRecognizer(target: self, action: #selector(clicked(_:)))
		gesture.numberOfClicksRequired = 1
		self.addGestureRecognizer(gesture)
	}
	
	func configureFrames() {
		
		let square = getMaxSquare(for: bounds)
		let path = createStarPath(in: square, inset: square.height/10)
		animatableLayer.path = path
		
		let grayShadow = ShadowState(shadowColor: .lightGray,
								 shadowOpacity: 0.1,
								 shadowOffset: .zero,
								 shadowRadius: 2.0,
								 shadowPath: nil)
		
		let yellowShadow = ShadowState(shadowColor: .systemYellow,
									   shadowOpacity: 0.1,
									   shadowOffset: .zero,
									   shadowRadius: 2.0,
									   shadowPath: nil)
		
		var firstState = AnimationState()
		firstState.shapeState.fillColor = nil
		firstState.shadowState = grayShadow
		firstState.shapeState.strokeColor = .secondaryLabelColor
		firstState.scale = 0.85
		
		var secondState = AnimationState()
		secondState.shapeState.fillColor = nil
		secondState.shadowState = grayShadow
		secondState.shapeState.strokeColor = .secondaryLabelColor
		secondState.scale = 1.0
		
		var thirdState = AnimationState()
		thirdState.shapeState.fillColor = .systemYellow
		thirdState.shadowState = yellowShadow
		thirdState.shapeState.strokeColor = .systemYellow
		thirdState.scale = 0.85
		
		animatableLayer.add(state: firstState, withDuration: 0.1)
		animatableLayer.add(state: secondState, withDuration: 0.5)
		animatableLayer.add(state: thirdState, withDuration: 0.9)
		
		animatableLayer.animationIsInverted = isOn
		animatableLayer.frameAnimationDelegate = self
		animatableLayer.frame = self.bounds
		animatableLayer.invalidate()
	}
	
	func getMaxSquare(for rect: NSRect) -> NSRect {
		let side = min(rect.height, rect.width)
		let x = (rect.width - side)/2
		let y = (rect.height - side)/2
		let origin = CGPoint(x: x, y: y)
		let size = CGSize(width: side, height: side)
		return NSRect(origin: origin, size: size)
	}
	
	func createStarPath(in normalRect: NSRect, inset: CGFloat) -> CGMutablePath {
		let insetsRect = NSInsetRect(normalRect, 2.0/2 + inset, 2.0/2 + inset)
		let path = CGMutablePath.star(in: insetsRect, corners: 5, smoothness: 0.5)
		return path
	}

	@objc
	func clicked(_ sender: Any?) {
		animatableLayer.startAnimation()
	}
}

extension AnimationButton : AnimationLayerDelegate {
	
	func animationDidFinished() {
		handler?(!isOn)
	}
}
