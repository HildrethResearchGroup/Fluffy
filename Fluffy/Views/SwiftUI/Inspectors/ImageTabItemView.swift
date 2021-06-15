//
//  ImageTabItemView.swift
//  Fluffy
//
//  Created by Connor Barnes on 6/12/21.
//

import SwiftUI

/// A view showing an image representing a tab item.
struct ImageTabItemView<Tab: Equatable>: View {
	/// The name of the SF Symbol to display when the tab item is not selected.
	var imageName: String
	
	/// The name of the SF Symbol to display when the tab item is selected.
	var selectedImageName: String
	
	/// The tab that the image represents.
	var tab: Tab
	
	/// The currently selected tab item in the tab view.
	@Binding var tabSelection: Tab
	
	/// Creates a new tab item representing the given tab.
	/// - Parameters:
	///   - tab: The tab this item represents.
	///   - tabSelection: The selected tab item.
	///   - imageName: The name of the SF Symbol to display when the item is not selected.
	///   - selectedImageName: The name of the SF Symbol to display when the item is selected. If `nil`, uses the filled variant of `imageName`.
	init(
		tab: Tab,
		tabSelection: Binding<Tab>,
		imageName: String,
		selectedImageName: String? = nil
	) {
		self.imageName = imageName
		self.selectedImageName = selectedImageName
			?? imageName + ".fill"
		self.tab = tab
		_tabSelection = tabSelection
	}
	
	var body: some View {
		Button {
			tabSelection = tab
		} label: {
			Image(
				systemName: tabSelection == tab
					? selectedImageName
					: imageName
			)
			.foregroundColor(
				tabSelection == tab
					? .accentColor
					: Color(.secondaryLabelColor)
			)
		}
		.buttonStyle(BorderlessButtonStyle())
	}
}

// MARK:- Previews
struct ImageTabItemView_Previews: PreviewProvider {
	enum Tab {
		case file
		case directory
	}
	
	static var previews: some View {
		ImageTabItemView(
			tab: Tab.file,
			tabSelection: .constant(.file),
			imageName: "doc"
		)
	}
}
