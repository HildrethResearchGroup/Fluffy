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
	static let group = "ImageCollectionView"
	var selectedDirectories: Set<Directory>
	
	var body: some View {
		ZStack(alignment: .bottom) {
			contentView
			VStack(spacing: 0.0) {
				Divider()
				ZStack {
					VisualEffectView(effect: .withinWindow, material: .titlebar)
						.frame(height: 26.0)
					HStack {
						Text("\(filesToShow.count) Items")
					}
				}
			}.frame(height: 26.0)
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
	var contentView: some View {
		switch imageViewType {
		case .asList:
			ImageCollectionListView(filesToShow: filesToShow,
															lazyDiskImageGroup: Self.group)
		case .asIcons:
			ImageCollectionIconsView(filesToShow: filesToShow,
															 lazyDiskImageGroup: Self.group)
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
