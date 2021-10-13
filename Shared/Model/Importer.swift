//
//  Importer.swift
//  Done
//
//  Created by Anton Cherkasov on 08.10.2021.
//

import Foundation
import CoreDataStore

protocol Importer {
	func importItems()
}

class TasksImporter {
	
	var progressBlock: (Double) -> Void
	var completionBlock: () -> Void
	
	init(progressBlock: @escaping (Double) -> Void, completionBlock: @escaping () -> Void) {
		self.progressBlock = progressBlock
		self.completionBlock = completionBlock
	}
	
	func importItems(from text: String) {
		
		CoreDataStorage.shared.persistentContainer.performBackgroundTask { privateContext in
			let factory = ObjectFactory<Task>(viewContext: privateContext)
			var lines = [String]()
			text.enumerateLines { line, _ in
				lines.append(line)
			}
			var numberOfCurrentLine = 0
			lines.forEach {
				factory.newObject(with: $0, for: \.text)
				DispatchQueue.main.async {
					if lines.count > 0 {
						let progress = Double(numberOfCurrentLine) / Double(lines.count)
						print("progress = \(progress)")
						self.progressBlock(progress)
					}
				}
				numberOfCurrentLine += 1
			}
			try? privateContext.save()
			DispatchQueue.main.async {
				self.completionBlock()
			}
		}
	}
}
