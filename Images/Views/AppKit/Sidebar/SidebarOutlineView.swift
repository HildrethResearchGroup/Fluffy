//
//  SidebarOutlineView.swift
//  Images
//
//  Created by Connor Barnes on 3/22/21.
//

import AppKit
import SwiftUI
import Combine

/// The AppKit view controller for the app's sidebar.
class SidebarOutlineViewController: NSViewController {
	/// The outline view.
	@IBOutlet weak var outlineView: NSOutlineView!
	
	/// The add button.
	@IBOutlet weak var addbutton: NSButton!
	
	/// The remove button.
	@IBOutlet weak var removeButton: NSButton!

	/// Called when the add button is pressed.
	/// - Parameter sender: The sender.
	@IBAction func addButtonPressed(_ sender: Any) {
		
	}
	
	/// Called when the remove button is pressed.
	/// - Parameter sender: The sender.
	@IBAction func removeButtonPressed(_ sender: Any) {
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		outlineView.registerForDraggedTypes([.directoryRowPasteboardType, .URL])
	}
}
