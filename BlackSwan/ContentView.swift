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
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else if store.isLoading {
                ProgressView()
                    .transition(.opacity)
            } else if store.isSubscribed {
                NavigationStack {
                    HomeView()
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))
            } else {
                OnboardingView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.snappy(duration: 0.4), value: hasCompletedConceptOnboarding)
        .animation(.snappy(duration: 0.4), value: store.isSubscribed)
        .animation(.easeInOut(duration: 0.25), value: store.isLoading)
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
