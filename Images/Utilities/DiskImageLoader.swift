//
//  DiskImageLoader.swift
//  Images
//
//  Created by Connor Barnes on 5/17/21.
//

import Cocoa
import QuickLook

class DiskImageLoaderGroup {
	var queue: DispatchQueue
	var isClearing = false
	var imageSize: CGSize
	var cache: ImageCache
	
	static let groups: [String : DiskImageLoaderGroup] = [:]
	
	private init(
		named name: String,
		cacheMegabyteCapacity: Int,
		imageSize: CGSize
	) {
		self.imageSize = imageSize
		cache = .init(megabyteCapacity: cacheMegabyteCapacity)
		let queueLabel = "DiskImageLoaderGroup:\(name)"
		queue = .init(label: queueLabel, qos: .userInitiated)
	}
	
	static func named(
		name: String,
		cacheMegabyteCapacity: Int,
		imageSize: CGSize
	) -> DiskImageLoaderGroup {
		if let group = groups[name] {
			return group
		} else {
			return .init(
				named: name,
				cacheMegabyteCapacity: cacheMegabyteCapacity,
				imageSize: imageSize
			)
		}
	}
	
	func clear() {
		isClearing = true
		queue.async { self.isClearing = false }
	}
}

class DiskImageLoader: ObservableObject {
	@Published var loadedImage: NSImage?
	@Published var state = State.queued
	
	let imageSize: CGSize
	private let group: DiskImageLoaderGroup
	
	init(imageSize: CGSize, group: DiskImageLoaderGroup) {
		self.imageSize = imageSize
		self.group = group
	}
}

// MARK:- Image Loading
extension DiskImageLoader {
	/// Makes the image from QuickLook.
	/// - Parameters:
	///   - url: The URL of the image.
	///   - imageSize: The size of the image.
	/// - Returns: The image if it could be created by QuickLook.
	private static func makeQuicklookImage(
		at url: URL,
		imageSize: CGSize
	) -> NSImage? {
		// Multiply by 2 for retina
		let thumbnailSize = CGSize(width: round(imageSize.width * 2.0),
															 height: round(imageSize.height * 2.0))
		
		let options = [kQLThumbnailOptionIconModeKey: true]
		guard let thumbnail = QLThumbnailImageCreate(kCFAllocatorDefault,
																								 url as CFURL,
																								 thumbnailSize,
																								 options as CFDictionary)
		else {
			return nil
		}

		let bitmapImageRep = NSBitmapImageRep(cgImage: thumbnail.takeUnretainedValue())

		let image = NSImage(size: bitmapImageRep.size)
		image.addRepresentation(bitmapImageRep)
		thumbnail.release()
		return image
	}
	
	/// Makes the image from `NSWorkspace`, as it would be displayed in Finder.
	/// - Parameters:
	///   - url: The url of the image.
	///   - imageSize: The size of the image.
	/// - Returns: The image.
	private static func makeFinderImage(
		at url: URL,
		imageSize: CGSize
	) -> NSImage {
		let image = NSWorkspace.shared.icon(forFile: url.path)
		image.size = imageSize
		return image
	}
	
	/// Loads the image at the given url for the given image group.
	/// - Parameters:
	///   - url: The url of the image on disk.
	///   - group: The image group.
	func loadImage(at url: URL) {
		if let image = group.cache[url] {
			state = .loaded
			loadedImage = image
			return
		}
		
		group.queue.async { [imageSize] in
			DispatchQueue.main.async { [weak self] in
				self?.state = .loading
			}
			
			let rawImage = Self.makeQuicklookImage(at: url, imageSize: imageSize)
				?? Self.makeFinderImage(at: url, imageSize: imageSize)
			
			DispatchQueue.main.async { [weak self] in
				self?.loadedImage = rawImage
				self?.group.cache.insert(image: rawImage, at: url)
				self?.state = .loaded
			}
		}
	}
}

/*

// MARK:- Image Loader
/// A class that loads an image from disk.
class DiskImageLoader: ObservableObject {
	/// The queue for each operation.
	static var queues: [String : DispatchQueue] = [:]
	
	/// Whether each queue is being cleared.
	static var isClearing: [String : Bool] = [:]
	
	/// The size of the image to load.
	var imageSize: CGSize
	
	/// The loaded image.
	@Published var loadedImage: NSImage?
	
	/// The state of the load operation.
	@Published var state = State.queued
	
	init(imageSize: CGSize) {
		self.imageSize = imageSize
	}
	
	/// Clears an image group of all pending operations.
	/// - Parameter group: The group to clear.
	static func clearQueue(for group: String) {
		isClearing[group] = true
		
		queues[group]?.async {
			isClearing[group] = false
		}
	}
}

// MARK: Image Loading
extension DiskImageLoader {
	/// Get the queue for the given group
	/// - Parameter group: The group.
	/// - Returns: The queue for the given group.
	private func getQueue(for group: String) -> DispatchQueue {
		if let savedQueue = Self.queues[group] {
			return  savedQueue
		} else {
			let queue = DispatchQueue(label: "com.connorbarnes.images.DiskImageLoaderQueue.\(group)",
														qos: .userInitiated)
			
			Self.queues[group] = queue
			Self.isClearing[group] = false
			return queue
		}
	}
	
	/// Makes the image from QuickLook.
	/// - Parameters:
	///   - url: The URL of the image.
	///   - imageSize: The size of the image.
	/// - Returns: The image if it could be created by QuickLook.
	private static func makeQuicklookImage(
		at url: URL,
		imageSize: CGSize
	) -> NSImage? {
		// Multiply by 2 for retina
		let thumbnailSize = CGSize(width: round(imageSize.width * 2.0),
															 height: round(imageSize.height * 2.0))
		
		let options = [kQLThumbnailOptionIconModeKey: true]
		guard let thumbnail = QLThumbnailImageCreate(kCFAllocatorDefault,
																								 url as CFURL,
																								 thumbnailSize,
																								 options as CFDictionary)
		else {
			return nil
		}

		let bitmapImageRep = NSBitmapImageRep(cgImage: thumbnail.takeUnretainedValue())

		let image = NSImage(size: bitmapImageRep.size)
		image.addRepresentation(bitmapImageRep)
		thumbnail.release()
		return image
	}
	
	/// Makes the image from `NSWorkspace`, as it would be displayed in Finder.
	/// - Parameters:
	///   - url: The url of the image.
	///   - imageSize: The size of the image.
	/// - Returns: The image.
	private static func makeFinderImage(
		at url: URL,
		imageSize: CGSize
	) -> NSImage {
		let image = NSWorkspace.shared.icon(forFile: url.path)
		image.size = imageSize
		return image
	}
	
	/// Loads the image at the given url for the given image group.
	/// - Parameters:
	///   - url: The url of the image on disk.
	///   - group: The image group.
	func loadImage(at url: URL, in group: String) {
		let queue = getQueue(for: group)
		guard Self.isClearing[group] != true else { return }
		
		queue.async { [imageSize] in
			DispatchQueue.main.async { [weak self] in
				self?.state = .loading
			}
			
			let rawImage = Self.makeQuicklookImage(at: url, imageSize: imageSize)
				?? Self.makeFinderImage(at: url, imageSize: imageSize)
			
			DispatchQueue.main.async { [weak self] in
				self?.loadedImage = rawImage
				self?.state = .loaded
			}
		}
	}
}

*/

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
	}
}
