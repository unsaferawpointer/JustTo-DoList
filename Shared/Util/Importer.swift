//
//  Importer.swift
//  Done
//
//  Created by Anton Cherkasov on 08.10.2021.
//

import Foundation
import CoreDataStore
import CoreData

//class ImportTasksOperation: Operation {
//
//	var text: String
//
//	init(text: String) {
//		super.init()
//	}
//
//	override func main() {
//		let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//		let factory = ObjectFactory<Task>(viewContext: privateContext)
//		var lines = [String]()
//		text.enumerateLines { line, _ in
//			lines.append(line)
//		}
//		var numberOfCurrentLine = 0
//		lines.forEach {
//		#warning("Remove sleep")
//			sleep(1)
//			factory.newObject(with: $0, for: \.text)
//			DispatchQueue.main.async {
//				if lines.count > 0 {
//					let progress = Double(numberOfCurrentLine) / Double(lines.count)
//					self.progressBlock(progress)
//				}
//			}
//			numberOfCurrentLine += 1
//		}
//		privateContext.parent = CoreDataStorage.shared.mainContext
//		try? privateContext.save()
//		DispatchQueue.main.async {
//			self.completionBlock()
//		}
//	}
//}

class TasksImporter {
	
	var progressBlock: (Double) -> Void
	var completionBlock: () -> Void
	
	var operationQueue = OperationQueue()
	var isCancelled = false
	
	init(progressBlock: @escaping (Double) -> Void, completionBlock: @escaping () -> Void) {
		self.progressBlock = progressBlock
		self.completionBlock = completionBlock
		operationQueue.maxConcurrentOperationCount = 1
	}
	
	func cancel() {
		isCancelled = true
	}
	
	func importItems(from text: String) {
		
		let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		let operationBlock = BlockOperation {
			let factory = ObjectFactory<Task>(viewContext: privateContext)
			var lines = [String]()
			text.enumerateLines { line, _ in
				lines.append(line)
			}
			var numberOfCurrentLine = 0
			lines.forEach {
			#warning("Remove sleep")
				sleep(1)
				factory.newObject(with: $0, for: \.text)
				DispatchQueue.main.async {
					if lines.count > 0 {
						let progress = Double(numberOfCurrentLine) / Double(lines.count)
						self.progressBlock(progress)
					}
				}
				numberOfCurrentLine += 1
			}
			privateContext.parent = CoreDataManager.shared.mainContext
			try? privateContext.save()
			DispatchQueue.main.async {
				self.completionBlock()
			}
		}
		operationQueue.addOperation(operationBlock)
	}
}
