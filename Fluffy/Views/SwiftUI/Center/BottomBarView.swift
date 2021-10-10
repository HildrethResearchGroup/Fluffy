//
//  BottomBarView.swift
//  Fluffy
//
//  Created by Connor Barnes on 6/4/21.
//

import SwiftUI

/// A view displaying the bottom bar of the application.
struct BottomBarView: View {
	/// The number of files selected.
	var numberOfFilesSelected: Int
	
	/// The number of files shown.
	var numberOfFilesShown: Int
	
	/// The number of directories selected.
	var numberOfDirectoriesSelected: Int
	
	/// The size of thumbnails to display if in icon view.
	var thumbnailScale: Binding<Double>?
	
	var body: some View {
		ZStack {
			VisualEffectView(effect: .withinWindow, material: .titlebar)
				.frame(height: 26)
			HStack {
				Spacer()
				Text(bottomText)
				Spacer()
				if let binding = thumbnailScale {
					Slider(value: binding,
                           in: C.minimumIconThumbnailSize...C.maximumIconThumbnailSize)
						.frame(maxWidth: 64.0, alignment: .trailing)
				}
			}
			.padding([.leading, .trailing])
		}
		.frame(height: 26)
	}
}

// MARK:- Helper Functions
private extension BottomBarView {
	/// The text to display in the bar.
	var bottomText: String {
		let selectionText: String = {
			if numberOfFilesSelected == 0 {
				return ""
			} else {
				return "\(numberOfFilesSelected) of "
			}
		}()
		
		let itemText: String = {
			let itemWord = numberOfFilesShown == 1
				? "item"
				: "items"
			
			return "\(numberOfFilesShown) \(itemWord)"
		}()
		
		let directoryText: String = {
			let directoryWord = numberOfDirectoriesSelected == 1
				? "directory"
				: "directories"
			
			return "\(numberOfDirectoriesSelected) \(directoryWord)"
		}()
		
		return "\(selectionText)\(itemText) in \(directoryText)"
	}
}

// MARK:- Previews
struct BottomBarView_Previews: PreviewProvider {
	@State static var thumbnailScale = 64.0
	
	static var previews: some View {
		BottomBarView(
			numberOfFilesSelected: 4,
			numberOfFilesShown: 36,
			numberOfDirectoriesSelected: 2,
			thumbnailScale: $thumbnailScale
		)
	}
}
