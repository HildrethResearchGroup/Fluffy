//
//  ImageCollectionView.swift
//  Images
//
//  Created by Connor Barnes on 3/15/21.
//

import SwiftUI

/// The view for displaying the collection of images in the selected directories.
struct ImageCollectionView: View {
	/// The Core Data view context.
	@Environment(\.managedObjectContext) private var viewContext
	
	/// The view type for displaying the images.
	var style: ImageCollectionViewStyle
	
	@Binding var fileSelection: Set<File>
	
	/// The size of thumbnails when displaying images as icons.
	@Binding var thumbnailScale: Double
	
	var filesToShow: [File]
	
	init(
		filesToShow: [File],
		fileSelection: Binding<Set<File>>,
		imageViewType: ImageCollectionViewStyle,
		thumbnailSize: Binding<Double>
	) {
		self.filesToShow = filesToShow
		style = imageViewType
		_fileSelection = fileSelection
		_thumbnailScale = thumbnailSize
	}
	
	var body: some View {
		switch style {
		case .asList:
			ImageCollectionListView(
				filesToShow: filesToShow,
				fileSelection: $fileSelection
			)
		case .asIcons:
			ImageCollectionIconsView(
				filesToShow: filesToShow,
				fileSelection: $fileSelection,
				thumbnailScale: thumbnailScale
			)
		}
	}
}

// MARK:- ImageViewType
/// The style for displaying the image selection view.
enum ImageCollectionViewStyle: Hashable {
	/// Displays the images as a list.
	case asList
	/// Displays the images as a grid of icons.
	case asIcons
}

// MARK:- Previews
struct ImageCollectionView_Previews: PreviewProvider {
	@State private static var fileSelection: Set<File> = []
	@State private static var thumbnailSize = C.defaultIconThumbnailSize
	
	private static func makeFilesToShow() -> [File] {
		let fetchRequest: NSFetchRequest<Directory> = Directory.fetchRequest()
		
		let viewContext = PersistenceController
			.preview
			.container
			.viewContext
		
		let fetchResult = try! viewContext.fetch(fetchRequest)
		let directories = Set(fetchResult)
		return Directory.files(inSelection: directories)
	}
	
	static var previews: some View {
		ImageCollectionView(filesToShow: makeFilesToShow(),
												fileSelection: $fileSelection,
												imageViewType: .asList,
												thumbnailSize: $thumbnailSize)
	}
}
