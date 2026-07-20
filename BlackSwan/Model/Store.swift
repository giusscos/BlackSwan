//
//  Store.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 31/10/24.
//

import Foundation
import StoreKit

typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

@Observable
@MainActor
class Store {
    private(set) var subscriptions: [Product] = []
    /// Driven by `subscriptionStatusTask` / `refreshEntitlements`.
    var isSubscribed: Bool = false
    var isLoading: Bool = true
    
    private let productIds: Set<String> = ["bs_1999_1y_1w", "com.giusscos.blackswan.weekly"]
    static let groupId: String = "21679517"
    
    var groupId: String { Self.groupId }
    
    private nonisolated(unsafe) var updateListenerTask: Task<Void, Never>?
    
    init() {
        updateListenerTask = listenForTransactions()
        
        Task {
            await requestProducts()
            await refreshEntitlements()
            isLoading = false
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                do {
                    let transaction = try checkVerified(result)
                    await refreshEntitlements()
                    await transaction.finish()
                } catch {
                    print("transaction failed verification: \(error)")
                }
            }
        }
    }
    
    func requestProducts() async {
        do {
            subscriptions = try await Product.products(for: Array(productIds))
        } catch {
            print("Failed product request from app store server: \(error)")
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    /// Prefer subscription-group status; fall back to current entitlements.
    func refreshEntitlements() async {
        if let subscribed = await subscriptionGroupIsActive() {
            isSubscribed = subscribed
            return
        }
        
        isSubscribed = await hasEntitlementTransaction()
    }
    
    func updateFromSubscriptionStatuses(_ statuses: [Product.SubscriptionInfo.Status]) {
        isSubscribed = Self.hasActiveSubscription(in: statuses)
        isLoading = false
    }
    
    /// Call immediately after a verified purchase so UI can leave the paywall without waiting.
    func markSubscribedFromPurchase() {
        isSubscribed = true
        isLoading = false
    }
    
    private static func hasActiveSubscription(in statuses: [Product.SubscriptionInfo.Status]) -> Bool {
        statuses.contains { status in
            switch status.state {
            case .subscribed, .inGracePeriod, .inBillingRetryPeriod:
                return true
            default:
                return false
            }
        }
    }
    
    private func subscriptionGroupIsActive() async -> Bool? {
        do {
            let statuses = try await Product.SubscriptionInfo.status(for: Self.groupId)
            return Self.hasActiveSubscription(in: statuses)
        } catch {
            print("SubscriptionInfo.status failed: \(error)")
            return nil
        }
    }
    
    private func hasEntitlementTransaction() async -> Bool {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                guard transaction.productType == .autoRenewable else { continue }
                guard productIds.contains(transaction.productID) else { continue }
                if transaction.revocationDate != nil { continue }
                if let expiration = transaction.expirationDate, expiration < Date() { continue }
                return true
            } catch {
                continue
            }
        }
        return false
    }
}

public enum StoreError: Error {
    case failedVerification
}
