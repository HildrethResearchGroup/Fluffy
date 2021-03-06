//
//  SettingsView.swift
//  Fluffy
//
//  Created by Connor Barnes on 6/10/21.
//

import SwiftUI

/// The view for displaying the user's app preferences.
struct SettingsView: View {
	/// Wether the user would like to filter file types.
	@AppStorage("filterFileTypes") private var filterFileTypes = true
	
	/// The file types the user would like to filter.
	@AppStorage("fileTypes") private var fileTypes = [
		"png",
		"jpg",
		"jpeg",
		"tiff",
		"gif"
	]
	
	/// The files types selected.
	@State private var fileTypeSelection: Set<Int> = []
	
	var body: some View {
		Form {
			Toggle("Filter File Types", isOn: $filterFileTypes)
			
			if filterFileTypes {
				fileTypeView
			}
		}
		.padding()
		.frame(width: 240,
					 alignment: .leading)
	}
}

// MARK: Subviews
private extension SettingsView {
	/// The view for the file type preference.
	@ViewBuilder
	var fileTypeView: some View {
		VStack(spacing: 0.0) {
			List(
				fileTypes.indices,
				id: \.self,
				selection: $fileTypeSelection
			) { index in
				TextField(
					"extension",
					text: Binding {
						guard index < fileTypes.count else {
							return ""
						}
						return fileTypes[index]
					} set: { newValue in
						guard index < fileTypes.count else {
							return
						}
						fileTypes[index] = newValue
					}
				)
			}
			.listStyle(PlainListStyle())
			.frame(height: 200.0)
			
			fileSelectionFooterView
		}
		.border(SeparatorShapeStyle())
	}
	
	/// The footer view for the file selection view.
	@ViewBuilder
	var fileSelectionFooterView: some View {
		HStack {
			Button {
				addFileType()
			} label: {
				Image(systemName: "plus")
					.frame(width: 16, height: 16)
			}
			
			Button {
				removeSelectedFileTypes()
			} label: {
				Image(systemName: "minus")
					.frame(width: 16, height: 16)
			}
			
			Spacer()
		}
		.buttonStyle(BorderlessButtonStyle())
		.padding(2.0)
	}
}

// MARK: Helper Functions
private extension SettingsView {
	/// Adds a new file type.
	func addFileType() {
		fileTypes.append("extension")
	}
	
	/// Removes the selected file types.
	func removeSelectedFileTypes() {
		fileTypes.remove(
			atOffsets: .init(fileTypeSelection)
		)
		
		fileTypeSelection = []
	}
}

// MARK: Preview
struct SettingsView_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView()
	}
}
