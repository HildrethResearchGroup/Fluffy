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
	
	@State private var fileSelection: Set<File> = []
	
	/// The style for displaying the image collection.
	@State private var imageCollectionViewStyle = ImageCollectionViewStyle.asList
	
	@State private var thumbnailScale = 64.0
	
	/// An updater instance.
	///
	/// This is included to allow manually updating this view when the sidebar has files dragged onto it.
	@State private var updater = Updater()
	
	var body: some View {
		// Used multiple times, so calculate only once
		let filesToShow = Directory.files(inSelection: sidebarSelection)
		
		NavigationView {
			SidebarView(selection: $sidebarSelection, updater: $updater)
				.frame(minWidth: 150, idealWidth: 300, maxWidth: .infinity)
			VStack(spacing: 0) {
				VSplitView {
					ImageCollectionView(
						filesToShow: filesToShow,
						fileSelection: $fileSelection,
						imageViewType: $imageCollectionViewStyle
					)
					.manualUpdater($updater)
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
		.toolbar(id: "Test") {
			sidebarToolbarItem
			viewAsToolbarItem
			flexibleSpaceToolbarItem
		}
	}
}

// MARK:- Subviews
extension PrimaryView {
	@ViewBuilder
	var detailView: some View {
		switch fileSelection.count {
		case 0:
			Text("No Selection")
		case 1:
			DetailView(file: fileSelection.first!)
		default:
			Text("Multiple Selection")
		}
	}
}

// MARK:- Toolbar Items
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

// MARK:- Helper Functions
extension PrimaryView {
	var thumbnailScaleBinding: Binding<Double>? {
		switch imageCollectionViewStyle {
		case .asList:
			return nil
		case .asIcons:
			return $thumbnailScale
		}
	}
}

// MARK:- Previews
struct PrimaryView_Previews: PreviewProvider {
	static var previews: some View {
		PrimaryView()
	}
}
