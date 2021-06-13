//
//  ImageTabItemView.swift
//  Fluffy
//
//  Created by Connor Barnes on 6/12/21.
//

import SwiftUI

struct ImageTabItemView<Tab: Equatable>: View {
	var imageName: String
	var selectedImageName: String
	var tab: Tab
	@Binding var tabSelection: Tab
	
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
