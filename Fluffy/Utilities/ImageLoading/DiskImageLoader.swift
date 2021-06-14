//
//  DiskImageLoader.swift
//  Fluffy
//
//  Created by Connor Barnes on 5/17/21.
//

import Cocoa
import QuickLook

/// A class which loads an image from disk in the background.
class DiskImageLoader: ObservableObject {
	/// The loaded image if it has been loaded.
	@Published var loadedImage: NSImage?
	
	/// The current state of the load operation.
	@Published var state = State.queued
	
	/// The loading group that the loader is a part of.
	let group: DiskImageLoaderGroup
	
	/// Creates a new loader in the given group.
	/// - Parameter group: The group to load in the image in.
	init(in group: DiskImageLoaderGroup) {
		self.group = group
	}
	
	/// Loads the image at the given file url.
	/// - Parameter url: The file url of the image to load.
	final func loadImage(at url: URL) {
		// Don't use background thread if the image is cached
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
	
	/// Makes an image instance from the given file url.
	/// - Parameter url: The file url of the image to load.
	/// - Returns: The image at the given url.
	func makeImage(at url: URL) -> NSImage? {
		return NSImage(contentsOf: url)
	}
}

// MARK: State
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
