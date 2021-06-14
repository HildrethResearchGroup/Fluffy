//
//  SidebarOutlineViewController.swift
//  Fluffy
//
//  Created by Connor Barnes on 3/22/21.
//

import AppKit
import SwiftUI
import Combine

/// The AppKit view controller for the app's sidebar.
class SidebarOutlineViewController: NSViewController {
	/// The view controller's SwiftUI coordinator.
	weak var coordinator: SidebarViewController.Coordinator!
	
	/// The outline view.
	@IBOutlet weak var outlineView: NSOutlineView!
	
	/// The add button.
	@IBOutlet weak var addButton: NSButton!
	
	/// The remove button.
	@IBOutlet weak var removeButton: NSButton!
	
	/// Called when the add button is pressed.
	@IBAction func addNewDirectory(_ sender: Any?) {
		coordinator.addNewDirectory()
	}
	
	/// Called when the remove button is pressed.
	@IBAction func removeSelectedDirectories(_ sender: Any?) {
		coordinator.removeSelectedDirectories()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		outlineView.registerForDraggedTypes(
			[.directoryRowPasteboardType, .URL]
		)
	}
}
