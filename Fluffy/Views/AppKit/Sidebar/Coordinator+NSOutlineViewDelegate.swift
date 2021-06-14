//
//  SidebarViewController+NSOutlineViewDelegate.swift
//  Fluffy
//
//  Created by Connor Barnes on 4/5/21.
//

import AppKit
import SwiftUI

// MARK:- NSOutlineViewDataSource
extension SidebarViewController.Coordinator: NSOutlineViewDataSource {
	func outlineView(
		_ outlineView: NSOutlineView,
		numberOfChildrenOfItem item: Any?
	) -> Int {
		guard let directory = directory(fromItem: item) else { return 0 }
		return directory.subdirectories.count
	}
	
	func outlineView(
		_ outlineView: NSOutlineView,
		child index: Int,
		ofItem item: Any?
	) -> Any {
		// TODO: Add better error handling than crashing.
		guard let directory = directory(fromItem: item) else {
			fatalError("Child of directory at the given index was nil.")
		}
		return directory.subdirectories[index]
	}
	
	func outlineView(
		_ outlineView: NSOutlineView,
		isItemExpandable item: Any
	) -> Bool {
		// TODO: Don't show disclosure for directories without subdirectories.
		return true
	}
}

// MARK:- NSOutlineViewDelegate
extension SidebarViewController.Coordinator: NSOutlineViewDelegate {
	func outlineView(
		_ outlineView: NSOutlineView,
		viewFor tableColumn: NSTableColumn?,
		item: Any
	) -> NSView? {
		guard let directory = directory(fromItem: item) else { return nil }
		
		let identifier = NSUserInterfaceItemIdentifier("SidebarFolderTableViewCell")
		let view = outlineView
			.makeView(withIdentifier: identifier, owner: nil)
			as? NSTableCellView
		
		view?.textField?.stringValue = directory.displayName
		
		return view
	}
	
	func outlineViewSelectionDidChange(_ notification: Notification) {
		guard let outlineView = notification.object as? NSOutlineView else {
			parent.selection = []
			return
		}
		
		parent.selection = Set(
			outlineView
				.selectedRowIndexes
				.compactMap { outlineView.item(atRow: $0) as? Directory }
		)
	}
}

// MARK:- Helper Functions
extension SidebarViewController.Coordinator {
	/// Converts an NSOutlineView item into a directory.
	/// - Parameter item: The item returned from an NSOutlineView.
	/// - Returns: The directory represented by the item.
	func directory(fromItem item: Any?) -> Directory? {
		// The top level item is given as nil by AppKit.
		guard let item = item else { return parent.rootDirectory }
		// Otherwise the item will be the row's directory.
		return item as? Directory
	}
	
	/// Removes the given directories from the sidebar and updates the model.
	/// - Parameter directories: The directories to remove.
	/// - Parameter outlineView: The outline view to update.
	func remove(
		directories: [Directory],
		inOutlineView outlineView: NSOutlineView
	) {
		// Multiple items may be removed, so put everything in an update block to improve performance
		outlineView.beginUpdates()
		directories.forEach { directory in
			let directoryParent = directory.parent
			let childIndex = outlineView.childIndex(forItem: directory)
			
			if let directoryParent = directoryParent {
				directory.parent = nil
				directoryParent.removeFromSubdirectories(directory)
			}
			
			guard directoryParent != nil else {
				print("[WARNING] Error finding parent for directory item to be removed.")
				return
			}
			guard childIndex != -1 else {
				print("[WARNING] Error finding child index for subdirectory to be removed.")
				return
			}
			
			// Top level directories are a member of the root directory. However,
			// NSOutlineView represents the item of the top level as nil, so if the
			// parent is the root directory, change it to nil.
			let sidebarParent =
				directoryParent == parent.rootDirectory ? nil : directoryParent
			
			outlineView.removeItems(at: IndexSet(integer: childIndex),
															inParent: sidebarParent,
															withAnimation: .slideDown)
		}
		outlineView.endUpdates()
	}
}
