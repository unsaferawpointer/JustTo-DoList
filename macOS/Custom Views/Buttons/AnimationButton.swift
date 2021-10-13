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
			animationLayersGroup.set(selected: backgroundStyle == .emphasized)
		}
	}
	

	
	var handler: ((Bool) -> Void)?
	
	func forceStopAnimation() {
		animationLayersGroup.stopAnimation()
	}
	
	var isOn: Bool = false {
		didSet {
			animationLayersGroup.set(inverted: isOn)
		}
	}
	
	var animationLayersGroup = AnimationLayersGroup()
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		configureAnimationLayers()
		setupGesture()
	}
	
	func configureAnimationLayers() {
		animationLayersGroup.add(layers: createAnimationLayers())
		animationLayersGroup.delegate = self
		self.wantsLayer = true
		for animationLayer in animationLayersGroup.layers {
			self.layer?.addSublayer(animationLayer)
		}
	}
	
	func createAnimationLayers() -> [AnimationLayer] {
		return [AnimationLayer()]
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layout() {
		super.layout()
		configureFrames()
	}
	
	override var intrinsicContentSize: NSSize {
		return NSSize(width: 19.0, height: 19.0)
	}
	
	private func setupGesture() {
		let gesture = NSClickGestureRecognizer(target: self, action: #selector(clicked(_:)))
		gesture.numberOfClicksRequired = 1
		self.addGestureRecognizer(gesture)
	}
	
	func configureFrames() {
		
		let square = getMaxSquare(for: bounds)
		let path = createStarPath(in: square, inset: square.height/10)
		animationLayersGroup.layers.first!.path = path
		
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
		firstState.shapeState.lineWidth = 1.5
		firstState.shadowState = grayShadow
		firstState.shapeState.strokeColor = .secondaryLabelColor
		firstState.scale = 0.85
		
		var secondState = AnimationState()
		secondState.shapeState.fillColor = nil
		secondState.shapeState.lineWidth = 1.5
		secondState.shadowState = grayShadow
		secondState.shapeState.strokeColor = .systemYellow
		secondState.scale = 1.1
		
		var thirdState = AnimationState()
		thirdState.shapeState.fillColor = .systemYellow
		thirdState.shapeState.lineWidth = 1.5
		thirdState.shadowState = yellowShadow
		thirdState.shapeState.strokeColor = .systemYellow
		thirdState.scale = 0.85
		
		animationLayersGroup.layers.first!.add(state: firstState, withDuration: 0.1)
		animationLayersGroup.layers.first!.add(state: secondState, withDuration: 0.5)
		animationLayersGroup.layers.first!.add(state: thirdState, withDuration: 0.9)
		
		animationLayersGroup.layers.first!.animationIsInverted = isOn
		animationLayersGroup.layers.first!.frame = self.bounds
		animationLayersGroup.layers.first!.invalidate()
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
		animationLayersGroup.startAnimation()
	}
}

extension AnimationButton : AnimationLayerDelegate {
	func animationDidStart() {
		
	}
	func animationDidFinished() {
		handler?(!isOn)
	}
}
