//
//  ThumbnailDiskImageLoader.swift
//  Fluffy
//
//  Created by Connor Barnes on 6/4/21.
//

import Cocoa
import QuickLook

/// A disk image loader which loads a thumbnail of an image.
class ThumbnailDiskImageLoader: DiskImageLoader {
	/// The size of the thumbnail to load.
	let imageSize: CGSize
	
	/// Creates a new loader in the given group for the given thumbnail size.
	/// - Parameters:
	///   - group: The group to load the image in.
	///   - imageSize: The size of the thumbnail to create.
	init(in group: DiskImageLoaderGroup, imageSize: CGSize) {
		self.imageSize = imageSize
		super.init(in: group)
	}
	
	override func makeImage(at url: URL) -> NSImage? {
		return Self.makeQuicklookImage(at: url, imageSize: imageSize)
			?? Self.makeFinderImage(at: url, imageSize: imageSize)
	}
}

// MARK:- Image Loading
private extension ThumbnailDiskImageLoader {
	/// Makes the image from QuickLook.
	/// - Parameters:
	///   - url: The URL of the image.
	///   - imageSize: The size of the image.
	/// - Returns: The image if it could be created by QuickLook.
	static func makeQuicklookImage(
		at url: URL,
		imageSize: CGSize
	) -> NSImage? {
		// Multiply by 2 for retina
		let thumbnailSize = CGSize(width: round(imageSize.width * 2.0),
															 height: round(imageSize.height * 2.0))
		
		let options = [kQLThumbnailOptionIconModeKey: true]
		guard let thumbnail = QLThumbnailImageCreate(
			kCFAllocatorDefault,
			url as CFURL,
			thumbnailSize,
			options as CFDictionary
		) else {
			return nil
		}

		let bitmapImageRep = NSBitmapImageRep(
			cgImage: thumbnail.takeUnretainedValue()
		)

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
	static func makeFinderImage(
		at url: URL,
		imageSize: CGSize
	) -> NSImage {
		let image = NSWorkspace.shared.icon(forFile: url.path)
		image.size = imageSize
		return image
	}
}
