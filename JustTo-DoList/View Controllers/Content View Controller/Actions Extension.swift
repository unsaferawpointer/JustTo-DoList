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
		factory.duplicate(objects: selectedTasks)
	}
	
	@objc
	func markCompleted(_ sender: Any?) {
		factory.set(value: true, for: \.transientIsDone, to: selectedTasks)
	}
	
	@objc
	func markIncomplete(_ sender: Any?) {
		factory.set(value: false, for: \.transientIsDone, to: selectedTasks)
	}
	
	@objc
	func toFavorites(_ sender: Any?) {
		factory.set(value: true, for: \.isFavorite, to: selectedTasks)
	}
	
	@objc
	func fromFavorites(_ sender: Any?) {
		factory.set(value: false, for: \.isFavorite, to: selectedTasks)
	}
	
	@objc
	func delete(_ sender: Any?) {
		factory.delete(objects: selectedTasks)
	}
}
