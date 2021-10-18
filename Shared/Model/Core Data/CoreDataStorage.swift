//
//  CoreDataStorage.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 08.08.2021.
//

#if os(macOS)
import AppKit
#endif
import CloudKit
import CoreData

class CoreDataStorage {
	
	static let shared = CoreDataStorage()
	
	var errorHandler: (() -> (Error))?
	
	private init() { }
	
	var mainContext: NSManagedObjectContext {
		return persistentContainer.viewContext
	}
	
	func createPrivateContext() -> NSManagedObjectContext {
		return persistentContainer.newBackgroundContext()
	}
	
	// MARK: - Core Data stack
	
	lazy var persistentContainer: NSPersistentCloudKitContainer = {
		/*
		The persistent container for the application. This implementation
		creates and returns a container, having loaded the store for the
		application to it. This property is optional since there are legitimate
		error conditions that could cause the creation of the store to fail.
		*/
		let container = NSPersistentCloudKitContainer(name: "Done")
		container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
		
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				/*
				Typical reasons for an error here include:
				* The parent directory does not exist, cannot be created, or disallows writing.
				* The persistent store is not accessible, due to permissions or data protection when the device is locked.
				* The device is out of space.
				* The store could not be migrated to the current model version.
				Check the error message to determine what the actual problem was.
				*/
				fatalError("Unresolved error \(error)")
			}
		})
		container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		container.viewContext.automaticallyMergesChangesFromParent = true
		return container
	}()
	
	// MARK: - Core Data Saving and Undo support
	
	func saveAction(_ sender: AnyObject?) {
		// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
		let context = persistentContainer.viewContext
		
		#if os(macOS)
		if !context.commitEditing() {
			NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
		}
		#endif
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				// Customize this code block to include application-specific recovery steps.
				let nserror = error as NSError
				#if os(macOS)
				NSApplication.shared.presentError(nserror)
				#endif
			}
		}
	}
	
	#if os(macOS)
	func canTerminate(_ sender: NSApplication) -> Bool {
		let context = persistentContainer.viewContext
		if !context.commitEditing() {
			NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
			return false
		}
		if !context.hasChanges {
			return true
		}
		do {
			try context.save()
		} catch {
//			let nserror = error as NSError
//
//			// Customize this code block to include application-specific recovery steps.
//			let result = sender.presentError(nserror)
//			if (result) {
//				return false
//			}
//
//
//			let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
//			let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
//			let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
//			let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
//			let alert = NSAlert()
//			alert.messageText = question
//			alert.informativeText = info
//			alert.addButton(withTitle: quitButton)
//			alert.addButton(withTitle: cancelButton)
//
//			let answer = alert.runModal()
//			if answer == .alertSecondButtonReturn {
//				return false
//			}
			
		}
		// If we got here, it is time to quit.
		return true
	}
	#endif
	
}

extension CoreDataStorage {
	
	var newBackgroundContext: NSManagedObjectContext {
		persistentContainer.newBackgroundContext()
	}
	
	func performForeground(block: @escaping (NSManagedObjectContext) -> Void) {
		mainContext.perform { block(self.mainContext) }
	}
	
	func performBackground(block: @escaping (NSManagedObjectContext) -> Void) {
		persistentContainer.performBackgroundTask(block)
	}
	
}
