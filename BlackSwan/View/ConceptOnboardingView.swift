//
//  ConceptOnboardingView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 20/07/26.
//

import SwiftUI

/// Four short screens before the paywall: the hook, what the person worries about,
/// the product working on their own kind of shock, then the outcome.
struct ConceptOnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool

    @AppStorage(FocusThemes.storageKey) private var focusThemesRaw = ""

    @State private var currentPage: Int
    @State private var selectedThemes: Set<RiskTheme> = []
    @State private var continueHaptic = false
    @State private var completeHaptic = false

    private let pageCount = 4
    
    init(hasCompletedOnboarding: Binding<Bool>, initialPage: Int = 0) {
        _hasCompletedOnboarding = hasCompletedOnboarding
        _currentPage = State(initialValue: initialPage)
    }

    private var isLastPage: Bool {
        currentPage == pageCount - 1
    }

    private var accent: Color {
        switch currentPage {
        case 1: .orange
        case 2: .red
        case 3: .green
        default: .primary
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.top, 12)
                .padding(.horizontal, 24)

            TabView(selection: $currentPage) {
                OnboardingPage { HookPage(isActive: currentPage == 0) }
                    .tag(0)
                OnboardingPage { ThemePickerPage(selection: $selectedThemes) }
                    .tag(1)
                OnboardingPage { DemoPage(event: FocusThemes.demoEvent(for: focusThemesRaw), isActive: currentPage == 2) }
                    .tag(2)
                OnboardingPage { OutcomePage(isActive: currentPage == 3) }
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.snappy(duration: 0.35), value: currentPage)

            Button {
                advance()
            } label: {
                Text(buttonTitle)
                    .font(.headline)
                    .foregroundStyle(Color(.systemBackground))
                    .frame(maxWidth: 432)
                    .frame(height: 56)
                    .background(Color(.label), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .contentTransition(.opacity)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 20)
            .sensoryFeedback(.impact(flexibility: .solid, intensity: 0.7), trigger: continueHaptic)
            .sensoryFeedback(.success, trigger: completeHaptic)
        }
        .background {
            ZStack {
                Color(.systemBackground)
                Circle()
                    .fill(accent.opacity(0.12))
                    .frame(width: 320, height: 320)
                    .blur(radius: 70)
                    .offset(x: 100, y: -220)
                Circle()
                    .fill(accent.opacity(0.08))
                    .frame(width: 240, height: 240)
                    .blur(radius: 60)
                    .offset(x: -120, y: 280)
            }
            .animation(.easeInOut(duration: 0.55), value: currentPage)
            .ignoresSafeArea()
        }
        .sensoryFeedback(.selection, trigger: currentPage)
        .onChange(of: selectedThemes) { _, newValue in
            focusThemesRaw = FocusThemes.encode(newValue)
        }
        .onAppear {
            selectedThemes = Set(FocusThemes.decode(focusThemesRaw))
        }
    }

    private var buttonTitle: LocalizedStringKey {
        switch currentPage {
        case 0: "Get started"
        case 1: selectedThemes.isEmpty ? LocalizedStringKey("Skip for now") : LocalizedStringKey("Continue")
        case 2: "Show me the result"
        default: "Continue"
        }
    }

    private var topBar: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(0..<pageCount, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentPage ? Color.primary : Color.secondary.opacity(0.25))
                        .frame(width: index == currentPage ? 24 : 8, height: 6)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Page \(currentPage + 1) of \(pageCount)")

            Spacer()

            Button("Skip") {
                complete()
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .opacity(isLastPage ? 0 : 1)
            .disabled(isLastPage)
        }
        .frame(height: 32)
    }

    private func advance() {
        if isLastPage {
            complete()
        } else {
            continueHaptic.toggle()
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                currentPage += 1
            }
        }
    }

    private func complete() {
        completeHaptic.toggle()
        withAnimation(.easeInOut(duration: 0.25)) {
            hasCompletedOnboarding = true
        }
    }
}

/// Centers a page vertically and scrolls on short screens (landscape, small iPhones).
private struct OnboardingPage<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                content
                    .frame(maxWidth: 480)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
        }
    }
}

private struct PageTitle: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Text(subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - 1. Hook

private struct HookPage: View {
    let isActive: Bool

    @State private var appeared = false

    private let shocks: [(icon: String, text: LocalizedStringKey, angle: Double, x: CGFloat)] = [
        ("briefcase.fill", "Biggest client cancelled", -4, -12),
        ("cross.case.fill", "Surprise $2,400 hospital bill", 3, 10),
        ("chart.line.downtrend.xyaxis", "Market dropped 18% overnight", -2, -6)
    ]

    var body: some View {
        VStack(spacing: 36) {
            VStack(spacing: 12) {
                ForEach(Array(shocks.enumerated()), id: \.offset) { index, shock in
                    HStack(spacing: 10) {
                        Image(systemName: shock.icon)
                            .foregroundStyle(.red)
                        Text(shock.text)
                            .font(.subheadline.weight(.semibold))
                        Text("Black Swan")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color(.systemBackground))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.label), in: Capsule())
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
                    .rotationEffect(.degrees(shock.angle))
                    .offset(x: shock.x)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 24)
                    .animation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.1 + Double(index) * 0.12), value: appeared)
                }
            }

            PageTitle(
                title: "Life doesn't send a warning",
                subtitle: "You can't predict the next shock. You can be ready for it. Black Swan helps you spot where you're fragile and protect yourself before it hits."
            )
        }
        .onAppear { appeared = isActive }
        .onChange(of: isActive) { _, active in if active { appeared = true } }
    }
}

// MARK: - 2. Personalize

private struct ThemePickerPage: View {
    @Binding var selection: Set<RiskTheme>

    var body: some View {
        VStack(spacing: 28) {
            PageTitle(
                title: "What feels fragile right now?",
                subtitle: "Pick everything that applies. We'll focus your plan there."
            )

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(FocusThemes.choices) { theme in
                    let isSelected = selection.contains(theme)
                    Button {
                        if isSelected {
                            selection.remove(theme)
                        } else {
                            selection.insert(theme)
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: theme.systemImage)
                                    .font(.title2)
                                    .foregroundStyle(isSelected ? Color(.systemBackground) : .primary)
                                Spacer()
                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(isSelected ? Color(.systemBackground) : .secondary)
                                    .contentTransition(.symbolEffect(.replace))
                            }
                            Text(theme.displayString)
                                .font(.headline)
                                .foregroundStyle(isSelected ? Color(.systemBackground) : .primary)
                            Text(themeDetail(theme))
                                .font(.caption)
                                .foregroundStyle(isSelected ? Color(.systemBackground).opacity(0.75) : .secondary)
                                .lineLimit(2, reservesSpace: true)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            isSelected ? AnyShapeStyle(Color(.label)) : AnyShapeStyle(.regularMaterial),
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        )
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.selection, trigger: isSelected)
                    .animation(.snappy(duration: 0.2), value: isSelected)
                }
            }
        }
    }

    private func themeDetail(_ theme: RiskTheme) -> LocalizedStringKey {
        switch theme {
        case .money: "Savings, debt, investments"
        case .work: "Income, clients, your job"
        case .health: "Injuries, bills, burnout"
        case .relationships: "Family, partner, home"
        case .other: ""
        }
    }
}

// MARK: - 3. Demo

private struct DemoPage: View {
    let event: DemoEvent
    let isActive: Bool

    @State private var step = 0

    var body: some View {
        VStack(spacing: 28) {
            PageTitle(
                title: "Turn a shock into a plan",
                subtitle: "Write what happened. Black Swan classifies it on your device and suggests how to protect yourself next time."
            )

            VStack(alignment: .leading, spacing: 14) {
                Text(event.text)
                    .font(.body.weight(.medium))
                    .fixedSize(horizontal: false, vertical: true)

                if step >= 1 {
                    HStack(spacing: 8) {
                        Label("Black Swan", systemImage: "bird.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color(.systemBackground))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color(.label), in: Capsule())
                        Text("\(event.confidence)% confident")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                }

                if step >= 2 {
                    Divider()
                    Text("Your protections")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    ForEach(Array(event.mitigations.enumerated()), id: \.offset) { index, item in
                        HStack(spacing: 10) {
                            Image(systemName: step >= 3 + index ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(step >= 3 + index ? .green : .secondary)
                                .contentTransition(.symbolEffect(.replace))
                            Text(item)
                                .font(.subheadline)
                                .strikethrough(step >= 3 + index, color: .secondary)
                                .foregroundStyle(step >= 3 + index ? .secondary : .primary)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 20, y: 10)
            .sensoryFeedback(.impact(weight: .light), trigger: step)

            HStack(spacing: 16) {
                legend(color: .primary, title: "Black Swan", detail: "Rare, severe, unexpected")
                legend(color: .orange, title: "Deliberate", detail: "A risk you chose")
            }
        }
        .task(id: isActive) {
            guard isActive else { return }
            step = 0
            for next in 1...(2 + event.mitigations.count) {
                try? await Task.sleep(for: .milliseconds(next == 1 ? 600 : 700))
                guard !Task.isCancelled else { return }
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    step = next
                }
            }
        }
    }

    private func legend(color: Color, title: LocalizedStringKey, detail: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .padding(.top, 5)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption.weight(.semibold))
                Text(detail)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 4. Outcome

private struct OutcomePage: View {
    let isActive: Bool

    @State private var score = 72
    @State private var progress = 0.72

    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 16)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(scoreColor.gradient, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 2) {
                    Text("\(score)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .contentTransition(.numericText(value: Double(score)))
                    Text("Fragility")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 190, height: 190)

            PageTitle(
                title: "Watch your fragility fall",
                subtitle: "Every protection you finish lowers your score. A weekly review keeps the habit going."
            )

            VStack(alignment: .leading, spacing: 12) {
                row(icon: "calendar", title: "Weekly review", detail: "Five minutes on wins, open actions and one focus")
                row(icon: "shield.lefthalf.filled", title: "Pre-mortems", detail: "Imagine the worst case and build buffers early")
                row(icon: "lock.fill", title: "Private by design", detail: "No account. Everything stays on your iPhone")
            }
        }
        .task(id: isActive) {
            guard isActive else { return }
            score = 72
            progress = 0.72
            try? await Task.sleep(for: .milliseconds(400))
            withAnimation(.easeInOut(duration: 1.6)) {
                score = 38
                progress = 0.38
            }
        }
    }

    private var scoreColor: Color {
        score > 55 ? .red : .green
    }

    private func row(icon: String, title: LocalizedStringKey, detail: LocalizedStringKey) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .frame(width: 36, height: 36)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ConceptOnboardingView(hasCompletedOnboarding: .constant(false))
}
