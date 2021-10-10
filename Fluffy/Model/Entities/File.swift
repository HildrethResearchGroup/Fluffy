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
	@NSManaged var dateImported: Date
	
	/// The parent directory of the file.
	@objc(parent)
	@NSManaged var parent: Directory?
    
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(Date(), forKey: "dateImported")
    }
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
    
    /// The Imported date formated as a String
    var dateImportedString: String {
        let dateString = self.dateImported.formatted(date: .abbreviated, time: .omitted)
        return dateString
    }
    
    /// Organized path to file location within the application.
    /// Note: this is not the stored file path
    var organizedPath: String {
        var path = parent?.organizedPath ?? ""
        path.append("/" + self.displayName)
        return path
    }
    
    /// File size in MB
    var fileSize: String {
        var fileSizeString = ""

        guard let urlPath = self.url?.path else {
            return fileSizeString
        }
        
        guard let attr = try? FileManager.default.attributesOfItem(atPath: urlPath) else {
            return fileSizeString
        }
       
        
        guard let fileSize = attr[FileAttributeKey.size] as? UInt64 else {
            return fileSizeString
        }
        
        fileSizeString = String(format: "%0.02f", Double(fileSize)/1E6)
        
        return fileSizeString
    }
    
}
