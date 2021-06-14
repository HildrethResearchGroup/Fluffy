//
//  SidebarViewController.swift
//  Fluffy
//
//  Created by Connor Barnes on 3/22/21.
//

import SwiftUI

/// The view controller for managing the app's sidebar.
struct SidebarViewController {
	/// The app's root directory.
	var rootDirectory: Directory
	
	/// The currently selected directories.
	@Binding var selection: Set<Directory>
	
	/// An updater instance.
	///
	/// Used for manually updating parent views when dragging in new files.
	@Binding var updater: Updater
	
	/// The Core Data view context.
	@Environment(\.managedObjectContext) var viewContext
}

// MARK:- NSViewControllerRepresentable {
extension SidebarViewController: NSViewControllerRepresentable {
	// This is a workaround to force the sidebar to update when the inspector
	// changes the name of a directory.
	/// The current controller.
	static var currentController: SidebarOutlineViewController! = nil
	
	typealias NSViewControllerType = SidebarOutlineViewController
	
	func makeNSViewController(context: Context) -> NSViewControllerType {
		let id = NSStoryboard.SceneIdentifier("sidebarViewController")
		
		let viewController = NSStoryboard
			.main!
			.instantiateController(identifier: id)
			as NSViewController?
			as! NSViewControllerType
		
		viewController.coordinator = context.coordinator
		
		context.coordinator.controller = viewController
		
		SidebarViewController.currentController = viewController
		return viewController
	}
	
	func updateNSViewController(
		_ nsViewController: NSViewControllerType,
		context: Context
	) {
		guard let outlineView = nsViewController.outlineView else {
			return
		}
		
		outlineView.dataSource = context.coordinator
		outlineView.delegate = context.coordinator
	}
	
	func makeCoordinator() -> Coordinator {
		return Coordinator(self)
	}
}

// MARK:- Coordinator
extension SidebarViewController {
	final class Coordinator: NSObject {
		/// The view controller owning the coordinator.
		var parent: SidebarViewController
		/// The AppKit view controller.
		var controller: SidebarOutlineViewController!
		
		/// Creates a coordinator from a parent `SidebarViewController`
		/// - Parameter sidebarViewController: The parent.
		init(_ sidebarViewController: SidebarViewController) {
			parent = sidebarViewController
		}
	}
}

// MARK:- Previews
struct SidebarViewController_Previews: PreviewProvider {
	@State static var selection: Set<Directory> = []
	@State static var updater = Updater()
	static let rootDirectory = try! PersistenceController
		.preview
		.loadRootDirectory()
		.get()
	
	static var previews: some View {
		SidebarViewController(rootDirectory: rootDirectory,
													selection: $selection,
													updater: $updater)
	}
}
