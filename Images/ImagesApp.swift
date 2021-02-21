//
//  ImagesApp.swift
//  Images
//
//  Created by Connor Barnes on 2/20/21.
//

import SwiftUI

@main
struct ImagesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
