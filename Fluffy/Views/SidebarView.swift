//
//  SidebarView.swift
//  Fluffy
//
//  Created by Connor Barnes on 4/5/21.
//

import SwiftUI

/// The app's sidebar view, which displays the imported directories.
struct SidebarView: View {
	/// The selected directories in the sidebar.
	@Binding var selection: Set<Directory>
    
    /// Manage the selection
    @EnvironmentObject var selectionManager: SelectionManager
	
	/// An updater instance for manual updating.
	///
	/// This is needed to force updating when images have been dragged onto a directory.
	@Binding var updater: Updater
	
	/// The managed object context.
	@Environment(\.managedObjectContext) var viewContext

	var body: some View {
		switch rootDirectory {
		case .success(let root):
			SidebarViewController(rootDirectory: root,
														selection: $selection,
														updater: $updater)
		case .failure(let error):
			failureView(forError: error)
		}
	}
}

// MARK:- Subviews
extension SidebarView {
	/// The view to display when loading the root directory failed.
	/// - Parameter error: The error that was thrown.
	/// - Returns: The failure view.
	@ViewBuilder
	func failureView(forError error: Error) -> some View {
		ZStack {
			Image(systemName: "exclamationmark.triangle")
				.font(.largeTitle)
			VStack {
				Spacer()
				Text("Error: \(error.localizedDescription)")
					.font(.body)
			}
		}
		.padding()
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(VisualEffectView(effect: .behindWindow, material: .sidebar))
	}
}

// MARK:- Helper Functions
extension SidebarView {
	/// The app's root directory.
	var rootDirectory: Result<Directory, Error> {
		PersistenceController
			.shared
			.loadRootDirectory()
	}
}

// MARK:- Previews
struct SidebarView_Previews: PreviewProvider {
	@State static var selection: Set<Directory> = []
	@State static var updater = Updater()
	
	static var previews: some View {
		SidebarView(selection: $selection, updater: $updater)
	}
}
