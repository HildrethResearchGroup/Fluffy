//
//  ImageCollectionItemContextMenu.swift
//  Fluffy
//
//  Created by Connor Barnes on 6/14/21.
//

import SwiftUI

struct ImageCollectionItemContextMenu: View {
	let file: File
	@Binding var fileSelection: Set<File>
	@Binding var updater: Updater
	@Environment(\.managedObjectContext) var viewContext
	
	var body: some View {
		showInFinderItem
		removeItem
	}
}

// MARK:- Menu Items
extension ImageCollectionItemContextMenu {
	@ViewBuilder
	var showInFinderItem: some View {
		if fileSelection.count > 1
				&& fileSelection.contains(file) {
			Button {
				fileSelection
					.compactMap(\.url)
					.showInFinder()
			} label: {
				Text("Show \(fileSelection.count) Files in Finder")
			}
		} else {
			Button {
				file.url?.showInFinder()
			} label: {
				Text("Show \"\(file.displayName)\" in Finder")
			}
			.disabled(file.url == nil)
		}
	}
	
	@ViewBuilder
	var removeItem: some View {
		if fileSelection.count > 1
				&& fileSelection.contains(file) {
			Button {
				remove(files: fileSelection)
				fileSelection = []
				updater.update()
			} label: {
				Text("Remove \(fileSelection.count) Files")
			}
		} else {
			Button {
				remove(files: [file])
				if fileSelection.contains(file) {
					fileSelection = []
				}
				updater.update()
			} label: {
				Text("Remove \"\(file.displayName)\"")
			}
		}
	}
}

// MARK:- Helper Functions
extension ImageCollectionItemContextMenu {
	func remove<C>(
		files: C
	) where C: Sequence,
					C.Element == File {
		files.forEach { file in
			viewContext.delete(file)
		}
		
		do {
			try viewContext.save()
		} catch {
			print("[WARNING] Could not save model: \(error)")
		}
	}
}

// MARK:- Previews
struct ImageCollectionItemContextMenu_Previews: PreviewProvider {
	static let file: File = {
		let context = PersistenceController.preview
			.container.viewContext
		
		let file = File(context: context)
		file.url = URL(
			fileURLWithPath: "/Users/Shared/example.txt"
		)
		return file
	}()
	
	@State static var fileSelection: Set = [file]
	
	static var previews: some View {
		ImageCollectionItemContextMenu(
			file: file,
			fileSelection: $fileSelection,
			updater: .constant(Updater())
		)
	}
}
