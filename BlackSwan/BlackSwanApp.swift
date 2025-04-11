//
//  BlackSwanApp.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 09/04/25.
//

import SwiftUI
import SwiftData

@main
struct BlackSwanApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Swan.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear() {
                    UITextField.appearance().clearButtonMode = .whileEditing
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
