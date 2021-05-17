//
//  ImageCollectionListView.swift
//  Images
//
//  Created by Connor Barnes on 5/17/21.
//

import SwiftUI

/// A view for displaying a collection of images as a list.
struct ImageCollectionListView: View {
	/// The files to display.
	var filesToShow: [File]
	
	/// The group used for lazily loading images from disk.
	var lazyDiskImageGroup: String
	
	var body: some View {
		List {
			ForEach(filesToShow, content: view(forFile:))
		}
	}
}

// MARK:- Subviews
extension ImageCollectionListView {
	/// The view for the given file.
	/// - Parameter file: The file to display.
	/// - Returns: The file's view.
	@ViewBuilder
	func view(forFile file: File) -> some View {
		HStack {
			if let url = file.url {
				LazyDiskImage(at: url,
											in: lazyDiskImageGroup,
											imageSize: CGSize(width: 24.0, height: 24.0))
					.scaledToFit()
					.frame(width: 24.0, height: 24.0)
			} else {
				Text("X")
			}
			Text(file.displayName)
		}
		.onDrag {
			let uri = file.objectID.uriRepresentation() as NSURL
			return NSItemProvider(object: uri)
		}
	}
}

// MARK:- Previews
struct ImageCollectionListView_Previews: PreviewProvider {
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
		ImageCollectionListView(filesToShow: filesToShow,
														lazyDiskImageGroup: "Preview")
	}
}
