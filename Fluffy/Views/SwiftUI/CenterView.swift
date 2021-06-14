//
//  CenterView.swift
//  Fluffy
//
//  Created by Connor Barnes on 6/7/21.
//

import SwiftUI

struct CenterView: View {
	@Binding var fileSelection: Set<File>
	@Binding var sidebarSelection: Set<Directory>
	@Binding var updater: Updater
	@AppStorage("thumbnailScale") private var thumbnailScale = C.defaultIconThumbnailSize
	@AppStorage("filterFileTypes") private var filterFileTypes = true
	@AppStorage("fileTypes") private var fileTypes = [
		"png",
		"jpg",
		"jpeg",
		"tiff",
		"gif"
	]
	
	/// The style for displaying the image collection.
	var imageCollectionViewStyle: ImageCollectionViewStyle
	
	var body: some View {
		let filesToShow = Directory.files(inSelection: sidebarSelection)
			.filter { file in
				if filterFileTypes {
					let `extension` = file.url?.pathExtension ?? ""
					return fileTypes.contains(`extension`)
				} else {
					return true
				}
			}
		
		VStack(spacing: 0) {
			VSplitView {
				ImageCollectionView(
					filesToShow: filesToShow,
					fileSelection: $fileSelection,
					updater: $updater,
					imageViewType: imageCollectionViewStyle,
					thumbnailSize: $thumbnailScale
				)
				detailView
					.frame(maxWidth: .infinity,
								 maxHeight: .infinity)
			}
			Divider()
			BottomBarView(
				numberOfFilesSelected: fileSelection.count,
				numberOfFilesShown: filesToShow.count,
				numberOfDirectoriesSelected: sidebarSelection.count,
				thumbnailScale: thumbnailScaleBinding
			)
		}
	}
}

// MARK: Subviews
extension CenterView {
	@ViewBuilder
	var detailView: some View {
		switch fileSelection.count {
		case 0:
			Text("No Selection")
				.id("DetailImage")
		case 1:
			DetailView(file: fileSelection.first!)
		default:
			Text("Multiple Selection")
				.id("DetailImage")
		}
	}
}

// MARK: Computed Properties
extension CenterView {
	var thumbnailScaleBinding: Binding<Double>? {
		switch imageCollectionViewStyle {
		case .asList:
			return nil
		case .asIcons:
			return $thumbnailScale
		}
	}
}

// MARK: Previews
struct CenterView_Previews: PreviewProvider {
	@State static var fileSelection: Set<File> = []
	@State static var sidebarSelection: Set<Directory> = []
	
	static var previews: some View {
		CenterView(
			fileSelection: $fileSelection,
			sidebarSelection: $sidebarSelection,
			updater: .constant(Updater()),
			imageCollectionViewStyle: .asList
		)
	}
}
