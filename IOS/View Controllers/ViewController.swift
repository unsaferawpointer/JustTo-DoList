//
//  ViewController.swift
//  JustTo-DoList-IOS
//
//  Created by Anton Cherkasov on 04.10.2021.
//

import UIKit

class ViewController: UIViewController {
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError()
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		fatalError()
	}
	
	override func loadView() {
		self.view = UIView()
		self.view.backgroundColor = .blue
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}

}

