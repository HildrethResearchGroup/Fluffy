//
//  VisualEffectView.swift
//  Images
//
//  Created by Connor Barnes on 2/20/21.
//

import SwiftUI

struct VisualEffectView: NSViewRepresentable {
	var effect: NSVisualEffectView.BlendingMode
	var material: NSVisualEffectView.Material
	
	func makeNSView(context: NSViewRepresentableContext<Self>) -> NSVisualEffectView {
		NSVisualEffectView()
	}
	
	func updateNSView(_ nsView: NSVisualEffectView, context: NSViewRepresentableContext<Self>) { nsView.blendingMode = effect
		nsView.material = material
	}
}

struct VisualEffectView_Previews: PreviewProvider {
	static var previews: some View {
		VisualEffectView(effect: .behindWindow,
										 material: .sidebar)
	}
}

