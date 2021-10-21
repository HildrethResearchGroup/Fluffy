//
//  InspectorView.swift
//  Fluffy
//
//  Created by Connor Barnes on 6/12/21.
//

import SwiftUI

/// A view displaying the inspector pane.
struct InspectorView: View {
	/// The files selected.
	//var fileSelection: Set<File>
	
	/// The directories selected.
	var directorySelection: Set<Directory>
    
    /// Manage the selection
    @EnvironmentObject var selectionManager: SelectionManager
    
	
	/// The inspector tab selected.
	@State var tabSelection = Tab.file
	
	var body: some View {
		VStack(spacing: 0.0) {
			HStack(spacing: 16.0) {
				ImageTabItemView(
					tab: .file,
					tabSelection: $tabSelection,
					imageName: "doc"
				)
				ImageTabItemView(
					tab: .directory,
					tabSelection: $tabSelection,
					imageName: "folder"
				)
			}
			.frame(height: 26.0)
			Divider()
			inspectorDetail
				.controlSize(.small)
		}
	}
}

// MARK:- Subviews
private extension InspectorView {
	/// The view showing the file inspector.
	@ViewBuilder
	var fileInspector: some View {
        switch selectionManager.fileSelection.count {
		case 0:
			Spacer()
			Text("No File Selected")
			Spacer()
		case 1:
			FileInspectorView(
				//file: fileSelection.first!
                file: selectionManager.fileSelection.first!
			)
		default:
			Spacer()
			Text("Multiple Selection")
			Spacer()
		}
	}
	
	/// The view showing the directory inspector.
	@ViewBuilder
	var directoryInspector: some View {
		switch directorySelection.count {
		case 0:
			Spacer()
			Text("No Directory Selected")
			Spacer()
		case 1:
			DirectoryInspectorView(
				directory: directorySelection.first!
			)
		default:
			Spacer()
			Text("Multiple Selection")
			Spacer()
		}
	}
	
	/// The view showing the currently selected inspector tab.
	@ViewBuilder
	var inspectorDetail: some View {
		switch tabSelection {
		case .file:
			fileInspector
		case .directory:
			directoryInspector
		}
	}
}

// MARK:- Tab
extension InspectorView {
	/// A tab item of the inspector.
	enum Tab {
		/// The file inspector.
		case file
		/// The directory inspector.
		case directory
	}
}

// MARK:- Previews
struct InspectorView_Previews: PreviewProvider {
	static var fileSelection: Set<File> = []
	static var directorySelection: Set<Directory> = []
	
	static var previews: some View {
		InspectorView(
			//fileSelection: fileSelection,
			directorySelection: directorySelection
		)
	}
}
