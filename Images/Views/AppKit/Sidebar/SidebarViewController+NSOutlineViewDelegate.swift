//
//  SidebarViewController+NSOutlineViewDelegate.swift
//  Images
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
		
		view?.textField?.stringValue = directory.name
		
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
private extension SidebarViewController.Coordinator {
	func directory(fromItem item: Any?) -> Directory? {
		// The top level item is given as nil by AppKit.
		guard let item = item else { return parent.rootDirectory }
		// Otherwise the item will be the row's directory.
		return item as? Directory
	}
}
