//
//  PrimaryView.swift
//  Images
//
//  Created by Connor Barnes on 2/20/21.
//

import SwiftUI

struct PrimaryView: View {
	@Environment(\.managedObjectContext) private var viewContext
	@EnvironmentObject var rootDirectory: Directory
	@State private var sidebarSelection: Set<Directory> = []
	@State private var imageViewType = ImageViewType.asList
	@State private var updater = Updater()
	
	var body: some View {
		NavigationView {
			SidebarView(selection: $sidebarSelection, updater: $updater)
				.frame(minWidth: 150, idealWidth: 300, maxWidth: .infinity)
			ImageCollectionView(selectedDirectories: sidebarSelection,
													imageViewType: $imageViewType)
				.manualUpdater($updater)
		}
		.toolbar(id: "Test") {
			sidebarToolbarItem
			viewAsToolbarItem
			flexibleSpaceToolbarItem
		}
	}
}

// MARK: Toolbar Items
extension PrimaryView {
	var sidebarToolbarItem: some CustomizableToolbarContent {
		ToolbarItem(id: "Sidebar", placement: .navigation) {
			Button {
				NSApp
					.keyWindow?
					.firstResponder?
					.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)),
												with: nil)
			} label: {
				Image(systemName: "sidebar.left")
			}
		}
	}
	
	var viewAsToolbarItem: some CustomizableToolbarContent {
		ToolbarItem(id: "View") {
			Picker(selection: $imageViewType, label: Text("View")) {
				Image(systemName: "list.bullet").tag(ImageViewType.asList)
				Image(systemName: "square.grid.2x2").tag(ImageViewType.asIcons)
			}.pickerStyle(InlinePickerStyle())
		}
	}
	
	var flexibleSpaceToolbarItem: some CustomizableToolbarContent {
		ToolbarItem(id: "Spacer", showsByDefault: false) {
			Spacer()
		}
	}
}

// MARK:- ImageViewType
enum ImageViewType: Hashable {
	case asList
	case asIcons
}

// MARK:- Previews
struct PrimaryView_Previews: PreviewProvider {
	static var previews: some View {
		PrimaryView()
	}
}
