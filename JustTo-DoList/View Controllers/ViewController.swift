//
//  ViewController.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 08.08.2021.
//

import Cocoa

class ViewController: NSViewController {
	
	override func loadView() {
		self.view = NSView()
		
//		self.view.wantsLayer = true
//		self.view.layer?.backgroundColor = NSColor.yellow.cgColor
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

