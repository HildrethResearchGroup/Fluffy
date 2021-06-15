//
//  ImageCollectionIconsView.swift
//  Fluffy
//
//  Created by Connor Barnes on 5/17/21.
//

import SwiftUI

/// A view displaying images as a grid of icons.
struct ImageCollectionIconsView: View {
	/// The files to display.
	var filesToShow: [File]
	
	/// The currently selected files.
	@Binding var fileSelection: Set<File>
	
	/// A manual updater for forcing the files to show to update.
	@Binding var updater: Updater
	
	/// The size of images.
	let thumbnailScale: Double
	
	/// The group to load images in.
	let diskImageGroup: DiskImageLoaderGroup
	
	/// The size group of icons.
	let sizeGroup: Int
	
	/// Creates an image collection icons view.
	/// - Parameters:
	///   - filesToShow: The files to display.
	///   - fileSelection: The files selected.
	///   - updater: An updater for updating the files to show.
	///   - thumbnailScale: The size of thumbnails.
	init(
		filesToShow: [File],
		fileSelection: Binding<Set<File>>,
		updater: Binding<Updater>,
		thumbnailScale: Double
	) {
		self.filesToShow = filesToShow
		self.thumbnailScale = thumbnailScale
		_fileSelection = fileSelection
		_updater = updater
		sizeGroup = Int(log2(thumbnailScale)) + 1
		
		diskImageGroup = .named("IconsView\(sizeGroup)",
														cacheMegabyteCapacity: 512)
	}
	
	var body: some View {
		ScrollView(.vertical) {
			LazyVGrid(columns: columns) {
				ForEach(filesToShow) { file in
					item(forFile: file)
						.onShiftTapGesture {
							if fileSelection.contains(file) {
								fileSelection.remove(file)
							} else {
								fileSelection.insert(file)
							}
						}
						.onCommandTapGesture {
							if fileSelection.contains(file) {
								fileSelection.remove(file)
							} else {
								fileSelection.insert(file)
							}
						}
						.onTapGesture {
							fileSelection = [file]
						}
				}
			}
			.padding(10.0)
		}
		.background(Color(NSColor.controlBackgroundColor))
	}
}

// MARK:- Item View
private extension ImageCollectionIconsView {
	/// A view for displaying an icon.
	struct ItemView: View {
		/// The file whose icon to display.
		@ObservedObject var file: File
		
		/// Whether the icon is selected or not.
		let isSelected: Bool
		
		/// The size group of the icon.
		let sizeGroup: Int
		
		/// The size of the icon's thumbnail.
		let thumbnailScale: Double
		
		/// The group to load the icon's image.
		let diskImageGroup: DiskImageLoaderGroup
		
		var body: some View {
			let imageHighlightColor = isSelected
				? Color(.unemphasizedSelectedContentBackgroundColor)
				: Color.clear
			
			let textHighlightColor = isSelected
				? Color(.selectedContentBackgroundColor)
				: Color.clear
			
			let textColor = isSelected
				? Color(.alternateSelectedControlTextColor)
				: Color(.textColor)
			
			VStack(spacing: 4.0) {
				thumbnail
					.padding(4.0)
					.frame(width: CGFloat(thumbnailScale),
								 height: CGFloat(thumbnailScale),
								 alignment: .center)
					.background(
						RoundedRectangle(cornerRadius: 4.0)
							.foregroundColor(imageHighlightColor)
					)
				
				Text(file.displayName)
					.lineLimit(2)
					.fixedSize(horizontal: false, vertical: true)
					.multilineTextAlignment(.center)
					.foregroundColor(textColor)
					.padding([.leading, .trailing], 4.0)
					.background(
						RoundedRectangle(cornerRadius: 4.0)
							.foregroundColor(textHighlightColor)
					)
			}
			.onDrag {
				let uri = file.objectID.uriRepresentation() as NSURL
				return NSItemProvider(object: uri)
			}
		}
		
		/// The thumbnail image of the icon.
		@ViewBuilder
		var thumbnail: some View {
			if let url = file.url {
				let size = pow(2.0, CGFloat(sizeGroup))
				
				let imageLoader = ThumbnailDiskImageLoader(
					in: diskImageGroup,
					imageSize: CGSize(
						width: size,
						height: size
					)
				)
				
				LazyDiskImage(at: url,
											using: imageLoader)
					.scaledToFit()
			} else {
				Text("X")
			}
		}
	}
}

// MARK:- Subviews
private extension ImageCollectionIconsView {
	/// Returns the view for the collection item of the given file.
	/// - Parameter file: The file to be displayed in the item.
	@ViewBuilder
	func item(forFile file: File) -> some View {
		ItemView(file: file,
						 isSelected: fileSelection.contains(file),
						 sizeGroup: sizeGroup,
						 thumbnailScale: thumbnailScale,
						 diskImageGroup: diskImageGroup)
			.contextMenu {
				ImageCollectionItemContextMenu(
					file: file,
					fileSelection: $fileSelection,
					updater: $updater
				)
			}
	}
}

// MARK:- Helper Functions
private extension ImageCollectionIconsView {
	/// The grid's columns.
	var columns: [GridItem] {
		[
			GridItem(
				.adaptive(
					minimum: max(96.0, CGFloat(thumbnailScale)),
					maximum: CGFloat(thumbnailScale) * 2
				),
				spacing: 24.0,
				alignment: .top
			)
		]
	}
}

// MARK:- Previews
struct ImageCollectionIconsView_Previews: PreviewProvider {
	@State static var fileSelection: Set<File> = []
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
		ImageCollectionIconsView(
			filesToShow: filesToShow,
			fileSelection: $fileSelection,
			updater: .constant(Updater()),
			thumbnailScale: C.defaultIconThumbnailSize
		)
	}
}
