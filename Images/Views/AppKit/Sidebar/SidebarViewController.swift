//
//  SidebarViewController.swift
//  Images
//
//  Created by Connor Barnes on 3/22/21.
//

import SwiftUI

struct SidebarViewController {
	@Binding var selection: Set<Directory>
	@EnvironmentObject var rootDirectory: Directory
}

// MARK:- NSViewControllerRepresentable {
extension SidebarViewController: NSViewControllerRepresentable {
	typealias NSViewControllerType = SidebarOutlineViewController
	
	func makeNSViewController(context: Context) -> NSViewControllerType {
		let id = NSStoryboard.SceneIdentifier("sidebarViewController")
		
		let viewController = NSStoryboard
			.main!
			.instantiateController(identifier: id)
			as NSViewController?
			as! NSViewControllerType
		
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
		var parent: SidebarViewController
		var controller: SidebarOutlineViewController!
		
		init(_ sidebarViewController: SidebarViewController) {
			parent = sidebarViewController
		}
	}
}

// MARK:- Previews
struct SidebarViewController_Previews: PreviewProvider {
	@State static var selection: Set<Directory> = []
	
	static var previews: some View {
		SidebarViewController(selection: $selection)
	}
}
