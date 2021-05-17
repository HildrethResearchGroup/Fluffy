//
//  ManualUpdatableView.swift
//  Images
//
//  Created by Connor Barnes on 5/17/21.
//

import SwiftUI

/// A view that allows for manually updating its contents.
struct ManualUpdatingView<Content: View>: View {
	/// The view's content.
	let content: Content
	
	/// The view's updater.
	@Binding var updater: Updater
	
	var body: some View {
		if updater._base {
			ZStack {
				Text("")
				content
			}
		} else {
			ZStack {
				Text(" ")
				content
			}
		}
	}
}

// MARK:- Updater
/// A type for updating manual updatable views.
struct Updater {
	/// The base value, which is changed during an update.
	fileprivate var _base = false
	
	/// Updates the views connected to this updater.
	mutating func update() {
		_base.toggle()
	}
}

// MARK:- View Modifier
extension View {
	/// Forces the view to redraw when the given updater calls for an update.
	/// - Parameter updater: The updater.
	/// - Returns: A manual updatable view.
	func manualUpdater(_ updater: Binding<Updater>) -> some View {
		return ManualUpdatingView(content: self, updater: updater)
	}
}
