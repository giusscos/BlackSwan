//
//  ContentView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 09/04/25.
//

import StoreKit
import SwiftUI

struct ContentView: View {
    @State private var store = Store()
    @AppStorage("hasCompletedConceptOnboarding") private var hasCompletedConceptOnboarding = false

    var body: some View {
        Group {
            if !hasCompletedConceptOnboarding {
                ConceptOnboardingView(hasCompletedOnboarding: $hasCompletedConceptOnboarding)
            } else if store.isLoading {
                ProgressView()
            } else if store.isSubscribed {
                NavigationStack {
                    HomeView()
                }
            } else {
                OnboardingView()
            }
        }
        .environment(store)
        .subscriptionStatusTask(for: Store.groupId) { taskState in
            if let statuses = taskState.value {
                store.updateFromSubscriptionStatuses(statuses)
            } else if case .failure = taskState {
                store.isLoading = false
                await store.refreshEntitlements()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Swan.self, inMemory: true)
}
