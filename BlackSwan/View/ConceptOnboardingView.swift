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
    @State private var contentVisible = false
    @State private var iconBounce = 0
    @State private var continuePulse = false
    @State private var pageHaptic = 0
    @State private var continueHaptic = false
    @State private var completeHaptic = false
    
    private let pages: [ConceptPage] = [
        ConceptPage(
            title: "What is a Black Swan?",
            description: "A rare, high-impact event that seems obvious only after it happens. You cannot predict the exact shock — but you can prepare for surprise.",
            systemImage: "bird.fill",
            accent: .primary,
            highlights: []
        ),
        ConceptPage(
            title: "Black Swan vs Deliberate",
            description: "Deliberate risks are choices you can see coming. Black Swans are outliers: unexpected, severe, and hard to price in advance.",
            systemImage: "arrow.left.arrow.right",
            accent: .orange,
            highlights: [
                ConceptHighlight(icon: "exclamationmark.triangle.fill", label: "Black Swan", detail: "Unexpected shock"),
                ConceptHighlight(icon: "hand.raised.fill", label: "Deliberate", detail: "Known trade-off")
            ]
        ),
        ConceptPage(
            title: "Limit the damage",
            description: "Build buffers, diversify exposure, and keep optionality. Journaling shocks helps you spot fragile spots before the next surprise.",
            systemImage: "shield.lefthalf.filled",
            accent: .green,
            highlights: [
                ConceptHighlight(icon: "checkmark.shield.fill", label: "Buffers", detail: "Absorb the hit"),
                ConceptHighlight(icon: "arrow.triangle.branch", label: "Optionality", detail: "Keep exits open")
            ]
        ),
        ConceptPage(
            title: "How Black Swan helps",
            description: "Log shocks, track mitigations, run pre-mortems, and watch your fragility fall — privately on your device.",
            systemImage: "sparkles",
            accent: .blue,
            highlights: [
                ConceptHighlight(icon: "chart.line.uptrend.xyaxis", label: "Fragility score", detail: "See weak spots"),
                ConceptHighlight(icon: "calendar.badge.clock", label: "Weekly review", detail: "Build the ritual"),
                ConceptHighlight(icon: "shield.lefthalf.filled", label: "Pre-mortems", detail: "Plan before impact"),
                ConceptHighlight(icon: "checklist", label: "Mitigations", detail: "Mark protections done")
            ]
        )
    ]
    
    private var isLastPage: Bool {
        currentPage == pages.count - 1
    }
    
    var body: some View {
        VStack(spacing: 0) {
            progressDots
                .padding(.top, 12)
                .padding(.bottom, 8)
            
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    ConceptPageView(
                        page: page,
                        isActive: currentPage == index,
                        contentVisible: contentVisible && currentPage == index,
                        iconBounce: iconBounce
                    )
                    .padding(.horizontal, 24)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.snappy(duration: 0.35), value: currentPage)
            
            VStack(spacing: 12) {
                Button {
                    advance()
                } label: {
                    Text(isLastPage ? "Get started" : "Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .scaleEffect(continuePulse ? 1.02 : 1)
                }
                .buttonStyle(.borderedProminent)
                .sensoryFeedback(.impact(flexibility: .solid, intensity: 0.7), trigger: continueHaptic)
                .sensoryFeedback(.success, trigger: completeHaptic)
                
            if !isLastPage {
                Button("Skip") {
                    complete()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .sensoryFeedback(.selection, trigger: completeHaptic)
            } else {
                Color.clear.frame(height: 20)
            }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
            .opacity(contentVisible ? 1 : 0)
            .offset(y: contentVisible ? 0 : 16)
        }
        .background {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        pages[currentPage].accent.opacity(0.08),
                        Color(.secondarySystemBackground).opacity(0.7)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                Circle()
                    .fill(pages[currentPage].accent.opacity(0.12))
                    .frame(width: 280, height: 280)
                    .blur(radius: 60)
                    .offset(x: 90, y: -180)
                    .animation(.easeInOut(duration: 0.55), value: currentPage)
                
                Circle()
                    .fill(pages[currentPage].accent.opacity(0.08))
                    .frame(width: 220, height: 220)
                    .blur(radius: 50)
                    .offset(x: -110, y: 260)
                    .animation(.easeInOut(duration: 0.55), value: currentPage)
            }
            .ignoresSafeArea()
        }
        .sensoryFeedback(.selection, trigger: pageHaptic)
        .onAppear {
            animatePageEntry()
        }
        .onChange(of: currentPage) { _, _ in
            pageHaptic += 1
            animatePageEntry()
        }
    }
    
    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? pages[currentPage].accent : Color.secondary.opacity(0.25))
                    .frame(width: index == currentPage ? 28 : 8, height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(currentPage + 1) of \(pages.count)")
    }
    
    private func advance() {
        if isLastPage {
            complete()
        } else {
            continueHaptic.toggle()
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                currentPage += 1
            }
            pulseContinue()
        }
    }
    
    private func complete() {
        completeHaptic.toggle()
        withAnimation(.easeInOut(duration: 0.25)) {
            hasCompletedOnboarding = true
        }
    }
    
    private func animatePageEntry() {
        contentVisible = false
        withAnimation(.spring(response: 0.5, dampingFraction: 0.82).delay(0.05)) {
            contentVisible = true
        }
        iconBounce += 1
        pulseContinue()
    }
    
    private func pulseContinue() {
        withAnimation(.easeInOut(duration: 0.9).repeatCount(1, autoreverses: true)) {
            continuePulse = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
            continuePulse = false
        }
    }
}

private struct ConceptPage {
    let title: String
    let description: String
    let systemImage: String
    let accent: Color
    let highlights: [ConceptHighlight]
}

private struct ConceptHighlight: Identifiable {
    var id: String { label }
    let icon: String
    let label: String
    let detail: String
}

private struct ConceptPageView: View {
    let page: ConceptPage
    let isActive: Bool
    let contentVisible: Bool
    let iconBounce: Int
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 12)
            
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 148, height: 148)
                    .overlay {
                        Circle()
                            .strokeBorder(page.accent.opacity(0.2), lineWidth: 1)
                    }
                    .shadow(color: page.accent.opacity(0.18), radius: 24, y: 10)
                    .scaleEffect(contentVisible ? 1 : 0.82)
                    .opacity(contentVisible ? 1 : 0)
                
                Circle()
                    .fill(page.accent.opacity(0.14))
                    .frame(width: 112, height: 112)
                    .scaleEffect(contentVisible ? 1 : 0.7)
                
                Image(systemName: page.systemImage)
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(page.accent)
                    .symbolRenderingMode(.hierarchical)
                    .symbolEffect(.bounce, value: iconBounce)
                    .scaleEffect(contentVisible ? 1 : 0.6)
                    .opacity(contentVisible ? 1 : 0)
            }
            .animation(.spring(response: 0.55, dampingFraction: 0.75), value: contentVisible)
            
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .opacity(contentVisible ? 1 : 0)
                    .offset(y: contentVisible ? 0 : 14)
                
                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 360)
                    .opacity(contentVisible ? 1 : 0)
                    .offset(y: contentVisible ? 0 : 18)
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.84).delay(0.06), value: contentVisible)
            
            if !page.highlights.isEmpty {
                VStack(spacing: 10) {
                    ForEach(Array(page.highlights.enumerated()), id: \.element.id) { index, highlight in
                        HighlightChip(highlight: highlight, accent: page.accent)
                            .opacity(contentVisible ? 1 : 0)
                            .offset(y: contentVisible ? 0 : 12)
                            .animation(
                                .spring(response: 0.48, dampingFraction: 0.82)
                                    .delay(0.12 + Double(index) * 0.06),
                                value: contentVisible
                            )
                    }
                }
                .padding(.top, 4)
            }
            
            Spacer(minLength: 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct HighlightChip: View {
    let highlight: ConceptHighlight
    let accent: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: highlight.icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(accent)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(highlight.label)
                    .font(.subheadline.weight(.semibold))
                
                Text(highlight.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(accent.opacity(0.12), lineWidth: 1)
        }
    }
}

#Preview {
    ConceptOnboardingView(hasCompletedOnboarding: .constant(false))
}
