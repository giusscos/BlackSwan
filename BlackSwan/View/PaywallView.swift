//
//  PaywallView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 16/10/26.
//

import StoreKit
import SwiftUI

/// Subscription paywall shown after onboarding when the user has no entitlement.
struct PaywallView: View {
    @Environment(Store.self) private var store
    /// Keeps the paywall on screen while a purchase finishes, so the welcome screen can show
    /// before ContentView swaps to Home.
    @Binding var isHoldingPaywall: Bool

    @AppStorage(FocusThemes.storageKey) private var focusThemesRaw = ""

    @State private var selectedProductID = Store.yearlyID
    @State private var remindBeforeTrialEnds = true
    @State private var didUnlock = false
    @State private var appeared = false

    private var selectedProduct: Product? {
        store.subscriptions.first { $0.id == selectedProductID } ?? store.subscriptions.first
    }

    private var selectedTrial: String? {
        guard let product = selectedProduct, store.hasEligibleTrial(product) else { return nil }
        return product.freeTrialText
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            if didUnlock {
                PaywallWelcomeView {
                    UserDefaults.standard.set(true, forKey: HomeView.openAddEventKey)
                    isHoldingPaywall = false
                }
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else {
                content
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: didUnlock)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.82).delay(0.05)) {
                appeared = true
            }
        }
        .task {
            if store.subscriptions.isEmpty {
                await store.requestProducts()
            }
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 28) {
                header

                if let selectedTrial, let product = selectedProduct {
                    TrialTimeline(trial: selectedTrial, priceText: product.pricePerPeriodText)
                }

                benefits

                footer
            }
            .frame(maxWidth: 480)
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        // Pinned so the purchase button is always visible without scrolling.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            callToAction
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 14) {
            Image("appIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 14, y: 8)
                .scaleEffect(appeared ? 1 : 0.85)

            Text(FocusThemes.paywallHeadline(for: focusThemesRaw))
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text("Unlock every tool that turns shocks into protection.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 14)
    }

    // MARK: - Benefits

    private var benefits: some View {
        VStack(alignment: .leading, spacing: 14) {
            PaywallBenefit(icon: "bird.fill", tint: .primary, title: "Spot every Black Swan", detail: "On-device classification with a confidence score")
            PaywallBenefit(icon: "checklist", tint: .green, title: "A plan for every shock", detail: "Mitigations you can actually tick off")
            PaywallBenefit(icon: "chart.line.downtrend.xyaxis", tint: .orange, title: "Watch fragility fall", detail: "Fragility score, themes and a weekly review")
            PaywallBenefit(icon: "shield.lefthalf.filled", tint: .blue, title: "Plan before the hit", detail: "Pre-mortems with buffer checklists")
            PaywallBenefit(icon: "lock.fill", tint: .secondary, title: "Private by design", detail: "No account. Your notes never leave your device")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 18)
    }

    // MARK: - Plans

    @ViewBuilder
    private var plans: some View {
        if store.subscriptions.isEmpty {
            VStack(spacing: 10) {
                ForEach(0..<2, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                        .frame(height: 58)
                }
            }
            .redacted(reason: .placeholder)
        } else {
            VStack(spacing: 8) {
                ForEach(store.subscriptions) { product in
                    planCard(product)
                }
            }
        }
    }

    private func planCard(_ product: Product) -> some View {
        let isSelected = product.id == selectedProduct?.id

        return Button {
            selectedProductID = product.id
        } label: {
            HStack(spacing: 14) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color(.label) : Color.secondary.opacity(0.5))
                    .contentTransition(.symbolEffect(.replace))

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(planName(for: product))
                            .font(.headline)

                        if let trial = store.hasEligibleTrial(product) ? product.freeTrialText : nil {
                            PlanBadge(text: String(localized: "\(trial) free").uppercased(), color: .green)
                        } else if let savings = savingsPercent(for: product) {
                            PlanBadge(text: String(localized: "Save \(savings)%").uppercased(), color: .orange)
                        }
                    }

                    Text(planSubtitle(for: product))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Spacer(minLength: 8)

                Text(product.displayPrice)
                    .font(.headline)
                    .monospacedDigit()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isSelected ? Color(.label) : .clear, lineWidth: 2)
            }
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selectedProductID)
        .animation(.snappy(duration: 0.2), value: selectedProductID)
    }

    private func planName(for product: Product) -> String {
        switch product.id {
        case Store.yearlyID: String(localized: "Yearly")
        case Store.weeklyID: String(localized: "Weekly")
        default: product.displayName
        }
    }

    private func planSubtitle(for product: Product) -> String {
        if product.id == Store.yearlyID, let weekly = product.weeklyPriceText {
            return String(localized: "\(weekly)/week, billed yearly")
        }
        if let unit = product.subscription?.subscriptionPeriod.unitName {
            return String(localized: "Billed every \(unit)")
        }
        return ""
    }

    /// Yearly against a year of the shortest plan, rounded down so the saving is never overstated.
    private func savingsPercent(for product: Product) -> Int? {
        guard product.id == Store.yearlyID,
              let yearlyWeekly = product.weeklyPrice,
              let cheapestWeekly = store.subscriptions
                .filter({ $0.id != product.id })
                .compactMap(\.weeklyPrice)
                .max(),
              cheapestWeekly > yearlyWeekly else { return nil }
        let ratio = NSDecimalNumber(decimal: (cheapestWeekly - yearlyWeekly) / cheapestWeekly).doubleValue
        let percent = Int((ratio * 100).rounded(.down))
        return percent > 0 ? percent : nil
    }

    // MARK: - Call to action

    private var ctaTitle: String {
        if let selectedTrial {
            return String(localized: "Start my \(selectedTrial) free")
        }
        return String(localized: "Continue")
    }

    /// What the user will be charged, right under the button (Guideline 3.1.2).
    private var ctaDisclosure: String? {
        guard let product = selectedProduct else { return nil }
        if let selectedTrial {
            return String(localized: "\(selectedTrial) free, then \(product.pricePerPeriodText). Cancel anytime.")
        }
        return String(localized: "\(product.pricePerPeriodText). Renews automatically. Cancel anytime.")
    }

    private var callToAction: some View {
        VStack(spacing: 10) {
            plans
                .padding(.bottom, 4)

            if selectedTrial != nil {
                Toggle(isOn: $remindBeforeTrialEnds) {
                    Label("Remind me before my trial ends", systemImage: "bell.badge")
                        .font(.subheadline)
                }
                .tint(.green)
                .padding(.horizontal, 4)
            }

            Button {
                purchaseSelected()
            } label: {
                ZStack {
                    if store.isPurchasing {
                        ProgressView()
                            .tint(Color(.systemBackground))
                    } else {
                        Text(ctaTitle)
                            .font(.headline)
                            .contentTransition(.opacity)
                    }
                }
                .foregroundStyle(Color(.systemBackground))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(.label), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(store.isPurchasing || selectedProduct == nil)

            if let ctaDisclosure {
                Text(ctaDisclosure)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: ctaDisclosure)
            }
        }
        .frame(maxWidth: 480)
        .padding(.horizontal, 24)
        .padding(.top, 14)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground).shadow(.drop(color: .black.opacity(0.08), radius: 12, y: -4)))
    }

    private func purchaseSelected() {
        guard let product = selectedProduct else { return }
        let startsTrial = store.hasEligibleTrial(product)
        let wantsReminder = remindBeforeTrialEnds
        isHoldingPaywall = true

        Task {
            if await store.purchase(product) {
                if startsTrial && wantsReminder {
                    await TrialReminder.schedule(for: product)
                }
                didUnlock = true
            } else {
                isHoldingPaywall = false
            }
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 14) {
            if let error = store.purchaseError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button("Restore Purchases") {
                isHoldingPaywall = true
                Task {
                    await store.restorePurchases()
                    if store.isSubscribed {
                        didUnlock = true
                    } else {
                        isHoldingPaywall = false
                    }
                }
            }
            .font(.subheadline.weight(.medium))
            .disabled(store.isPurchasing)

            Text("Subscriptions renew automatically unless cancelled at least 24 hours before the end of the period. Manage or cancel anytime in Settings.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                Text("·")
                Link("Privacy Policy", destination: URL(string: "https://giusscos.com/work/black-swan/privacy/")!)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .tint(.primary)
        .padding(.bottom, 16)
    }
}

// MARK: - Pieces

private struct PaywallBenefit: View {
    let icon: String
    let tint: Color
    let title: LocalizedStringKey
    let detail: LocalizedStringKey

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct PlanBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(color, in: Capsule())
    }
}

/// "How your free trial works" — makes the charge date explicit, which is what makes a trial feel safe.
private struct TrialTimeline: View {
    let trial: String
    let priceText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            step(icon: "lock.open.fill", tint: .green, title: "Today", detail: "Full access unlocks. No charge today.", isLast: false)
            step(icon: "bell.fill", tint: .orange, title: "2 days before it ends", detail: "We'll send you a reminder.", isLast: false)
            step(icon: "creditcard.fill", tint: .primary, title: "After \(trial)", detail: "You're billed \(priceText) unless you cancel.", isLast: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func step(icon: String, tint: Color, title: LocalizedStringKey, detail: LocalizedStringKey, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Image(systemName: icon)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(tint == .primary ? Color(.systemBackground) : .white)
                    .frame(width: 30, height: 30)
                    .background(tint, in: Circle())
                if !isLast {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.25))
                        .frame(width: 2)
                        .frame(minHeight: 22)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 5)
            .padding(.bottom, isLast ? 0 : 12)
        }
    }
}

private struct PaywallWelcomeView: View {
    let onContinue: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image("appIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 112, height: 112)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .shadow(color: .black.opacity(0.2), radius: 24, y: 12)
                .scaleEffect(appeared ? 1 : 0.6)
                .rotationEffect(.degrees(appeared ? 0 : -8))
                .padding(.bottom, 32)

            Text("You're all set")
                .font(.largeTitle.bold())
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)

            Text("Start with the last thing that caught you off guard. We'll classify it and suggest how to protect yourself next time.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
                .padding(.top, 12)
                .opacity(appeared ? 1 : 0)

            Spacer()

            Button(action: onContinue) {
                Text("Log my first event")
                    .font(.headline)
                    .foregroundStyle(Color(.systemBackground))
                    .frame(maxWidth: 432)
                    .frame(height: 56)
                    .background(Color(.label), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .opacity(appeared ? 1 : 0)
        }
        .sensoryFeedback(.success, trigger: appeared)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
}

#Preview {
    PaywallView(isHoldingPaywall: .constant(false))
        .environment(Store())
}
