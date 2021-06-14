//
//  GestureViewModifiers.swift
//  Fluffy
//
//  Created by Connor Barnes on 5/30/21.
//

import SwiftUI

extension View {
	/// Adds an action to perform when this view recognizes a tap gesture while the shift key is being held.
	/// - Parameter action: The action to perform.
	func onShiftTapGesture(action: @escaping () -> Void) -> some View {
		let gesture = TapGesture()
			.modifiers(.shift)
			.onEnded(action)
		return self.gesture(gesture)
	}
	
	/// Adds an action to perform when this view recognizes a tap gesture while the command key is being held.
	/// - Parameter action: The action to perform.
	func onCommandTapGesture(action: @escaping () -> Void) -> some View {
		let gesture = TapGesture()
			.modifiers(.command)
			.onEnded(action)
		return self.gesture(gesture)
	}
}
