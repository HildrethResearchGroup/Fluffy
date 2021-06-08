//
//  URL.swift
//  Images
//
//  Created by Connor Barnes on 6/6/21.
//

import Foundation

extension URL {
	/// Returns `true` if the url is a file system container. (Packages are not considered containers).
	var isFolder: Bool {
		guard let resources = try? resourceValues(forKeys: [.isDirectoryKey, .isPackageKey]) else { return false }
		
		return (resources.isDirectory ?? false) && !(resources.isPackage ?? false)
	}
}
