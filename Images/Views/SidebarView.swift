//
//  SidebarView.swift
//  Images
//
//  Created by Connor Barnes on 4/5/21.
//

import SwiftUI

struct SidebarView: View {
	@Binding var selection: Set<Directory>

	var rootDirectory = PersistenceController
		.shared
		.loadRootDirectory()
	
	var body: some View {
		switch rootDirectory {
		case .success(let root):
			SidebarViewController(rootDirectory: root,
														selection: $selection)
		case .failure(let error):
			ZStack {
				Image(systemName: "exclamationmark.triangle")
					.font(.largeTitle)
				VStack {
					Spacer()
					Text("Error: \(error.localizedDescription)")
						.font(.body)
				}
			}
			.padding()
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background(VisualEffectView(effect: .behindWindow))
		}
	}
}

struct SidebarView_Previews: PreviewProvider {
	@State static var selection: Set<Directory> = []
	
	static var previews: some View {
		SidebarView(selection: $selection)
	}
}
