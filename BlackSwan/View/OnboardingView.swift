//
//  OnboardingView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 11/04/25.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var isPresented: Bool
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
        )
    ]
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            Button {
                if currentPage < pages.count - 1 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    isPresented = false
                }
            } label: {
                Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(.background)
            .background(.primary)
            .clipShape(Capsule())
        }
        .padding()
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
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
        .environmentObject(ThemeManager())
} 
