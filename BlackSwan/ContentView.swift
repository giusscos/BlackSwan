//
//  ContentView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 09/04/25.
//

import SwiftUI

struct ContentView: View {
    @State var store = Store()
    @State var currentIndex: Int = 0

    var body: some View {
        if store.isLoading {
            ProgressView()
        } else if !store.purchasedSubscriptions.isEmpty {
            NavigationStack {
                HomeView()
            }
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Swan.self, inMemory: true)
}
