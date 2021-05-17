//
//  File.swift
//  Images
//
//  Created by Connor Barnes on 2/20/21.
//
//

import Foundation
import CoreData

@objc(File)
class File: NSManagedObject {
	@nonobjc class func fetchRequest() -> NSFetchRequest<File> {
			return NSFetchRequest<File>(entityName: "File")
	}

	@objc(customName)
	@NSManaged var customName: String?
	
	@objc(url)
	@NSManaged var url: URL?
	
	@objc(dateImported)
	@NSManaged var dateImported: Date?
	
	@objc(parent)
	@NSManaged var parent: Directory?
}

// MARK:- Identifiable
extension File: Identifiable {
	public var id: NSManagedObjectID {
		return self.objectID
	}
}

// MARK:- Computed properties
extension File {
	/// The display name to show the user for the file.
	var displayName: String {
		return customName ?? fileName ?? ""
	}
	
	/// The name of the file as determined from its URL. `nil` if the image has no URL.
	var fileName: String? {
		return url?
			.deletingPathExtension()
			.lastPathComponent
	}
}
