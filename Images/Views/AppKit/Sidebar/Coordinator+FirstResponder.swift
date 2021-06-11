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
