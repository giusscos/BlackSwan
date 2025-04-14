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
    // Create the ThemeManager as a StateObject
    @StateObject private var themeManager = ThemeManager()
    
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
                // Inject the ThemeManager into the environment
                .environmentObject(themeManager)
                .onAppear() {
                    UITextField.appearance().clearButtonMode = .whileEditing
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
