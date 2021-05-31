//
//  ModifierGestures.swift
//  Images
//
//  Created by Connor Barnes on 5/30/21.
//

import SwiftUI

extension View {
	func onShiftTapGesture(action: @escaping () -> Void) -> some View {
		let gesture = TapGesture()
			.modifiers(.shift)
			.onEnded(action)
		return self.gesture(gesture)
	}
	
	func onCommandTapGesture(action: @escaping () -> Void) -> some View {
		let gesture = TapGesture()
			.modifiers(.command)
			.onEnded(action)
		return self.gesture(gesture)
	}
}
