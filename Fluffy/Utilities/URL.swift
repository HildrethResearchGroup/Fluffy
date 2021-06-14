//
//  URL.swift
//  Fluffy
//
//  Created by Connor Barnes on 6/6/21.
//

import Cocoa

extension URL {
	/// Returns `true` if the url is a file system container. (Packages are not considered containers).
	var isFolder: Bool {
		guard let resources = try? resourceValues(forKeys: [.isDirectoryKey, .isPackageKey]) else { return false }
		
		return (resources.isDirectory ?? false) && !(resources.isPackage ?? false)
	}
	
	/// Opens Finder and highlights the file at the url's path.
	func showInFinder() {
		NSWorkspace.shared
			.activateFileViewerSelecting([self])
	}
}

extension Collection where Element == URL {
	/// Opens Finder and highlights the files at the urls' paths.
	func showInFinder() {
		NSWorkspace.shared
			.activateFileViewerSelecting(map { $0 })
	}
}
