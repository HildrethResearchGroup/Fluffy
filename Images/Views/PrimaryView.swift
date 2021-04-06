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
		HSplitView {
			SidebarView(selection: $sidebarSelection)
				.frame(minWidth: 150, idealWidth: 200, maxWidth: .infinity)
			ImageCollectionView(selectedDirectories: sidebarSelection)
		}
	}
}

struct PrimaryView_Previews: PreviewProvider {
	static var root = PersistenceController
		.preview
		.container
		.viewContext
		.loadRootDirectory()
	
	static var previews: some View {
		PrimaryView()
			.environmentObject(root)
	}
}
