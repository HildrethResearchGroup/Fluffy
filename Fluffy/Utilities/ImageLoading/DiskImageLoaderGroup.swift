//
//  DiskImageLoaderGroup.swift
//  Fluffy
//
//  Created by Connor Barnes on 6/4/21.
//

import Cocoa

/// A group for loading images in.
class DiskImageLoaderGroup {
	/// The queue to load images on.
	let queue: DispatchQueue
	
	/// The name of the group.
	let name: String
	
	/// A cache of loaded images.
	var cache: ImageCache
	
	/// If `true`, the queue is clearing and should not perform any load operations until the queue is cleared.
	private var isClearing = false
	
	/// Creates a group of the given name and capacity in megabytes.
	/// - Parameters:
	///   - name: The name of the group to create.
	///   - cacheMegabyteCapacity: The size of the cache to use in megabytes.
	private init(
		named name: String,
		cacheMegabyteCapacity: Int
	) {
		self.name = name
		cache = .init(megabyteCapacity: cacheMegabyteCapacity)
		let queueLabel = "DiskImageLoaderGroup:\(name)"
		queue = .init(label: queueLabel, qos: .userInitiated)
		DiskImageLoaderGroup.groups[name] = self
	}
	
	/// Clears all queued image load operations in the group.
	func clearQueue() {
		isClearing = true
		queue.async {
			// This will be placed at the end of the queue so will be run after
			// every queued operation was skipped
			DispatchQueue.main.async { self.isClearing = false }
		}
	}
	
	/// Clears all queued image load operations in all groups except for the queues specified.
	/// - Parameter excludedQueues: The queues to not clear.
	static func clearAllQueues<S>(
		except excludedQueues: S
	) where S: Sequence,
					S.Element == DiskImageLoaderGroup {
		
		let excludedSet = Set(excludedQueues)
		
		groups.map { $0.value }
			.filter { !excludedSet.contains($0) }
			.forEach { $0.clearQueue() }
	}
}

// MARK: Hashable
extension DiskImageLoaderGroup: Hashable {
	static func == (
		lhs: DiskImageLoaderGroup,
		rhs: DiskImageLoaderGroup
	) -> Bool {
		return lhs.name == rhs.name
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(queue)
	}
}

// MARK: Factory
extension DiskImageLoaderGroup {
	/// The created disk image loaders.
	private static var groups: [String : DiskImageLoaderGroup] = [:]
	
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
}
