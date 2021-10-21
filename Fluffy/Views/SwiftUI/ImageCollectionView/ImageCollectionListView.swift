//
//  ImageCollectionListView.swift
//  Fluffy
//
//  Created by Connor Barnes on 5/17/21.
//

import SwiftUI

/// A view for displaying a collection of images as a list.
struct ImageCollectionListView: View {
	/// The files to display.
	var filesToShow: [File]
	
	/// The files selected.
	//@Binding var fileSelection: Set<File>
    
    /// Manage the selection
    @EnvironmentObject var selectionManager: SelectionManager
    
	
	/// An updater for manually updating the files to show.
	@Binding var updater: Updater
	
	/// The group to load images in.
	@State var diskImageGroup: DiskImageLoaderGroup
	
	var body: some View {
        List(selection: $selectionManager.fileSelection) {
			ForEach(filesToShow, id: \.self) { file in
				item(forFile: file)
					.tag(file)
			}
		}
	}
	
    
	/// Creates an image collection list view.
	/// - Parameters:
	///   - filesToShow: The files to show.
	///   - fileSelection: The files selected.
	///   - updater: An updater for manually updating the files to show.
	init(
		filesToShow: [File],
		//fileSelection: Binding<Set<File>>,
		updater: Binding<Updater>
	) {
		self.filesToShow = filesToShow
		//_fileSelection = fileSelection
		_updater = updater
		diskImageGroup = .named(
			"ListView",
			cacheMegabyteCapacity: 128
		)
	}
}


// MARK: - ItemView
private extension ImageCollectionListView {
	/// A view displaying an image collection list row.
	struct ItemView: View {
		/// The file to display.
		@ObservedObject var file: File
		
        
        /// Manage the File and Directory selections
        @EnvironmentObject var selectionManager: SelectionManager
		
		/// The group to load the thumbnail image in.
		let diskImageGroup: DiskImageLoaderGroup
		
		var body: some View {
			HStack {
				if let url = file.url {
					let imageLoader = ThumbnailDiskImageLoader(
						in: diskImageGroup,
						imageSize: CGSize(width: C.listThumbnailSize,
															height: C.listThumbnailSize)
					)
					
					LazyDiskImage(at: url,
                                  using: imageLoader)
						.scaledToFit()
						.frame(width: C.listThumbnailSize,
                               height: C.listThumbnailSize)
				} else {
					Text("X")
				}
				Text(file.displayName)
			}
			// TODO: Add proper shift clicking
			.onCommandTapGesture {
                if selectionManager.fileSelection.contains(file) {
                    selectionManager.fileSelection.remove(file)
				} else {
                    selectionManager.fileSelection.insert(file)
				}
			}
			.onTapGesture {
                selectionManager.fileSelection = [file]
			}
			.onDrag {
				let uri = file.objectID.uriRepresentation() as NSURL
				return NSItemProvider(object: uri)
			}
		}
	}
}

// MARK:- Subviews
private extension ImageCollectionListView {
	/// The view for the given file.
	/// - Parameter file: The file to display.
	/// - Returns: The file's view.
	@ViewBuilder
	func item(forFile file: File) -> some View {
		ItemView(file: file,
                 diskImageGroup: diskImageGroup)
			.contextMenu {
				ImageCollectionItemContextMenu(
					file: file,
					updater: $updater
				)
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
		"Preview",
		cacheMegabyteCapacity: 512
	)
	
	@State static var fileSelection: Set<File> = []
	
	static var previews: some View {
		ImageCollectionListView(
			filesToShow: filesToShow,
			updater: .constant(Updater())
		)
	}
}
