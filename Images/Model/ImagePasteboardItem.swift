//
//  ImagePasteboardItem.swift
//  Images
//
//  Created by Connor Barnes on 4/26/21.
//

import Cocoa

/// A paste board writer for images.
class ImagePasteboardWriter: NSFilePromiseProvider {
	/// An enum holding a list of all the used keys in userDictionary.
	enum UserInfoKeys {
		/// The Core Data objectID of the image.
		static let objectID = "objectID"
	}
	
	override func writableTypes(
		for pasteboard: NSPasteboard
	) -> [NSPasteboard.PasteboardType] {
		var types = super.writableTypes(for: pasteboard)
		// As well as promise files, add internal image pasteboard type and
		// fileURLs
		types.append(.imagePasteboardType)
		types.append(.fileURL)
		return types
	}
	
	override func pasteboardPropertyList(
		forType type: NSPasteboard.PasteboardType
	) -> Any? {
		switch type {
		case .imagePasteboardType:
			// The pasteboard type is the internal image drag, use userInfo as the
			// property list
			return userInfo
		default:
			// The pasteboard type could be a file promise, the super class can
			// determine the property list
			return super.pasteboardPropertyList(forType: type)
		}
	}
}

// MARK:- Pasteboard Type
extension NSPasteboard.PasteboardType {
	static let imagePasteboardType = Self(
		"com.connorbarnes.fluffy.imagePasteboardType"
	)
}
