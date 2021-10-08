//
//  SwitchCellView.swift
//  CompactToDo
//
//  Created by Anton Cherkasov on 06.08.2021.
//

import AppKit
import Combine

protocol ToggleableButton : NSView {
	func set(isOn: Bool)
	var backgroundStyle: NSView.BackgroundStyle { get set }
	var handler: ((Bool) -> ())? { get set }
	func forceStopAnimation()
}

class ToggleCellView: NSTableCellView {
	
	var button: ToggleableButton?
	var completionHandler: ((Bool) -> ())?
	
	var subsription: AnyCancellable?
	
	override var backgroundStyle: NSView.BackgroundStyle {
		didSet {
			button?.backgroundStyle = backgroundStyle
		}
	}
	
	func observe<T: NSManagedObject>(keyPath: KeyPath<T, Bool>, in object: T) {
		subsription = object.publisher(for: keyPath)
			.sink { [weak self] isOn in
				self?.set(isOn: isOn)
			}
	}
	
	// #START	******** Init Block ********
	
	init(button: ToggleableButton) {
		self.button = button
		super.init(frame: .zero)
		self.addSubview(button)
		configure()
		
	}
	
	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()
		
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		configure()
	}
	
	func set(isOn: Bool) {
		button?.set(isOn: isOn)
	}
	
	override func mouseEntered(with event: NSEvent) {
		print(#function)
		button?.isHidden = false
	}
	
	override func mouseExited(with event: NSEvent) {
		button?.isHidden = true
	}
	
	private func configure() {
		
		guard let button = button else {
			return
		}
		button.handler = { [weak self] isOn in
			self?.completionHandler?(isOn)
		}
		// Constraints
		button.translatesAutoresizingMaskIntoConstraints = false
		self.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
		self.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		button?.forceStopAnimation()
		subsription?.cancel()
	}
	
	// #END		******** Init Block ********
	
	@objc func clicked(_ sender: NSButton) {
		
	}

}
