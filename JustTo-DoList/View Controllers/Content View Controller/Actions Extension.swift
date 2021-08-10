//
//  Actions Extension.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 08.08.2021.
//

import Foundation

extension ContentViewController {
	@objc
	func newTask(_ sender: Any?) {
		print(#function)
		factory.newObject()
	}
	@objc
	func duplicate(_ sender: Any?) {
		factory.duplicate(object: <#T##Task#>)
	}
}
