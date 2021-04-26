//
//  DirectoryPasteboardItem.swift
//  Images
//
//  Created by Connor Barnes on 4/26/21.
//

import Cocoa

/// A paste board writer for directories.
class DirectoryPasteboardWriter: NSFilePromiseProvider {
	/// An enum holding a list of all the used keys in userDictionary.
	enum UserInfoKeys {
		/// The row of the dragged directory in the sidebar
		static let row = "rowKey"
		/// The name of the directory
		static let name = "nameKey"
		// The url of the directory
		static let url = "urlKey"
	}
	
	// MARK: NSPasteboardWriting
	override func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
		var types = super.writableTypes(for: pasteboard)
		// As well as promise files, add internal directory pasteboard type and fileURLs.
		types.append(.directoryRowPasteboardType)
		types.append(.fileURL)
		return types
	}
	
	override func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
		switch type {
		case .directoryRowPasteboardType:
			// The pasteboard type is the internal directory drag, use userInfo as the property list
			return userInfo
		default:
			// The pasteboard type could be a file promise, the super class can determine the property list.
			return super.pasteboardPropertyList(forType: type)
		}
	}
	
}

// MARK: Utilities
extension DirectoryPasteboardWriter {
	/// Returns the url of a file promise provider.
	/// - Parameter filePromiseProvider: The file promise provider.
	/// - Returns: The url or `nil` if the url could not be determined.
	class func urlFromFilePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider) -> URL? {
		// The url is stored in a key of userInfo -- if userInfo is not a dictionary of [String: Any] or if the key does not exist return nil
		guard let userInfo = filePromiseProvider.userInfo as? [String: Any] else { return nil }
		
		if let urlString = userInfo[DirectoryPasteboardWriter.UserInfoKeys.url] as? String {
			// If the urlString is empty then it does not represent a valid url so return nil
			if !urlString.isEmpty {
				return URL(string: urlString)
			}
		}
		
		return nil
	}
}
