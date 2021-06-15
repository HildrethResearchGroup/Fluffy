//
//  FileInspectorView.swift
//  Fluffy
//
//  Created by Connor Barnes on 6/12/21.
//

import SwiftUI

/// The view for the file inspector.
struct FileInspectorView: View {
	/// The file to display info for.
	@ObservedObject var file: File
	
	/// Whether the name and location disclosure group is expanded.
	@AppStorage("FileNameLocationIsExpanded") var nameLocationIsExpanded = true
	
	/// The managed object context.
	@Environment(\.managedObjectContext) var viewContext
	
	var body: some View {
		ScrollView(.vertical) {
			VStack {
				DisclosureGroup(
					"Name and Location",
					isExpanded: $nameLocationIsExpanded
				) {
					// Place in grid to align all labels
					LazyVGrid(columns: columns, content: {
						nameAndLocationView
					})
					.padding(4.0)
				}
			}
			.padding()
		}
	}
}

// MARK:- Subviews
private extension FileInspectorView {
	/// The name and location group.
	@ViewBuilder
	var nameAndLocationView: some View {
		Text("Name")
		TextField("Name", text: customNameBinding)
		
		Text("Path")
			.alignmentGuide(.trailing, computeValue: { dimension in
				dimension[.top]
			})
		HStack(alignment: .bottom) {
			Text(file.url?.path ?? "")
				.lineLimit(nil)
			if let url = file.url {
				Spacer()
				Button {
					url.showInFinder()
				} label: {
					Image(systemName: "arrow.right.circle.fill")
				}
				.buttonStyle(BorderlessButtonStyle())
			}
		}
	}
}

// MARK:- Helper Functions
private extension FileInspectorView {
	/// The columns for the inspector items.
	var columns: [GridItem] {
		[
			.init(
				.fixed(50),
				spacing: 6.0,
				alignment: .trailing
			),
			.init(
				.flexible(),
				spacing: 6.0,
				alignment: .leading
			)
		]
	}
	
	/// The binding for the custom name text field.
	var customNameBinding: Binding<String> {
		Binding {
			return file.displayName
		} set: { newValue in
			file.customName = newValue
			
			
			do {
				try viewContext.save()
			} catch {
				print("[WARNING] Failed to save model: \(error)")
			}
		}
	}
}

// MARK:- Previews
struct FileInspectorView_Previews: PreviewProvider {
	@StateObject static var file: File = {
		let context = PersistenceController.preview
			.container
			.viewContext
		
		let file = File(context: context)
		file.url = URL(
			fileURLWithPath: "/Users/username/Documents/Images/Flowers/Tulip.png"
		)
		
		return file
	}()
	
	static var previews: some View {
		FileInspectorView(file: file)
			.frame(width: 300)
	}
}
