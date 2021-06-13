//
//  ImageCache.swift
//  Fluffy
//
//  Created by Connor Barnes on 5/30/21.
//

import AppKit
import Collections

struct ImageCache {
	let byteCapacity: Int
	private(set) var byteSize: Int = 0
	private var cache: [URL : NSImage] = [:]
	private var images: Deque<(URL, NSImage)> = []
	
	init(byteCapacity: Int) {
		self.byteCapacity = byteCapacity
	}
	
	subscript(_ url: URL) -> NSImage? {
		return cache[url]
	}
}

// MARK: Convenience Initializers
extension ImageCache {
	init(megabyteCapacity: Int) {
		self.init(byteCapacity: 1024 * 1024 * megabyteCapacity)
	}
}

// MARK: Methods
extension ImageCache {
	mutating func insert(image: NSImage, at url: URL) {
		cache[url] = image
		images.append((url, image))
		byteSize += image.byteSize
		
		while byteSize > byteCapacity && images.count > 1 {
			// Remove the oldest image
			let (url, image) = images.removeFirst()
			cache[url] = nil
			byteSize -= image.byteSize
		}
	}
}

// MARK: Image Size
extension NSImage {
	var byteSize: Int {
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
