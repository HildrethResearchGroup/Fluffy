//
//  LazyDiskImage.swift
//  Images
//
//  Created by Connor Barnes on 4/5/21.
//

import SwiftUI
import Combine
import QuickLook

struct LazyDiskImage: View {
	@ObservedObject private var imageLoader = DiskImageLoader()
	
	var placeholder = Image(systemName: "photo")
	var failedPlaceholder = Image(systemName: "exclamationmark.triangle")
	
	var body: some View {
		if let image = imageLoader.loadedImage {
			Image(nsImage: image)
				.resizable()
		} else {
			switch imageLoader.state {
			case .queued:
				placeholder
			case .loading:
				ProgressView()
					.controlSize(.mini)
			case .loaded:
				// image was nil
				failedPlaceholder
			}
		}
	}
	
	init(at url: URL, in group: String) {
		imageLoader.loadImage(at: url, in: group)
	}
}

// MARK:- Image Loader
class DiskImageLoader: ObservableObject {
	static var queues: [String : DispatchQueue] = [:]
		
	static var isClearing: [String : Bool] = [:]
	
	@Published var loadedImage: NSImage?
	@Published var state = State.queued
	
	static func clearQueue(for group: String) {
		isClearing[group] = true
		
		queues[group]?.async {
			isClearing[group] = false
		}
	}
	
	func loadImage(at url: URL, in group: String) {
		let queue: DispatchQueue
		
		if let savedQueue = Self.queues[group] {
			queue = savedQueue
		} else {
			queue = DispatchQueue(label: "com.connorbarnes.images.DiskImageLoaderQueue.\(group)",
														qos: .userInitiated)
			
			Self.queues[group] = queue
			Self.isClearing[group] = false
		}
		
		queue.async {
			guard Self.isClearing[group] != true else { return }
			
			DispatchQueue.main.async { [weak self] in
				self?.state = .loading
			}
			
			// Try to create a thumbnail from QuickLook
			let options = [kQLThumbnailOptionIconModeKey: true]
			let thumbnailSize = CGSize(width: 100.0, height: 100.0)
			let thumbnail = QLThumbnailImageCreate(kCFAllocatorDefault,
																						 url as CFURL,
																						 thumbnailSize,
																						 options as CFDictionary)
			
			let rawImage: NSImage
			
			if let thumbnail = thumbnail {
				let bitmapImageRep = NSBitmapImageRep(cgImage: thumbnail.takeUnretainedValue())
				
				rawImage = NSImage(size: bitmapImageRep.size)
				rawImage.addRepresentation(bitmapImageRep)
				thumbnail.release()
			} else {
				// QuickLook failed, use Finder icon instead
				rawImage = NSWorkspace.shared.icon(forFile: url.path)
				rawImage.size = thumbnailSize
			}
			
			DispatchQueue.main.async { [weak self] in
				self?.loadedImage = rawImage
				self?.state = .loaded
			}
			
		}
	}
	
	enum State {
		case queued
		case loading
		case loaded
	}
}

// MARK:- Previews
struct LazyDiskImage_Previews: PreviewProvider {
	static let imageURL = URL(fileURLWithPath: "/Users/connorbarnes/Desktop/Examples/Images/Eiffel.jpg")
	
	static var previews: some View {
		LazyDiskImage(at: imageURL, in: "PreviewGroup")
	}
}
