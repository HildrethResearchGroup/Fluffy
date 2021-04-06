//
//  ImagesApp.swift
//  Images
//
//  Created by Connor Barnes on 2/20/21.
//

import SwiftUI

@main
struct ImagesApp: App {
	private var persistenceController = PersistenceController.shared
	
	@StateObject var rootDirectory = PersistenceController.shared.container.viewContext.loadRootDirectory()
	
	var body: some Scene {
		WindowGroup {
			PrimaryView()
				.environment(\.managedObjectContext,
										 persistenceController.container.viewContext)
				.environmentObject(rootDirectory)
		}
	}
}
