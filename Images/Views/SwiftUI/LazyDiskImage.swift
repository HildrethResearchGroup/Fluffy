//
//  LazyDiskImage.swift
//  Images
//
//  Created by Connor Barnes on 4/5/21.
//

import SwiftUI
import Combine

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
			
			let rawImage = NSImage(contentsOf: url)
			
			if let rawImage = rawImage {
				let image = NSImage(size: NSSize(width: 256, height: 256))
				
				image.lockFocus()
				rawImage.draw(in: NSRect(x: 0,
																	y: 0,
																	width: 256,
																	height: 256),
											 from: NSRect(origin: CGPoint(x: 0,
																										y: 0),
																		size: rawImage.size),
											 operation: .copy,
											 fraction: 1.0)
				
				image.unlockFocus()
				
				DispatchQueue.main.async { [weak self] in
					self?.loadedImage = image
					self?.state = .loaded
				}
			} else {
				DispatchQueue.main.async { [weak self] in
					self?.state = .loaded
				}
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
