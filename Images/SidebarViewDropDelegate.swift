//
//  SidebarViewDropDelegate.swift
//  Images
//
//  Created by Connor Barnes on 3/15/21.
//

import SwiftUI

struct SidebarDropDelegate: DropDelegate {
	var viewContext: NSManagedObjectContext
	var destination: Directory
	
	func performDrop(info: DropInfo) -> Bool {
		guard validateDrop(info: info) else {
			return false
		}
		
		let items = info.itemProviders(for: [Directory.typeIdentifier])
		for item in items {
			_ = item.loadObject(ofClass: URL.self) { (url, _) in
				if let url = url {
					let coordinator = viewContext
						.persistentStoreCoordinator
					if let objectID = coordinator?
							.managedObjectID(forURIRepresentation: url) {
						if let directory = viewContext
								.object(with: objectID)
								as? Directory {
							directory.parent = destination
						}
					}
				}
			}
		}
		
		return true
	}
	
	func validateDrop(info: DropInfo) -> Bool {
		return info.hasItemsConforming(to: [Directory.typeIdentifier])
	}
}
