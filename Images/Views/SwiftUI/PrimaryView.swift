//
//  PrimaryView.swift
//  Images
//
//  Created by Connor Barnes on 2/20/21.
//

import SwiftUI

/// The app's primary view. This view contains all the app's subviews.
struct PrimaryView: View {
	/// The Core Data view context.
	@Environment(\.managedObjectContext) private var viewContext
	
	/// The app's root directory.
	@EnvironmentObject var rootDirectory: Directory
	
	/// The currently selected directories in the sidebar.
	@State private var sidebarSelection: Set<Directory> = []
	
	/// The style for displaying the image collection.
	@State private var imageCollectionViewStyle = ImageCollectionViewStyle.asList
	
	/// An updater instance.
	///
	/// This is included to allow manually updating this view when the sidebar has files dragged onto it.
	@State private var updater = Updater()
	
	var body: some View {
		NavigationView {
			SidebarView(selection: $sidebarSelection, updater: $updater)
				.frame(minWidth: 150, idealWidth: 300, maxWidth: .infinity)
			ImageCollectionView(selectedDirectories: sidebarSelection,
													imageViewType: $imageCollectionViewStyle)
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
	/// The toolbar item for hiding/showing the sidebar.
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
	
	/// The toolbar item for selecting the view style for the image collection.
	var viewAsToolbarItem: some CustomizableToolbarContent {
		ToolbarItem(id: "View") {
			Picker(selection: $imageCollectionViewStyle, label: Text("View")) {
				Image(systemName: "list.bullet").tag(ImageCollectionViewStyle.asList)
				Image(systemName: "square.grid.2x2").tag(ImageCollectionViewStyle.asIcons)
			}.pickerStyle(InlinePickerStyle())
		}
	}
	
	/// The flexible space toolbar item.
	var flexibleSpaceToolbarItem: some CustomizableToolbarContent {
		ToolbarItem(id: "Flexible Space", showsByDefault: false) {
			Spacer()
		}
	}
}

// MARK:- Previews
struct PrimaryView_Previews: PreviewProvider {
	static var previews: some View {
		PrimaryView()
	}
}
