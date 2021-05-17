//
//  ManualUpdatableView.swift
//  Images
//
//  Created by Connor Barnes on 5/17/21.
//

import SwiftUI

struct ManualUpdatingView<Content: View>: View {
	let content: Content
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

struct Updater {
	fileprivate var _base = false
	mutating func update() {
		_base.toggle()
	}
}

extension View {
	func manualUpdater(_ updater: Binding<Updater>) -> some View {
		return ManualUpdatingView(content: self, updater: updater)
	}
}
