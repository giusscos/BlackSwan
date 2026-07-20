//
//  OnboardingView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 11/04/25.
//

import SwiftUI
import StoreKit

/// Subscription paywall shown after concept onboarding when the user has no entitlement.
struct OnboardingView: View {
    @Environment(Store.self) private var store
    
    @State private var headerVisible = false
    @State private var purchaseSuccessHaptic = false
    
    var body: some View {
        SubscriptionStoreView(groupID: Store.groupId) {
            VStack(spacing: 20) {
                Image("appIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .black.opacity(0.12), radius: 16, y: 8)
                    .scaleEffect(headerVisible ? 1 : 0.86)
                    .opacity(headerVisible ? 1 : 0)
                
                VStack(spacing: 10) {
                    Text("Unlock Black Swan")
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                    
                    Text("Fragility insights, weekly reviews, pre-mortems, and on-device plans — start with a free trial.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .opacity(headerVisible ? 1 : 0)
                .offset(y: headerVisible ? 0 : 14)
                
                VStack(alignment: .leading, spacing: 10) {
                    PaywallPerk(icon: "chart.line.uptrend.xyaxis", text: "Track your fragility over time")
                    PaywallPerk(icon: "checklist", text: "Turn shocks into done mitigations")
                    PaywallPerk(icon: "shield.lefthalf.filled", text: "Run pre-mortems before surprises")
                }
                .padding(.top, 4)
                .opacity(headerVisible ? 1 : 0)
                .offset(y: headerVisible ? 0 : 18)
            }
            .frame(maxWidth: 400)
            .padding()
            .animation(.spring(response: 0.55, dampingFraction: 0.82), value: headerVisible)
        }
        .subscriptionStoreControlStyle(.compactPicker, placement: .automatic)
        .subscriptionStoreButtonLabel(.multiline)
        .storeButton(.visible, for: .restorePurchases)
        .subscriptionStorePolicyDestination(url: URL(string: "https://giusscos.it/privacy")!, for: .privacyPolicy)
        .subscriptionStorePolicyDestination(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!, for: .termsOfService)
        .tint(.primary)
        .interactiveDismissDisabled()
        .sensoryFeedback(.success, trigger: purchaseSuccessHaptic)
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.82).delay(0.05)) {
                headerVisible = true
            }
        }
        .onInAppPurchaseCompletion { _, result in
            // Nested Result: outer = StoreKit call, inner = PurchaseResult.
            switch result {
            case .success(.success(let verification)):
                do {
                    let transaction = try store.checkVerified(verification)
                    await transaction.finish()
                    purchaseSuccessHaptic.toggle()
                    store.markSubscribedFromPurchase()
                    await store.refreshEntitlements()
                } catch {
                    print("Purchase verification failed: \(error)")
                    await store.refreshEntitlements()
                }
            case .success(.pending):
                break
            case .success(.userCancelled):
                break
            case .success:
                await store.refreshEntitlements()
            case .failure(let error):
                print("Purchase failed: \(error)")
            }
        }
    }
}

private struct PaywallPerk: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    OnboardingView()
        .environment(Store())
}
