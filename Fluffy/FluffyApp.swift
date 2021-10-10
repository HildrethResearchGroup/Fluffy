//
//  FluffyApp.swift
//  Fluffy
//
//  Created by Connor Barnes on 2/20/21.
//

import SwiftUI

/// The Fluffy application.
@main
struct FluffyApp: App {
	/// The app's persistence controller, responsible for the app's CoreData store.
	private var persistenceController = PersistenceController.shared
    
    /// The app's selection manager.  It it responsible for the app's selection.
    private var selectionManager = SelectionManager()
	
	var body: some Scene {
		WindowGroup {
			PrimaryView()
				.environment(\.managedObjectContext,
										 persistenceController.container.viewContext)
                .environmentObject(selectionManager)
		}
		Settings {
			SettingsView()
				.navigationTitle("Preferences")
		}
	}
}
