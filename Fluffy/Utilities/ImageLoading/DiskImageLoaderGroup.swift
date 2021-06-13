//
//  DiskImageLoaderGroup.swift
//  Fluffy
//
//  Created by Connor Barnes on 6/4/21.
//

import Cocoa

class DiskImageLoaderGroup {
	var queue: DispatchQueue
	var isClearing = false
	var cache: ImageCache
	
	static var groups: [String : DiskImageLoaderGroup] = [:]
	
	private init(
		named name: String,
		cacheMegabyteCapacity: Int
	) {
		cache = .init(megabyteCapacity: cacheMegabyteCapacity)
		let queueLabel = "DiskImageLoaderGroup:\(name)"
		queue = .init(label: queueLabel, qos: .userInitiated)
		DiskImageLoaderGroup.groups[name] = self
	}
	
	static func named(
		_ name: String,
		cacheMegabyteCapacity: Int
	) -> DiskImageLoaderGroup {
		if let group = groups[name] {
			return group
		} else {
			return .init(
				named: name,
				cacheMegabyteCapacity: cacheMegabyteCapacity
			)
		}
	}
	
	func clear() {
		isClearing = true
		queue.async { self.isClearing = false }
	}
}
