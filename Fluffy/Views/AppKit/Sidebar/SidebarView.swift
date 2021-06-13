//
//  SidebarView.swift
//  Images
//
//  Created by Connor Barnes on 3/22/21.
//

import SwiftUI

struct SidebarViewController: NSViewControllerRepresentable {
	@Binding var selection: Set<NSManagedObjectID>
	
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
		
	}
}

// MARK:- Coordinator
extension SidebarViewController {
	class Coordinator: NSObject {
		var parent: SidebarViewController
	}
}

// MARK:- Previews
struct SidebarView_Previews: PreviewProvider {
	@State static var selection: Set<NSManagedObjectID> = []
	
	static var previews: some View {
		SidebarViewController(selection: $selection)
	}
}
