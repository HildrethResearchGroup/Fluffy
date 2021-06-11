//
//  Coordinator+FirstResponder.swift
//  Images
//
//  Created by Connor Barnes on 6/10/21.
//

import Cocoa

extension SidebarViewController.Coordinator {
	func addNewDirectory() {
		let parentDirectory = insertionDirectory()
		
		let newDirectory = Directory(context: parent.viewContext)
		newDirectory.customName = "New Directory"
		parentDirectory.addToSubdirectories(newDirectory)
		
		do {
			try parent.viewContext.save()
		} catch {
			print("[WARNING] Could not save context: \(error)")
		}
		
		let outlineView = controller.outlineView!
		
		// The item is being inserted at the end of the list of children. NSOutlineView.insertItems(at:inParent:withAnimation) takes the parent item to add the new item inside of. In this case, this is the parent directory which was calculated above. It also takes the child index to add the item to - this is simply the index of the (just added) last child subdirectory.
		let endIndex = IndexSet(
			integer: parentDirectory.subdirectories.count - 1
		)
		// Top level directories are a member of the root directory. However, NSOutlineView represents the item of the top level as nil, so if the parent is the root directory, change it to nil.
		let sidebarParent = parentDirectory == parent.rootDirectory
			? nil
			: parentDirectory
		
		outlineView.insertItems(at: endIndex,
														inParent: sidebarParent,
														withAnimation: .slideUp)
		// Items are collapsed by default, but should be expanded if an item has just been added to it.
		outlineView.animator().expandItem(parentDirectory)
		
		// Get the view for the newly inserted row so we can begin editing its textfield
		let view = outlineView.view(
			atColumn: 0,
			row: outlineView.row(forItem: newDirectory),
			makeIfNecessary: true
		) as? NSTableCellView
		
		view?.textField?.becomeFirstResponder()
	}
	
	func removeSelectedDirectories() {
		let outlineView = controller.outlineView!
		let selection = outlineView.selectedRowIndexes
		guard !selection.isEmpty else { return }
		let selectedDirectories = selection.compactMap { row in
			// This should never return nil (all items in the sidebar should
			// be directories) however if it does, skip over it, and it will be
			// noted as an error in the following guard statement (we can't
			// break out of a map)
			return outlineView.item(atRow: row) as? Directory
		}
		
		guard selectedDirectories.count == selection.count else {
			print("NSOutlineView inconstancy: could not map all rows to directories")
			return
		}
		
		// Multiple items may be removed, so put everything in an update block to improve performance
		outlineView.beginUpdates()
		selectedDirectories.forEach { directory in
			let parentDirectory = directory.parent
			let childIndex = outlineView.childIndex(forItem: directory)
			parent.viewContext.delete(directory)
			
			guard parentDirectory != nil else {
				print("[WARNING] Error finding parent for directory item to be removed.")
				return
			}
			guard childIndex != -1 else {
				print("[WARNING] Error finding child index for subdirectory to be removed.")
				return
			}
			
			// Top level directories are a member of the root directory. However, NSOutlineView represents the item of the top level as nil, so if the parent is the root directory, change it to nil.
			let outlineViewParent = parentDirectory == parent.rootDirectory
				? nil
				: parent
			
			outlineView.removeItems(at: IndexSet(integer: childIndex),
															inParent: outlineViewParent,
															withAnimation: .slideDown)
		}
		outlineView.endUpdates()
		
		do {
			try parent.viewContext.save()
		} catch {
			print("[WARNING] Failed to save context: \(error)")
		}
	}
}

// MARK: Helper Functions
extension SidebarViewController.Coordinator {
	func insertionDirectory() -> Directory {
		let outlineView = controller.outlineView!
		
		switch outlineView.numberOfSelectedRows {
		case 0:
			// If no cell is selected, place the new directory in the root
			// directory.
			return parent.rootDirectory
		default:
			// If one or multiple cells are selected, place the new directory
			// in the last cell's directory.
			let selectedItem = outlineView.item(
				atRow: outlineView.selectedRowIndexes.last!
			)
			return directory(fromItem: selectedItem)!
		}
	}
}
