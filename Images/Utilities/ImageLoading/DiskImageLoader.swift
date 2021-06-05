//
//  DiskImageLoader.swift
//  Images
//
//  Created by Connor Barnes on 5/17/21.
//

import Cocoa
import QuickLook

class DiskImageLoader: ObservableObject {
	@Published var loadedImage: NSImage?
	@Published var state = State.queued
	
	let group: DiskImageLoaderGroup
	
	init(in group: DiskImageLoaderGroup) {
		self.group = group
	}
	
	final func loadImage(at url: URL) {
		if let image = group.cache[url] {
			state = .loaded
			loadedImage = image
			return
		}
		
		group.queue.async { [weak self] in
			guard let self = self else { return }
			if let image = self.makeImage(at: url) {
				DispatchQueue.main.async {
					self.loadedImage = image
					self.group.cache.insert(image: image, at: url)
					self.state = .loaded
				}
			} else {
				DispatchQueue.main.async {
					self.state = .failed
				}
			}
		}
	}
	
	func makeImage(at url: URL) -> NSImage? {
		return NSImage(contentsOf: url)
	}
}

// MARK: DiskImageLoader.State
extension DiskImageLoader {
	/// The disk image loader state.
	enum State {
		/// The operation is queued.
		case queued
		/// The image is loading.
		case loading
		/// The image is loaded.
		case loaded
		/// The image could not be loaded.
		case failed
	}
}
