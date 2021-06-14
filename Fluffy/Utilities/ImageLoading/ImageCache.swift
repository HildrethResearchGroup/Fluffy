//
//  ImageCache.swift
//  Fluffy
//
//  Created by Connor Barnes on 5/30/21.
//

import AppKit
import Collections

/// A cache for storing images.
struct ImageCache {
	/// The capacity of the cache in bytes.
	let byteCapacity: Int
	
	/// The current size of the cache in bytes.
	///
	/// - Note: This value is only an estimate.
	private(set) var byteSize: Int = 0
	
	/// The cache.
	private var cache: [URL : NSImage] = [:]
	
	/// The images and urls that are in the cache.
	private var images: Deque<(URL, NSImage)> = []
	
	/// Creates a new cache with the given capacity in bytes.
	/// - Parameter byteCapacity: The capacity in bytes.
	init(byteCapacity: Int) {
		self.byteCapacity = byteCapacity
	}
	
	subscript(_ url: URL) -> NSImage? {
		return cache[url]
	}
}

// MARK: Convenience Initializers
extension ImageCache {
	/// Creates a new cache with the given capacity in megabytes.
	/// - Parameter megabyteCapacity: The capacity in megabytes.
	init(megabyteCapacity: Int) {
		self.init(byteCapacity: 1024 * 1024 * megabyteCapacity)
	}
}

// MARK: Methods
extension ImageCache {
	/// Inserts an image that is stored at the given url into the cache.
	/// - Parameters:
	///   - image: The image to add to the cache.
	///   - url: The url that the image is from.
	mutating func insert(image: NSImage, at url: URL) {
		cache[url] = image
		images.append((url, image))
		byteSize += image.estimatedByteSize
		
		while byteSize > byteCapacity && images.count > 1 {
			// Remove the oldest image
			let (url, image) = images.removeFirst()
			cache[url] = nil
			byteSize -= image.estimatedByteSize
		}
	}
}

// MARK: Image Size
extension NSImage {
	/// Returns the estimated size of the image in memory.
	var estimatedByteSize: Int {
		return representations
			.map { representation in
				let channels = representation.hasAlpha ? 4 : 3
				let bits = representation.bitsPerSample * channels
				let size = representation.pixelsWide * representation.pixelsHigh
				return bits * size / 8
			}
			.reduce(0, +)
	}
}
