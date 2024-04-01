//
//  casinoApp.swift
//  casino
//
//  Created by Sudharsan on 26/08/24.
//

import SwiftUI

@main
struct casinoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
