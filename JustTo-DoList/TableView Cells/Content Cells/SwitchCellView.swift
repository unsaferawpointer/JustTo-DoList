//
//  SwitchCellView.swift
//  CompactToDo
//
//  Created by Anton Cherkasov on 06.08.2021.
//

import AppKit
import Combine

class SwitchCellView: NSTableCellView {
	
	var button: SwitchButtonProtocol?
	var completionHandler: ((Bool) -> ())?
	
	var subsription: AnyCancellable?
	
	override var backgroundStyle: NSView.BackgroundStyle {
		didSet {
			let selected = backgroundStyle == .emphasized
			button?.set(selected: selected)
		}
	}
	
	func subsribe<T: NSManagedObject>(keyPath: KeyPath<T, Bool>, in object: T) {
		subsription = object.publisher(for: keyPath)
			.sink { [weak self] isOn in
				self?.set(isOn: isOn)
			}
	}
	
	// #START	******** Init Block ********
	
	init(button: SwitchButtonProtocol) {
		self.button = button
		super.init(frame: .zero)
		self.addSubview(button)
		configure()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		configure()
	}
	
	func set(isOn: Bool) {
		button?.set(isOn: isOn)
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
		button?.removeAllAnimations()
		subsription?.cancel()
	}
	
	// #END		******** Init Block ********
	
	@objc func clicked(_ sender: NSButton) {
		
	}

}
