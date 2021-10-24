//
//  Task+CoreDataProperties.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 09.08.2021.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public private (set) var id: UUID
    @NSManaged public var text: String
    @NSManaged public private (set) var isDone: Bool
    @NSManaged public private (set) var creationDate: Date
    @NSManaged public private (set) var completionDate: Date?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var typeMask: Int16
	
	@NSManaged public var list: List?
	
	public override func awakeFromInsert() {
		super.awakeFromInsert()
		self.id = UUID()
		self.text = "New To Do"
		self.isDone = false
		self.creationDate = Date()
		self.completionDate = nil
		self.isFavorite = false
		self.typeMask = 0
	}
	
	var transientIsDone: Bool {
		get {
			return isDone
		}
		set {
			if self.isDone != newValue {
				self.completionDate = newValue ? Date() : nil
				self.isDone = newValue
			}
		}
	}
	
	public override func awakeFromFetch() {
		super.awakeFromFetch()
		print(#function)
		print("text = \(text)")
		list?.addObserver(self, forKeyPath: "name", options: [NSKeyValueObservingOptions.new], context: nil)
	}
	
	public override func willTurnIntoFault() {
		print(#function)
		print("text = \(text)")
		super.willTurnIntoFault()
		list?.removeObserver(self, forKeyPath: "name")
	}
	
	public override func didTurnIntoFault() {
		print(#function)
		print("text = \(text)")
		super.didTurnIntoFault()
	}
	
	public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		switch (keyPath, context) {
		case ("name", _):
			print("isFault = \(isFault)")
			managedObjectContext?.refresh(self, mergeChanges: true)
		default:
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}

}

extension Task : Identifiable {

}
