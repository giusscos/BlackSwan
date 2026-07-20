//
//  ConceptOnboardingView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 20/07/26.
//

import SwiftUI

struct ConceptOnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    private let pages: [ConceptPage] = [
        ConceptPage(
            title: "What is a Black Swan?",
            description: "A Black Swan is a rare, high-impact event that seems obvious only after it happens. You cannot predict the exact shock — but you can prepare for surprise.",
            systemImage: "bird.fill",
            accent: .primary
        ),
        ConceptPage(
            title: "Black Swan vs Deliberate",
            description: "Deliberate risks are choices you can see coming — a known trade-off. Black Swans are outliers: unexpected, severe, and hard to price in advance.",
            systemImage: "arrow.left.arrow.right",
            accent: .orange
        ),
        ConceptPage(
            title: "Limit the damage",
            description: "Build buffers, diversify exposure, stress-test plans, and keep optionality. Journaling shocks helps you spot fragile spots before the next surprise.",
            systemImage: "shield.lefthalf.filled",
            accent: .green
        ),
        ConceptPage(
            title: "How Black Swan helps",
            description: "Log events, get a plan, track mitigations, run pre-mortems, and watch your fragility score fall as you build buffers — privately on your device.",
            systemImage: "sparkles",
            accent: .blue
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    ConceptPageView(page: page)
                        .padding(.horizontal, 24)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            Button {
                if currentPage < pages.count - 1 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    hasCompletedOnboarding = true
                }
            } label: {
                Text(currentPage < pages.count - 1 ? "Continue" : "Get started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
            
            if currentPage < pages.count - 1 {
                Button("Skip") {
                    hasCompletedOnboarding = true
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 24)
            } else {
                Color.clear.frame(height: 44)
            }
        }
        .background {
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.secondarySystemBackground).opacity(0.6)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

private struct ConceptPage {
    let title: String
    let description: String
    let systemImage: String
    let accent: Color
}

private struct ConceptPageView: View {
    let page: ConceptPage
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 24)
            
            ZStack {
                Circle()
                    .fill(page.accent.opacity(0.12))
                    .frame(width: 140, height: 140)
                
                Image(systemName: page.systemImage)
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundStyle(page.accent)
                    .symbolRenderingMode(.hierarchical)
            }
            
            Text(page.title)
                .font(.title.bold())
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
            
            Spacer(minLength: 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ConceptOnboardingView(hasCompletedOnboarding: .constant(false))
}
