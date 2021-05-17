//
//  ImageCollectionIconsView.swift
//  Images
//
//  Created by Connor Barnes on 5/17/21.
//

import SwiftUI

/// A view displaying images as a grid of icons.
struct ImageCollectionIconsView: View {
	/// The files to display.
	var filesToShow: [File]
	
	/// The group used for loading the images from disk lazily.
	var lazyDiskImageGroup: String
	
	/// The size of images.
	@Binding var thumbnailScale: CGFloat
	
	init(filesToShow: [File], lazyDiskImageGroup: String, thumbnailScale: Binding<CGFloat>) {
		self.filesToShow = filesToShow
		self.lazyDiskImageGroup = lazyDiskImageGroup
		_thumbnailScale = thumbnailScale
		DiskImageLoader.clearQueue(for: lazyDiskImageGroup)
	}
	
	var body: some View {
		ScrollView(.vertical) {
			LazyVGrid(columns: columns) {
				ForEach(filesToShow, content: view(forFile:))
			}
			.padding(10.0)
		}
	}
}

// MARK:- Subviews
extension ImageCollectionIconsView {
	/// The view for the given file.
	/// - Parameter file: The file to display.
	/// - Returns: The file's view.
	@ViewBuilder
	func view(forFile file: File) -> some View {
		VStack {
			if let url = file.url {
				LazyDiskImage(at: url,
											in: lazyDiskImageGroup,
											imageSize: CGSize(width: thumbnailScale * 2, height: thumbnailScale * 2))
					.scaledToFit()
			} else {
				Text("X")
			}
			Text(file.displayName)
				.lineLimit(1)
		}
		.onDrag {
			let uri = file.objectID.uriRepresentation() as NSURL
			return NSItemProvider(object: uri)
		}
	}
}

// MARK:- Helper Functions
extension ImageCollectionIconsView {
	/// The grid's columns.
	var columns: [GridItem] {
		[
			GridItem(.adaptive(minimum: thumbnailScale, maximum: thumbnailScale * 2),
							 spacing: 10.0)
		]
	}
}

// MARK:- Previews
struct ImageCollectionIconsView_Previews: PreviewProvider {
	@State static var thumbnailScale: CGFloat = 64.0
	static var filesToShow: [File] {
		let fetchRequest: NSFetchRequest<Directory> = Directory.fetchRequest()
		
		let viewContext = PersistenceController
			.preview
			.container
			.viewContext
		
		let fetchResult = try! viewContext.fetch(fetchRequest)
		
		return fetchResult
			.flatMap { $0.files.compactMap { $0 as? File } }
	}
	
	static var previews: some View {
		ImageCollectionIconsView(filesToShow: filesToShow,
														 lazyDiskImageGroup: "Preview",
														 thumbnailScale: $thumbnailScale)
	}
}
