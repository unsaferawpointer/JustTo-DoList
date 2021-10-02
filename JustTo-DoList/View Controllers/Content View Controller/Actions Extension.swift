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
		presenter.duplicate()
	}
	
	@objc
	func markCompleted(_ sender: Any?) {
		presenter.markCompleted()
	}
	
	@objc
	func markIncomplete(_ sender: Any?) {
		presenter.markIncomplete()
	}
	
	@objc
	func toFavorites(_ sender: Any?) {
		presenter.toFavorites()
	}
	
	@objc
	func fromFavorites(_ sender: Any?) {
		presenter.fromFavorites()
	}
	
	@objc
	func delete(_ sender: Any?) {
		presenter.delete()
	}
}
