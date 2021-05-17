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
	
	/// The size of thumbnails when displaying images as icons.
	@State var thumbnailScale: CGFloat = 64.0
	
	/// The group used for loading images from disk lazily.
	static let lazyDiskImageGroup = "ImageCollectionView"
	
	/// The currently selected directories.
	var selectedDirectories: Set<Directory>
	
	init(
		selectedDirectories: Set<Directory>,
		imageViewType: Binding<ImageCollectionViewStyle>
	) {
		self.selectedDirectories = selectedDirectories
		_style = imageViewType
		DiskImageLoader.clearQueue(for: Self.lazyDiskImageGroup)
	}
	
	var body: some View {
		VStack(spacing: 0.0) {
			contentView
			Divider()
			bottomBar
		}
	}
}

// MARK:- Subviews
extension ImageCollectionView {
	/// The bottom bar view.
	@ViewBuilder
	var bottomBar: some View {
		ZStack {
			VisualEffectView(effect: .withinWindow, material: .titlebar)
				.frame(height: 26.0)
			HStack {
				Spacer()
				Text("\(filesToShow.count) Items")
				Spacer()
				if (style == .asIcons) {
					Slider(value: $thumbnailScale, in: 32.0...128.0)
						.frame(maxWidth: 64.0, alignment: .trailing)
				}
			}
			.padding([.leading, .trailing])
		}.frame(height: 26.0)
	}
	
	/// The content view containing the images.
	@ViewBuilder
	var contentView: some View {
		switch style {
		case .asList:
			ImageCollectionListView(filesToShow: filesToShow,
															lazyDiskImageGroup: Self.lazyDiskImageGroup)
		case .asIcons:
			ImageCollectionIconsView(filesToShow: filesToShow,
															 lazyDiskImageGroup: Self.lazyDiskImageGroup,
															 thumbnailScale: $thumbnailScale)
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

// MARK:- Helper Functions
extension ImageCollectionView {
	/// The files to show based off the currently selected directories.
	var filesToShow: [File] {
		func filesToShow(in directory: Directory) -> [File] {
			directory.files
				.map { $0 as! File }
				+ directory.subdirectories
				.flatMap { filesToShow(in: $0 as! Directory) }
		}
		
		func ancestor(
			of directory: Directory,
			isContainedIn set: Set<Directory>
		) -> Bool {
			var parent = directory.parent
			while let nextParent = parent {
				if set.contains(nextParent) {
					return true
				}
				parent = nextParent.parent
			}
			return false
		}
		
		return selectedDirectories
			.filter { !ancestor(of: $0, isContainedIn: selectedDirectories) }
			.flatMap { filesToShow(in: $0) }
	}
}

// MARK:- Previews
struct ImageCollectionView_Previews: PreviewProvider {
	@State static var selectedDirectories: Set<Directory> = makeSelectedDirectories()
	@State static var imageViewType = ImageCollectionViewStyle.asList
	
	static func makeSelectedDirectories() -> Set<Directory> {
		let fetchRequest: NSFetchRequest<Directory> = Directory.fetchRequest()
		
		let viewContext = PersistenceController
			.preview
			.container
			.viewContext
		
		let fetchResult = try! viewContext.fetch(fetchRequest)
		
		return Set(fetchResult)
	}
	
	static var previews: some View {
		ImageCollectionView(selectedDirectories: selectedDirectories,
												imageViewType: $imageViewType)
	}
}
