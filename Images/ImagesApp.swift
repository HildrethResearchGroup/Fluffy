//
//  ImagesApp.swift
//  Images
//
//  Created by Connor Barnes on 2/20/21.
//

import SwiftUI

/// The Images application.
@main
struct ImagesApp: App {
	/// The app's persistence controller, responsible for the app's CoreData store.
	private var persistenceController = PersistenceController.shared
	
	var body: some Scene {
		WindowGroup {
			PrimaryView()
				.environment(\.managedObjectContext,
										 persistenceController.container.viewContext)
		}
	}
}
