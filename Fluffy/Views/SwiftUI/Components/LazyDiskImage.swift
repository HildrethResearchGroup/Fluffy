//
//  LazyDiskImage.swift
//  Fluffy
//
//  Created by Connor Barnes on 4/5/21.
//

import SwiftUI

/// A view for lazily displaying an image from disk.
struct LazyDiskImage: View {
	/// The instance for loading the image from disk.
	@ObservedObject private var imageLoader: DiskImageLoader
	
	/// The url of the image.
	private var url: URL
	
	/// The custom id of the image view.
	private var id: AnyHashable?
	
	/// Creates a lazy disk image for the image at the given url using the given image loader.
	/// - Parameters:
	///   - url: The file url of the image.
	///   - imageLoader: The image loader to use to load the image.
	init(at url: URL, using imageLoader: DiskImageLoader) {
		self.imageLoader = imageLoader
		self.url = url
		imageLoader.loadImage(at: url)
		
	}
	
	/// Creates a lazy disk image for the image at the given url using the given image loader and a custom id.
	/// - Parameters:
	///   - url: The file url of the image.
	///   - imageLoader: The image loader to use to load the image.
	///   - id: The custom id to use.
	private init<ID>(
		at url: URL,
		using imageLoader: DiskImageLoader,
		id: ID
	) where ID : Hashable {
		self.init(at: url, using: imageLoader)
		self.id = AnyHashable(id)
	}
	
	/// Binds a view's identity to the given proxy value.
	func id<ID>(_ id: ID) -> some View where ID : Hashable {
		LazyDiskImage(at: self.url,
									using: self.imageLoader,
									id: id)
	}
	
	var body: some View {
		if let image = imageLoader.loadedImage {
			Image(nsImage: image)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.id(id ?? AnyHashable(url))
		} else {
			switch imageLoader.state {
			case .queued:
				placeholder
					.id(id ?? AnyHashable(url))
			case .loading:
				ProgressView()
					.controlSize(.mini)
					.id(id ?? AnyHashable(url))
			case .loaded, .failed:
				// image was nil
				failedPlaceholder
					.id(id ?? AnyHashable(url))
			}
		}
	}
}


// MARK:- Subviews
private extension LazyDiskImage {
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
