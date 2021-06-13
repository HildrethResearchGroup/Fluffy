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
	
	@Binding var fileSelection: Set<File>
	
	/// The size of images.
	let thumbnailScale: Double
	
	let diskImageGroup: DiskImageLoaderGroup
	
	let sizeGroup: Int
	
	init(
		filesToShow: [File],
		fileSelection: Binding<Set<File>>,
		thumbnailScale: Double
	) {
		self.filesToShow = filesToShow
		self.thumbnailScale = thumbnailScale
		_fileSelection = fileSelection
		sizeGroup = Int(log2(thumbnailScale)) + 1
		
		diskImageGroup = .named("IconsView\(sizeGroup)",
														cacheMegabyteCapacity: 512)
	}
	
	var body: some View {
		ScrollView(.vertical) {
			LazyVGrid(columns: columns) {
				ForEach(filesToShow) { file in
					view(forFile: file)
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

// MARK:- Subviews
extension ImageCollectionIconsView {
	/// The view for the given file.
	/// - Parameter file: The file to display.
	/// - Returns: The file's view.
	@ViewBuilder
	func view(forFile file: File) -> some View {
		let isSelected = fileSelection.contains(file)
		
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
			thumbnail(forFile: file)
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
	
	@ViewBuilder
	func thumbnail(forFile file: File) -> some View {
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

// MARK:- Helper Functions
extension ImageCollectionIconsView {
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
			thumbnailScale: C.defaultIconThumbnailSize
		)
	}
}
