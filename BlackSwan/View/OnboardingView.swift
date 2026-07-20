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
    
    var body: some View {
        SubscriptionStoreView(groupID: Store.groupId) {
            VStack(spacing: 20) {
                Image("appIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                
                Text("Unlock Black Swan")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                
                Text("Log events, get on-device classifications, and turn surprises into preparation — with a free trial.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: 400)
            .padding()
        }
        .subscriptionStoreControlStyle(.compactPicker, placement: .automatic)
        .subscriptionStoreButtonLabel(.multiline)
        .storeButton(.visible, for: .restorePurchases)
        .subscriptionStorePolicyDestination(url: URL(string: "https://giusscos.it/privacy")!, for: .privacyPolicy)
        .subscriptionStorePolicyDestination(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!, for: .termsOfService)
        .tint(.primary)
        .interactiveDismissDisabled()
        .onInAppPurchaseCompletion { _, result in
            // Nested Result: outer = StoreKit call, inner = PurchaseResult.
            switch result {
            case .success(.success(let verification)):
                do {
                    let transaction = try store.checkVerified(verification)
                    await transaction.finish()
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

#Preview {
    OnboardingView()
        .environment(Store())
}
