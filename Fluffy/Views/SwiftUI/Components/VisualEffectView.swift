//
//  VisualEffectView.swift
//  Fluffy
//
//  Created by Connor Barnes on 2/20/21.
//

import SwiftUI

/// A view hosting an `NSVisualEffectView`.
struct VisualEffectView: NSViewRepresentable {
	/// A value indicating how the view’s contents blend with the surrounding content.
	var effect: NSVisualEffectView.BlendingMode
	/// The material shown by the visual effect view.
	var material: NSVisualEffectView.Material
	
	func makeNSView(context: NSViewRepresentableContext<Self>) -> NSVisualEffectView {
		NSVisualEffectView()
	}
	
	func updateNSView(
		_ nsView: NSVisualEffectView,
		context: NSViewRepresentableContext<Self>
	) {
		nsView.blendingMode = effect
		nsView.material = material
	}
}

// MARK:- Previews
struct VisualEffectView_Previews: PreviewProvider {
	static var previews: some View {
		VisualEffectView(effect: .behindWindow,
										 material: .sidebar)
	}
}

