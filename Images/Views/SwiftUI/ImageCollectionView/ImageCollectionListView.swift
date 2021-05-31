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
	
	@Binding var fileSelection: Set<File>
	
	@State var diskImageGroup: DiskImageLoaderGroup
	
	var body: some View {
		List(selection: $fileSelection) {
			ForEach(filesToShow, id: \.self) {
				view(forFile: $0)
					.tag($0)
			}
		}
	}
	
	init(filesToShow: [File], fileSelection: Binding<Set<File>>) {
		self.filesToShow = filesToShow
		_fileSelection = fileSelection
		diskImageGroup = .named(
			name: "ListView",
			cacheMegabyteCapacity: 128,
			imageSize: CGSize(width: 24, height: 24)
		)
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
											in: diskImageGroup,
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
	
	static let group = DiskImageLoaderGroup.named(
		name: "Preview",
		cacheMegabyteCapacity: 512,
		imageSize: CGSize(width: 256, height: 256)
	)
	
	@State static var fileSelection: Set<File> = []
	
	static var previews: some View {
		ImageCollectionListView(
			filesToShow: filesToShow,
			fileSelection: $fileSelection
		)
	}
}
