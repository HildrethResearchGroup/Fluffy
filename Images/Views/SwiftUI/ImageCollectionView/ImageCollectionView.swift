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
	@Binding var style: ImageCollectionViewStyle
	
	@Binding var fileSelection: Set<File>
	
	/// The size of thumbnails when displaying images as icons.
	@State var thumbnailScale: CGFloat = 64.0
	
	/// The group used for loading images from disk lazily.
	static let lazyDiskImageGroup = "ImageCollectionView"
	
	var filesToShow: [File]
	
	init(
		filesToShow: [File],
		fileSelection: Binding<Set<File>>,
		imageViewType: Binding<ImageCollectionViewStyle>
	) {
		self.filesToShow = filesToShow
		_style = imageViewType
		_fileSelection = fileSelection
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
				thumbnailScale: $thumbnailScale
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
	@State private static var imageViewType = ImageCollectionViewStyle.asList
	@State private static var fileSelection: Set<File> = []
	
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
												imageViewType: $imageViewType)
	}
}
