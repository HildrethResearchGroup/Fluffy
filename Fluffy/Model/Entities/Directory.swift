//
//  Directory.swift
//  Fluffy
//
//  Created by Connor Barnes on 2/20/21.
//
//

import Foundation
import CoreData

@objc(Directory)
public class Directory: NSManagedObject {
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Directory> {
		return NSFetchRequest<Directory>(entityName: "Directory")
	}
	
	@objc(customName)
	@NSManaged var customName: String?
	
	@objc(url)
	@NSManaged var url: URL?
	
	@objc(collapsed)
	@NSManaged var collapsed: Bool
	
	@objc(dateImported)
	@NSManaged var dateImported: Date?
	
	@objc(parent)
	@NSManaged var parent: Directory?
	
	@objc(subdirectories)
	@NSManaged var subdirectories: NSOrderedSet
	
	@objc(files)
	@NSManaged var files: NSOrderedSet
}

// MARK:- Generated accessors for subdirectories
extension Directory {
	@objc(insertObject:inSubdirectoriesAtIndex:)
	@NSManaged func insertIntoSubdirectories(_ value: Directory, at idx: Int)
	
	@objc(removeObjectFromSubdirectoriesAtIndex:)
	@NSManaged func removeFromSubdirectories(at idx: Int)
	
	@objc(insertSubdirectories:atIndexes:)
	@NSManaged func insertIntoSubdirectories(_ values: [Directory], at indexes: NSIndexSet)
	
	@objc(removeSubdirectoriesAtIndexes:)
	@NSManaged func removeFromSubdirectories(at indexes: NSIndexSet)
	
	@objc(replaceObjectInSubdirectoriesAtIndex:withObject:)
	@NSManaged func replaceSubdirectories(at idx: Int, with value: Directory)
	
	@objc(replaceSubdirectoriesAtIndexes:withSubdirectories:)
	@NSManaged func replaceSubdirectories(at indexes: NSIndexSet, with values: [Directory])
	
	@objc(addSubdirectoriesObject:)
	@NSManaged func addToSubdirectories(_ value: Directory)
	
	@objc(removeSubdirectoriesObject:)
	@NSManaged func removeFromSubdirectories(_ value: Directory)
	
	@objc(addSubdirectories:)
	@NSManaged func addToSubdirectories(_ values: NSOrderedSet)
	
	@objc(removeSubdirectories:)
	@NSManaged func removeFromSubdirectories(_ values: NSOrderedSet)
	
}

// MARK:- Generated accessors for files
extension Directory {
	@objc(insertObject:inFilesAtIndex:)
	@NSManaged func insertIntoFiles(_ value: File, at idx: Int)
	
	@objc(removeObjectFromFilesAtIndex:)
	@NSManaged func removeFromFiles(at idx: Int)
	
	@objc(insertFiles:atIndexes:)
	@NSManaged func insertIntoFiles(_ values: [File], at indexes: NSIndexSet)
	
	@objc(removeFilesAtIndexes:)
	@NSManaged func removeFromFiles(at indexes: NSIndexSet)
	
	@objc(replaceObjectInFilesAtIndex:withObject:)
	@NSManaged func replaceFiles(at idx: Int, with value: File)
	
	@objc(replaceFilesAtIndexes:withFiles:)
	@NSManaged func replaceFiles(at indexes: NSIndexSet, with values: [File])
	
	@objc(addFilesObject:)
	@NSManaged func addToFiles(_ value: File)
	
	@objc(removeFilesObject:)
	@NSManaged func removeFromFiles(_ value: File)
	
	@objc(addFiles:)
	@NSManaged func addToFiles(_ values: NSOrderedSet)
	
	@objc(removeFiles:)
	@NSManaged func removeFromFiles(_ values: NSOrderedSet)
}

// MARK:- Computed Properties
extension Directory {
	/// The directories subdirectories as an array.
	var subdirectoriesArray: [Directory]? {
		if subdirectories.count > 0 {
			return subdirectories.array.map { $0 as! Directory }
		} else {
			return nil
		}
	}
	
	/// The name of the directory.
	var name: String {
		return customName ?? url?.lastPathComponent ?? ""
	}
	
	/// The recursive parent directories of this directory.
	var ancestors: Set<Directory> {
		var ancestors: Set<Directory> = []
		var parent = self.parent
		
		while let nextParent = parent {
			ancestors.insert(nextParent)
			parent = nextParent.parent
		}
		
		return ancestors
	}
}

// MARK:- Methods
extension Directory {
	static func files(inSelection selection: Set<Directory>) -> [File] {
		func filesToShow(in directory: Directory) -> [File] {
			directory.files
				.map { $0 as! File }
				+ directory.subdirectories
				.flatMap { filesToShow(in: $0 as! Directory) }
		}
		
		func ancestor(
			of directory: Directory,
			isContainedIn set: Set<Directory>
		) -> Bool {
			var parent = directory.parent
			while let nextParent = parent {
				if set.contains(nextParent) {
					return true
				}
				parent = nextParent.parent
			}
			return false
		}
		
		return selection
			.filter { !ancestor(of: $0, isContainedIn: selection) }
			.sorted { $0.name < $1.name }
			.flatMap { filesToShow(in: $0) }
	}
	
	func insertFileSystemObjects(
		at urls: [URL],
		index: Int?,
		includeSubdirectories: Bool
	) {
		// insertFileSystemObject inserts the directories in the ordered set at the
		// given index. Inserting objects one at a time at a given index will result
		// in it being reversed, so reverse before iterating
		urls.reversed().forEach { url in
			insertFileSystemObject(at: url,
														 index: index,
														 includeSubdirectories: includeSubdirectories)
		}
		
		do {
			try managedObjectContext!.save()
		} catch {
			print("[WARNING] Failed to save context: \(error)")
		}
	}
	
	private func insertFileSystemObject(
		at url: URL,
		index: Int?,
		includeSubdirectories: Bool
	) {
		if url.isFolder {
			// The item being added is a folder (directory)
			let directory = Directory(context: managedObjectContext!)
			directory.url = url
			directory.dateImported = Date()
			directory.collapsed = true
			if let index = index {
				insertIntoSubdirectories(directory, at: index)
			} else {
				// For nil index, append
				addToSubdirectories(directory)
			}
			
			// Add all of the directory's contents
			do {
				let fileURLS = try FileManager.default.contentsOfDirectory(
					at: url,
					includingPropertiesForKeys: [],
					options: [.skipsHiddenFiles]
				)
				if includeSubdirectories {
					fileURLS.forEach { url in
						directory.insertFileSystemObject(
							at: url,
							index: nil,
							includeSubdirectories: true
						)
					}
				} else {
					// If not including subdirectories, filter out subfolders
					fileURLS.filter { !$0.isFolder }
						.forEach { url in
							directory.insertFileSystemObject(
								at: url,
								index: nil,
								includeSubdirectories: true
							)
						}
				}
			} catch {
				// Error reading directories content
				print("[WARNING] Failed to read directory content: \(error)")
			}
		} else {
			let file = File(context: managedObjectContext!)
			file.url = url
			file.dateImported = Date()
			addToFiles(file)
		}
	}
}

// MARK:- Identifiable
extension Directory: Identifiable {
	public var id: NSManagedObjectID {
		return self.objectID
	}
}

// MARK:- Type Identifier
extension Directory {
	/// The type identifier for `Directory` entities.
	static let typeIdentifier = "com.connorbarnes.images.directory"
}
