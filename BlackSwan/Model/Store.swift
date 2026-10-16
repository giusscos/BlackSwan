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
    private(set) var isPurchasing = false
    var purchaseError: String?
    /// Products whose introductory free trial this Apple Account can still redeem.
    private(set) var trialEligibleIDs: Set<String> = []
    
    static let yearlyID = "bs_1999_1y_1w"
    static let weeklyID = "com.giusscos.blackswan.weekly"
    private let productIds: Set<String> = [Store.yearlyID, Store.weeklyID]
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
            let products = try await Product.products(for: Array(productIds))
            // Yearly first: it's the plan the paywall recommends.
            subscriptions = products.sorted { $0.price > $1.price }
            await refreshTrialEligibility()
        } catch {
            print("Failed product request from app store server: \(error)")
        }
    }
    
    func hasEligibleTrial(_ product: Product) -> Bool {
        product.freeTrialPeriod != nil && trialEligibleIDs.contains(product.id)
    }
    
    private func refreshTrialEligibility() async {
        var eligible: Set<String> = []
        for product in subscriptions where product.freeTrialPeriod != nil {
            if await product.subscription?.isEligibleForIntroOffer == true {
                eligible.insert(product.id)
            }
        }
        trialEligibleIDs = eligible
    }
    
    /// Returns true when the purchase went through and access is unlocked.
    @discardableResult
    func purchase(_ product: Product) async -> Bool {
        isPurchasing = true
        purchaseError = nil
        defer { isPurchasing = false }
        
        do {
            switch try await product.purchase() {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                markSubscribedFromPurchase()
                await refreshEntitlements()
                return true
            case .pending:
                purchaseError = String(localized: "Your purchase is pending approval. You'll get access as soon as it's approved.")
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = String(localized: "The purchase couldn't be completed. Please try again.")
            print("Purchase failed: \(error)")
        }
        return false
    }
    
    func restorePurchases() async {
        isPurchasing = true
        purchaseError = nil
        defer { isPurchasing = false }
        
        do {
            try await AppStore.sync()
        } catch {
            print("Restore failed: \(error)")
        }
        await refreshEntitlements()
        if !isSubscribed {
            purchaseError = String(localized: "No active subscription found for this Apple Account.")
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
        #if DEBUG
        if UserDefaults.standard.bool(forKey: "SimulatorSubscribed") {
            isSubscribed = true
            return
        }
        #endif
        if let subscribed = await subscriptionGroupIsActive() {
            isSubscribed = subscribed
            return
        }
        
        isSubscribed = await hasEntitlementTransaction()
    }
    
    func updateFromSubscriptionStatuses(_ statuses: [Product.SubscriptionInfo.Status]) {
        #if DEBUG
        if UserDefaults.standard.bool(forKey: "SimulatorSubscribed") {
            isSubscribed = true
            isLoading = false
            return
        }
        #endif
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

extension Product {
    var freeTrialPeriod: Product.SubscriptionPeriod? {
        guard let offer = subscription?.introductoryOffer, offer.paymentMode == .freeTrial else { return nil }
        return offer.period
    }
    
    /// "1 week", "3 days" — the length of the free trial, if the product has one.
    var freeTrialText: String? {
        freeTrialPeriod.map(\.durationText)
    }
    
    /// "$19.99/year"
    var pricePerPeriodText: String {
        guard let period = subscription?.subscriptionPeriod else { return displayPrice }
        return "\(displayPrice)/\(period.unitName)"
    }
    
    /// Price spread over a week, used to compare plans of different lengths.
    var weeklyPrice: Decimal? {
        guard let period = subscription?.subscriptionPeriod else { return nil }
        let weeks: Decimal = switch period.unit {
        case .day: Decimal(period.value) / 7
        case .week: Decimal(period.value)
        case .month: Decimal(period.value) * 52 / 12
        case .year: Decimal(period.value) * 52
        @unknown default: 0
        }
        guard weeks > 0 else { return nil }
        return price / weeks
    }
    
    var weeklyPriceText: String? {
        weeklyPrice.map { $0.formatted(priceFormatStyle) }
    }
}

extension Product.SubscriptionPeriod {
    var durationText: String {
        switch unit {
        case .day where isWholeWeeks: value == 7 ? String(localized: "1 week") : String(localized: "\(value / 7) weeks")
        case .day: String(localized: "\(value) days")
        case .week: value == 1 ? String(localized: "1 week") : String(localized: "\(value) weeks")
        case .month: value == 1 ? String(localized: "1 month") : String(localized: "\(value) months")
        case .year: value == 1 ? String(localized: "1 year") : String(localized: "\(value) years")
        @unknown default: ""
        }
    }
    
    /// StoreKit sometimes reports a weekly plan as 7 days.
    private var isWholeWeeks: Bool {
        unit == .day && value % 7 == 0
    }
    
    var unitName: String {
        if isWholeWeeks && value == 7 {
            return String(localized: "week")
        }
        return switch unit {
        case .day: String(localized: "day")
        case .week: String(localized: "week")
        case .month: String(localized: "month")
        case .year: String(localized: "year")
        @unknown default: ""
        }
    }
}
