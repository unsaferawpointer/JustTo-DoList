//
//  Task+CoreDataClass.swift
//  JustTo-DoList
//
//  Created by Anton Cherkasov on 09.08.2021.
//
//

import Foundation
import CoreData

@objc(Task)
public class Task: NSManagedObject {

}

extension Task : Duplicatable {
	func duplicate() -> Self {
		return self
	}
}
