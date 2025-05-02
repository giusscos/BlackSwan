//
//  OnboardingView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 11/04/25.
//

import SwiftUI
import StoreKit

struct OnboardingView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var currentPage = 0
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to BlackSwan",
            description: "A place where you can describe and get aware of unexpected events.",
            systemImage: "AppIcon"
        ),
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
        ),
        OnboardingPage(
            title: "Unlock Full Access",
            description: "Get unlimited access to all features with our flexible subscription plans.",
            systemImage: "lock.open.fill"
        )
    ]
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    if index == pages.count - 1 {
                        SubscriptionStoreView(groupID: Store().groupId)
                            .subscriptionStoreControlStyle(.compactPicker, placement: .automatic)
                            .subscriptionStoreButtonLabel(.multiline)
                            .storeButton(.visible, for: .restorePurchases)
                            .subscriptionStorePolicyDestination(url: URL(string: "https://giusscos.it/privacy")!, for: .privacyPolicy)
                            .subscriptionStorePolicyDestination(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!, for: .termsOfService)
                            .tint(.primary)
                            .padding(.vertical, 48)
                            .padding(.horizontal)
                            .tag(index)
                    } else {
                        OnboardingPageView(page: page)
                            .padding()
                            .tag(index)
                    }
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            if currentPage < pages.count - 1 {
                Button {
                    withAnimation {
                        if currentPage < pages.count - 1 {
                            currentPage += 1
                        }
                    }
                } label: {
                    Text(currentPage == pages.count - 2 ? "Get Started" : "Next")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(.background)
                .background(.primary)
                .clipShape(Capsule())
                .frame(maxWidth: 400, alignment: .center)
                .padding()
            }
        }
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
    
    @EnvironmentObject var themeManager: ThemeManager
    
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
                    .foregroundStyle(themeManager.gradient())
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
        .environmentObject(ThemeManager())
} 
