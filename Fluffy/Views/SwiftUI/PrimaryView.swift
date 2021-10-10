//
//  PrimaryView.swift
//  Fluffy
//
//  Created by Connor Barnes on 2/20/21.
//

import SwiftUI

/// The app's primary view. This view contains all the app's subviews.
struct PrimaryView: View {
	/// The Core Data view context.
	@Environment(\.managedObjectContext) private var viewContext
    
	
	/// The app's root directory.
	@EnvironmentObject private var rootDirectory: Directory
	
	/// The currently selected directories in the sidebar.
	@State private var sidebarSelection: Set<Directory> = []
	
	/// The currently selected files.
	@State private var fileSelection: Set<File> = []
	
	/// The style for displaying the image collection.
	@AppStorage("imageCollectionViewStyle") private var imageCollectionViewStyle = ImageCollectionViewStyle.asList
	
	/// Whether the inspector is currently shown.
	@AppStorage("showInspector") private var isShowingInspector = true
	
	/// An updater instance.
	///
	/// This is included to allow manually updating this view when the sidebar has files dragged onto it.
	@State private var updater = Updater()
	
	var body: some View {
		NavigationView {
			SidebarView(selection: $sidebarSelection, updater: $updater)
				.frame(
					minWidth: 150,
					idealWidth: 300,
					maxWidth: .infinity
				)
			
			ZStack {
				centerView
					.zIndex(1.0)
				
				inspector
					.zIndex(0.0)
			}
		}
		.toolbar(id: "PrimaryToolbar") {
			sidebarToolbarItem
			viewAsToolbarItem
			flexibleSpaceToolbarItem
			inspectorToolbarItem
		}
	}
}

// MARK:- Subviews
private extension PrimaryView {
	/// The view of the inspector.
	@ViewBuilder
	var inspector: some View {
		HStack(spacing: 0) {
			Spacer()
			
			HStack(spacing: 0) {
				Divider()
				VStack(spacing: 0) {
					Divider()
					InspectorView(
						fileSelection: fileSelection,
						directorySelection: sidebarSelection
					)
				}
			}
			.frame(width: C.inspectorWidth)
		}
	}
	
	/// The view of the center view.
	@ViewBuilder
	var centerView: some View {
		HStack(spacing: 0.0) {
			CenterView(
				fileSelection: $fileSelection,
				sidebarSelection: $sidebarSelection,
				updater: $updater,
				imageCollectionViewStyle: imageCollectionViewStyle
			)
			.background(
				Color(.controlBackgroundColor)
			)
			.manualUpdater($updater)
			.animation(.easeInOut)
			
			// Add space for inspector if it is shown
			Spacer()
				.frame(
					width: isShowingInspector
						? C.inspectorWidth
						: 0
				)
		}
	}
}

// MARK:- Toolbar Items
private extension PrimaryView {
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
				Image(systemName: "sidebar.leading")
			}
		}
	}
	
	/// The toolbar item for selecting the view style for the image collection.
	var viewAsToolbarItem: some CustomizableToolbarContent {
		ToolbarItem(id: "View") {
			Picker(selection: $imageCollectionViewStyle, label: Text("View")) {
				Image(systemName: "list.bullet").tag(ImageCollectionViewStyle.asList)
				Image(systemName: "square.grid.2x2").tag(ImageCollectionViewStyle.asIcons)
                Image(systemName: "tablecells").tag(ImageCollectionViewStyle.asTable)
			}.pickerStyle(InlinePickerStyle())
		}
	}
	
	/// The toolbar item for hiding/showing the inspector.
	var inspectorToolbarItem: some CustomizableToolbarContent {
		ToolbarItem(id: "Inspector") {
			Button {
				isShowingInspector.toggle()
			} label: {
				Image(systemName: "sidebar.trailing")
			}
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
