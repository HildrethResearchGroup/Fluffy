//
//  InspectorView.swift
//  Fluffy
//
//  Created by Connor Barnes on 6/12/21.
//

import SwiftUI

struct InspectorView: View {
	var fileSelection: Set<File>
	var directorySelection: Set<Directory>
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
extension InspectorView {
	@ViewBuilder
	var fileInspector: some View {
		switch fileSelection.count {
		case 0:
			Spacer()
			Text("No File Selected")
			Spacer()
		case 1:
			FileInspectorView(
				file: fileSelection.first!
			)
		default:
			Spacer()
			Text("Multiple Selection")
			Spacer()
		}
	}
	
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
	enum Tab {
		case file
		case directory
	}
}

// MARK:- Previews
struct InspectorView_Previews: PreviewProvider {
	static var fileSelection: Set<File> = []
	static var directorySelection: Set<Directory> = []
	
	static var previews: some View {
		InspectorView(
			fileSelection: fileSelection,
			directorySelection: directorySelection
		)
	}
}
