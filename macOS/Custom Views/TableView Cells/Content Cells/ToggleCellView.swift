//
//  SwitchCellView.swift
//  CompactToDo
//
//  Created by Anton Cherkasov on 06.08.2021.
//

import AppKit
import Combine

protocol ToggleableButton : NSView {
	var isOn: Bool { get set }
	var backgroundStyle: NSView.BackgroundStyle { get set }
	var handler: ((Bool) -> ())? { get set }
	func forceStopAnimation()
}

class ToggleCellView: NSTableCellView {
	
	var button: ToggleableButton?
	var completionHandler: ((Bool) -> ())?
	
	var isOn: Bool = false {
		didSet {
			button?.isOn = isOn
		}
	}
	
	var subsription: AnyCancellable?
	
	override func accessibilityValue() -> Any? {
		return true
	}
	
	override func accessibilityLabel() -> String? {
		return "Чекбокс \(true ? "выполнено" : "не выполнено")"
	}
	
	override var backgroundStyle: NSView.BackgroundStyle {
		didSet {
			button?.backgroundStyle = backgroundStyle
		}
	}
	
//	func observe<T: NSManagedObject>(keyPath: KeyPath<T, Bool>, in object: T) {
//		subsription = object.publisher(for: keyPath)
//			.sink { [weak self] isOn in
//				self?.set(isOn: isOn)
//			}
//	}
	
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
