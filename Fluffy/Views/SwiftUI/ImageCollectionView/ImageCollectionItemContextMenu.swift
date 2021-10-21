//
//  ImageCollectionItemContextMenu.swift
//  Fluffy
//
//  Created by Connor Barnes on 6/14/21.
//

import SwiftUI

/// The context menu to show when secondary clicking a file.
struct ImageCollectionItemContextMenu: View {
	/// The file that was clicked on.
	let file: File
	
	/// The files currently selected.
	//@Binding var fileSelection: Set<File>
    
    /// Manage the selection
    @EnvironmentObject var selectionManager: SelectionManager
    	
	/// A manual updater for updating the files to show.
	@Binding var updater: Updater
	
	/// The managed object context.
	@Environment(\.managedObjectContext) var viewContext
	
	var body: some View {
		showInFinderItem
		removeItem
	}
}

// MARK:- Menu Items
private extension ImageCollectionItemContextMenu {
	/// The show in Finder menu item.
	@ViewBuilder
	var showInFinderItem: some View {
        // Changed if fileSelection.count > 1
        if selectionManager.fileSelection.count > 1
				&& selectionManager.fileSelection.contains(file) {
			Button {
                selectionManager.fileSelection
					.compactMap(\.url)
					.showInFinder()
			} label: {
				Text("Show \(selectionManager.fileSelection.count) Files in Finder")
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
	
	/// The remove menu item.
	@ViewBuilder
	var removeItem: some View {
		if selectionManager.fileSelection.count > 1
				&& selectionManager.fileSelection.contains(file) {
			Button {
				remove(files: selectionManager.fileSelection)
                selectionManager.fileSelection = []
				updater.update()
			} label: {
				Text("Remove \(selectionManager.fileSelection.count) Files")
			}
		} else {
			Button {
				remove(files: [file])
				if selectionManager.fileSelection.contains(file) {
                    selectionManager.fileSelection = []
				}
				updater.update()
			} label: {
				Text("Remove \"\(file.displayName)\"")
			}
		}
	}
}

// MARK:- Helper Functions
private extension ImageCollectionItemContextMenu {
	/// Removes the given files.
	/// - Parameter files: The files to remove.
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



// MARK: - Previews
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
			//fileSelection: $fileSelection,
			updater: .constant(Updater())
		)
	}
}
