//
//  File.swift
//  Fluffy
//
//  Created by Connor Barnes on 2/20/21.
//
//

import Foundation
import CoreData

@objc(File)
class File: NSManagedObject {
	/// Creates a fetch request for objects of type `File`.
	/// - Returns: A fetch request for file objects.
	@nonobjc class func fetchRequest() -> NSFetchRequest<File> {
			return NSFetchRequest<File>(entityName: "File")
	}

	/// A custom name for the file given by the user.
	@objc(customName)
	@NSManaged var customName: String?
	
	/// The file url of the file.
	@objc(url)
	@NSManaged var url: URL?
	
	/// The date and time the file was imported into the program.
	@objc(dateImported)
	@NSManaged var dateImported: Date?
	
	/// The parent directory of the file.
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
