//
//  PrimaryView.swift
//  Images
//
//  Created by Connor Barnes on 2/20/21.
//

import SwiftUI

struct PrimaryView: View {
	@Environment(\.managedObjectContext) private var viewContext
	@EnvironmentObject var rootDirectory: Directory
	@State private var sidebarSelection: Set<Directory> = []
	
	var body: some View {
		NavigationView {
			SidebarView(selection: $sidebarSelection)
				.frame(minWidth: 150, idealWidth: 300, maxWidth: .infinity)
			ImageCollectionView(selectedDirectories: sidebarSelection)
		}
		.toolbar {
			ToolbarItemGroup(placement: .navigation) {
				Button {
					NSApp
						.keyWindow?
						.firstResponder?
						.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)),
													with: nil)
				} label: {
					Image(systemName: "sidebar.left")
				}
				
				Spacer()
			}
		}
	}
}

struct PrimaryView_Previews: PreviewProvider {
	static var previews: some View {
		PrimaryView()
	}
}
