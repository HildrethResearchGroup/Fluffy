//
//  BottomBarView.swift
//  Images
//
//  Created by Connor Barnes on 6/4/21.
//

import SwiftUI

struct BottomBarView: View {
	var numberOfFilesSelected: Int
	var numberOfFilesShown: Int
	var numberOfDirectoriesSelected: Int
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
					Slider(value: binding, in: 32.0...128.0)
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
