//
//  SidebarView.swift
//  Images
//
//  Created by Connor Barnes on 4/5/21.
//

import SwiftUI

struct SidebarView: View {
	@Binding var selection: Set<Directory>
	
	var body: some View {
		SidebarViewController(selection: $selection)
	}
}

struct SidebarView_Previews: PreviewProvider {
	@State static var selection: Set<Directory> = []
	
	static var previews: some View {
		SidebarView(selection: $selection)
	}
}
