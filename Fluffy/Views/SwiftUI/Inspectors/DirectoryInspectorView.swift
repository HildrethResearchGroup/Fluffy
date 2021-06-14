//
//  DirectoryInspectorView.swift
//  Fluffy
//
//  Created by Connor Barnes on 6/14/21.
//

import SwiftUI

struct DirectoryInspectorView: View {
	@ObservedObject var directory: Directory
	@AppStorage("DirectoryNameLocationIsExpanded") var nameLocationIsExpanded = true
	@Environment(\.managedObjectContext) var viewContext
	
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
extension DirectoryInspectorView {
	@ViewBuilder
	var nameAndLocationView: some View {
		Text("Name")
		TextField("Name", text: customNameBinding)
		
		Text("Path")
			.alignmentGuide(.trailing, computeValue: { dimension in
				dimension[.top]
			})
		HStack(alignment: .bottom) {
			Text(directory.url?.path ?? "")
				.lineLimit(nil)
			if let url = directory.url {
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
extension DirectoryInspectorView {
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
	
	var customNameBinding: Binding<String> {
		Binding {
			return directory.displayName
		} set: { newValue in
			directory.customName = newValue
			SidebarViewController.currentController.outlineView.reloadData()
			
			do {
				try viewContext.save()
			} catch {
				print("[WARNING] Failed to save model: \(error)")
			}
		}
	}
}

// MARK:- Previews
struct DirectoryInspectorView_Previews: PreviewProvider {
	@StateObject static var directory: Directory = {
		let context = PersistenceController.preview
			.container
			.viewContext
		
		let directory = Directory(context: context)
		directory.url = URL(
			fileURLWithPath: "/Users/username/Documents/Images/Flowers/"
		)
		
		return directory
	}()
	
	static var previews: some View {
		DirectoryInspectorView(directory: directory)
	}
}
