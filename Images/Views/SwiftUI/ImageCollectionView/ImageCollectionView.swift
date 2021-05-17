//
//  ImageCollectionView.swift
//  Images
//
//  Created by Connor Barnes on 3/15/21.
//

import SwiftUI

struct ImageCollectionView: View {
	@Environment(\.managedObjectContext) private var viewContext
	@Binding var imageViewType: ImageViewType
	@State var thumbnailScale: CGFloat = 64.0
	static let group = "ImageCollectionView"
	var selectedDirectories: Set<Directory>
	
	var body: some View {
		VStack(spacing: 0.0) {
			contentView
			Divider()
			bottomBar
		}
	}
	
	init(
		selectedDirectories: Set<Directory>,
		imageViewType: Binding<ImageViewType>
	) {
		self.selectedDirectories = selectedDirectories
		_imageViewType = imageViewType
		DiskImageLoader.clearQueue(for: Self.group)
	}
}

// MARK: Subviews
extension ImageCollectionView {
	@ViewBuilder
	var bottomBar: some View {
		ZStack {
			VisualEffectView(effect: .withinWindow, material: .titlebar)
				.frame(height: 26.0)
			HStack {
				Spacer()
				Text("\(filesToShow.count) Items")
				Spacer()
				Slider(value: $thumbnailScale, in: 32.0...512.0)
					.frame(maxWidth: 64.0, alignment: .trailing)
			}
			.padding([.leading, .trailing])
		}.frame(height: 26.0)
	}
	
	@ViewBuilder
	var contentView: some View {
		switch imageViewType {
		case .asList:
			ImageCollectionListView(filesToShow: filesToShow,
															lazyDiskImageGroup: Self.group)
		case .asIcons:
			ImageCollectionIconsView(filesToShow: filesToShow,
															 lazyDiskImageGroup: Self.group,
															 thumbnailScale: $thumbnailScale)
		}
	}
}

// MARK: Helper Functions
extension ImageCollectionView {
	var filesToShow: [File] {
		func filesToShow(in directory: Directory) -> [File] {
			directory.files
				.map { $0 as! File }
				+ directory.subdirectories
				.flatMap { filesToShow(in: $0 as! Directory) }
		}
		
		return selectedDirectories
			.flatMap { filesToShow(in: $0) }
	}
}

// MARK: Previews
struct ImageCollectionView_Previews: PreviewProvider {
	@State static var selectedDirectories: Set<Directory> = makeSelectedDirectories()
	@State static var imageViewType = ImageViewType.asList
	
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
