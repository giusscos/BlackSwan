//
//  OnboardingView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 11/04/25.
//

import SwiftUI
import StoreKit

struct OnboardingView: View {
    @State private var currentPage = 0
    
    private let pages = [
        OnboardingPage(
            title: "Add Your Events",
            description: "Tap the + button to add new events. Each event will be automatically analyzed.",
            systemImage: "plus.circle.fill"
        ),
        OnboardingPage(
            title: "Smart Classification",
            description: "Events are automatically classified as Black Swan or Deliberate using on-device machine learning.",
            systemImage: "brain.head.profile"
        ),
        OnboardingPage(
            title: "Customize Your Experience",
            description: "Personalize the app's appearance with different themes and colors.",
            systemImage: "paintpalette.fill"
        )
    ]
    
    var body: some View {
        SubscriptionStoreView(groupID: Store().groupId) {
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .padding()
                            .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
        .subscriptionStoreControlStyle(.compactPicker, placement: .automatic)
        .subscriptionStoreButtonLabel(.multiline)
        .storeButton(.visible, for: .restorePurchases)
        .subscriptionStorePolicyDestination(url: URL(string: "https://giusscos.it/privacy")!, for: .privacyPolicy)
        .subscriptionStorePolicyDestination(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!, for: .termsOfService)
        .tint(.primary)
        .interactiveDismissDisabled()
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let systemImage: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
        
    var body: some View {
        VStack(spacing: 24) {
            if page.systemImage == "AppIcon" {
                Image("appIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                Image(systemName: page.systemImage)
                    .font(.largeTitle)
            }
            
            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .frame(maxWidth: 400, alignment: .center)
    }
}

#Preview {
    OnboardingView()
}
