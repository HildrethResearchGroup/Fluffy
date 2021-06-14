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
	@EnvironmentObject var rootDirectory: Directory
	
	/// The currently selected directories in the sidebar.
	@State private var sidebarSelection: Set<Directory> = []
	
	@State private var fileSelection: Set<File> = []
	
	/// The style for displaying the image collection.
	@AppStorage("imageCollectionViewStyle") private var imageCollectionViewStyle = ImageCollectionViewStyle.asList
	
	@AppStorage("showInspector") private var showInspector = true
	
	/// An updater instance.
	///
	/// This is included to allow manually updating this view when the sidebar has files dragged onto it.
	@State private var updater = Updater()
	
	var body: some View {
		NavigationView {
			SidebarView(selection: $sidebarSelection, updater: $updater)
				.frame(minWidth: 150, idealWidth: 300, maxWidth: .infinity)
			ZStack {
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
					
					Spacer()
						.frame(
							width: showInspector
								? C.inspectorWidth
								: 0
						)
				}
				
				.zIndex(1.0)
				
				HStack(spacing: 0) {
					Spacer()
					
					HStack(spacing: 0) {
						Divider()
						InspectorView(
							fileSelection: fileSelection,
							directorySelection: sidebarSelection
						)
					}
					.frame(width: C.inspectorWidth)
				}
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
			}.pickerStyle(InlinePickerStyle())
		}
	}
	
	var inspectorToolbarItem: some CustomizableToolbarContent {
		ToolbarItem(id: "Inspector") {
			Button {
				showInspector.toggle()
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
