//
//  SidebarOutlineViewController.swift
//  Images
//
//  Created by Connor Barnes on 3/22/21.
//

import AppKit
import SwiftUI
import Combine

/// The AppKit view controller for the app's sidebar.
class SidebarOutlineViewController: NSViewController {
	weak var coordinator: SidebarViewController.Coordinator!
	
	/// The outline view.
	@IBOutlet weak var outlineView: NSOutlineView!
	
	/// The add button.
	@IBOutlet weak var addbutton: NSButton!
	
	/// The remove button.
	@IBOutlet weak var removeButton: NSButton!
	
	@IBAction func addNewDirectory(_ sender: Any?) {
		coordinator.addNewDirectory()
	}
	
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
