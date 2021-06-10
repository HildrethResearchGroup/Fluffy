//
//  SettingsView.swift
//  Images
//
//  Created by Connor Barnes on 6/10/21.
//

import SwiftUI

struct SettingsView: View {
	@AppStorage("filterFileTypes") private var filterFileTypes = true
	@AppStorage("fileTypes") private var fileTypes = [
		"png",
		"jpg",
		"jpeg",
		"tiff",
		"gif"
	]
	
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
extension SettingsView {
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
extension SettingsView {
	func addFileType() {
		fileTypes.append("extension")
	}
	
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
