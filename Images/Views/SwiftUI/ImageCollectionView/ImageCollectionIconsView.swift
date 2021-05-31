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
	
	@Binding var fileSelection: Set<File>
	
	/// The size of images.
	@Binding var thumbnailScale: CGFloat
	
	@State var diskImageGroup: DiskImageLoaderGroup
	
	init(
		filesToShow: [File],
		fileSelection: Binding<Set<File>>,
		thumbnailScale: Binding<CGFloat>
	) {
		self.filesToShow = filesToShow
		_thumbnailScale = thumbnailScale
		_fileSelection = fileSelection
		diskImageGroup = .named(name: "IconsView",
														cacheMegabyteCapacity: 512,
														imageSize: CGSize(width: 256, height: 256))
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
			? Color(NSColor.unemphasizedSelectedContentBackgroundColor)
			: Color.clear
		
		let textHighlightColor = isSelected
			? Color(NSColor.selectedContentBackgroundColor)
			: Color.clear
		
		let textColor = isSelected
			? Color(NSColor.alternateSelectedControlTextColor)
			: Color(NSColor.textColor)
		
		VStack {
			if let url = file.url {
				LazyDiskImage(at: url,
											in: diskImageGroup,
											imageSize: CGSize(width: thumbnailScale * 2, height: thumbnailScale * 2))
					.scaledToFit()
					.padding(4.0)
					.background(
						RoundedRectangle(cornerRadius: 4.0)
							.foregroundColor(imageHighlightColor)
					)
			} else {
				Text("X")
			}
			Text(file.displayName)
				.lineLimit(1)
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
			thumbnailScale: $thumbnailScale
		)
	}
}
