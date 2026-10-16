//
//  TrialReminder.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 16/10/26.
//

import Foundation
import StoreKit
import UserNotifications

/// Local notification before a free trial converts. People start trials more readily
/// when they know they'll be warned, and it heads off surprise charges and refunds.
enum TrialReminder {
    private static let identifier = "trial-ending-reminder"

    static func schedule(for product: Product, trialStart: Date = .now) async {
        guard let trial = product.freeTrialPeriod else { return }

        let center = UNUserNotificationCenter.current()
        guard (try? await center.requestAuthorization(options: [.alert, .sound])) == true else { return }

        let calendar = Calendar.current
        let component: Calendar.Component = switch trial.unit {
        case .day: .day
        case .week: .weekOfYear
        case .month: .month
        case .year: .year
        @unknown default: .day
        }
        guard let trialEnd = calendar.date(byAdding: component, value: trial.value, to: trialStart),
              let fireDate = calendar.date(byAdding: .day, value: -2, to: trialEnd),
              fireDate > .now else { return }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "Your free trial ends in 2 days")
        content.body = String(localized: "After that it's \(product.pricePerPeriodText). Keep it, or cancel anytime in Settings → Apple Account → Subscriptions.")
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate),
            repeats: false
        )
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        try? await center.add(UNNotificationRequest(identifier: identifier, content: content, trigger: trigger))
    }
}
