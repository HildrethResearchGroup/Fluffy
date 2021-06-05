//
//  LazyDiskImage.swift
//  Images
//
//  Created by Connor Barnes on 4/5/21.
//

import SwiftUI

/// A view for lazily displaying an image from disk.
struct LazyDiskImage: View {
	/// The instance for loading the image from disk.
	@ObservedObject private var imageLoader: DiskImageLoader
	
	init(at url: URL, using imageLoader: DiskImageLoader) {
		self.imageLoader = imageLoader
		imageLoader.loadImage(at: url)
	}
	
	var body: some View {
		if let image = imageLoader.loadedImage {
			Image(nsImage: image)
				.resizable()
				.aspectRatio(contentMode: .fit)
		} else {
			switch imageLoader.state {
			case .queued:
				placeholder
			case .loading:
				ProgressView()
					.controlSize(.mini)
			case .loaded, .failed:
				// image was nil
				failedPlaceholder
			}
		}
	}
}

// MARK:- Subviews
extension LazyDiskImage {
	/// The placeholder to display while the image loads.
	var placeholder: some View {
		Image(systemName: "photo")
	}
	
	/// The placeholder to display if the image could not be loaded.
	var failedPlaceholder: some View {
		Image(systemName: "exclamationmark.triangle")
	}
}

// MARK:- Previews
struct LazyDiskImage_Previews: PreviewProvider {
	static let imageURL = URL(
		fileURLWithPath: "/Users/connorbarnes/Desktop/Examples/Images/Eiffel.jpg"
	)
	static let group = DiskImageLoaderGroup.named(
		"Preview",
		cacheMegabyteCapacity: 512
	)
	
	static var previews: some View {
		LazyDiskImage(
			at: imageURL,
			using: ThumbnailDiskImageLoader(
				in: group,
				imageSize: CGSize(width: 100.0, height: 100.0)
			)
		)
	}
}
