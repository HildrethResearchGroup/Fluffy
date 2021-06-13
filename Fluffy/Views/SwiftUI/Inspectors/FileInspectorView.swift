//
//  FileInspectorView.swift
//  Fluffy
//
//  Created by Connor Barnes on 6/12/21.
//

import SwiftUI

struct FileInspectorView: View {
	@ObservedObject var file: File
	@AppStorage("NameLocationIsExpanded") var nameLocationIsExpanded = true
	
	var body: some View {
		ScrollView(.vertical) {
			VStack {
				DisclosureGroup(
					"Name and Location",
					isExpanded: $nameLocationIsExpanded
				) {
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
extension FileInspectorView {
	@ViewBuilder
	var nameAndLocationView: some View {
		Text("Name")
		TextField("Name", text: customNameBinding)
		
		Text("Path")
			.alignmentGuide(.trailing, computeValue: { dimension in
				dimension[.top]
			})
		Text(file.url?.path ?? "")
			.lineLimit(nil)
	}
}

// MARK:- Helper Functions
extension FileInspectorView {
	var columns: [GridItem] {
		[
			.init(
				.fixed(64),
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
	
	var customNameBinding: Binding<String> {
		Binding {
			return file.displayName
		} set: { newValue in
			file.customName = newValue
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
