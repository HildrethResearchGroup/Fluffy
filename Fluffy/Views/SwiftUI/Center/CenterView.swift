//
//  CenterView.swift
//  Fluffy
//
//  Created by Connor Barnes on 6/7/21.
//

import SwiftUI

/// The center pane in the application.
struct CenterView: View {
	/// The  selected files.
	@Binding var fileSelection: Set<File>
	
	/// The selected directories.
	@Binding var sidebarSelection: Set<Directory>
	
	/// A manual updater for updating the files to show.
	@Binding var updater: Updater
	
	/// The size of thumbnails in icons view.
	@AppStorage("thumbnailScale") private var thumbnailScale = C.defaultIconThumbnailSize
	
	/// Whether or not to filter files by their file type.
	@AppStorage("filterFileTypes") private var filterFileTypes = true
	
	/// The file types to filter for.
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
					style: imageCollectionViewStyle,
					thumbnailSize: $thumbnailScale
				)
					.animation(nil)
				detailView
					.frame(maxWidth: .infinity,
								 maxHeight: .infinity)
					.animation(nil)
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
private extension CenterView {
	/// The detail view displaying the selected image.
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
private extension CenterView {
	/// The binding for the thumbnail scale if in icons view, otherwise `nil`.
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
