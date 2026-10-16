//
//  MockData.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 20/07/26.
//

import Foundation
import SwiftData

enum MockData {
    @MainActor
    static func insertSampleContent(into context: ModelContext) {
        let calendar = Calendar.current
        let now = Date()
        
        let samples: [(daysAgo: Int, text: String, classification: SwanClassification, theme: RiskTheme, probability: Int, explanation: String, mitigations: [(String, Bool)])] = [
            (
                1,
                String(localized: "Largest client paused the retainer with two weeks’ notice. Cash flow tight next month."),
                .blackSwan,
                .work,
                78,
                String(localized: "An abrupt income shock from concentration in a single client."),
                [
                    (String(localized: "Warm two backup prospects this week"), false),
                    (String(localized: "Cut discretionary spend for 30 days"), true),
                    (String(localized: "Keep 3 months of expenses in a separate buffer"), false)
                ]
            ),
            (
                2,
                String(localized: "Took a calculated equity grant instead of higher salary — known trade-off."),
                .deliberate,
                .work,
                88,
                String(localized: "A foreseeable compensation choice with clear upside and downside."),
                []
            ),
            (
                5,
                String(localized: "Regional bank stress rumor briefly froze a transfer I needed for rent."),
                .blackSwan,
                .money,
                71,
                String(localized: "Infrastructure/finance friction that was hard to price in advance."),
                [
                    (String(localized: "Split operating cash across two banks"), false),
                    (String(localized: "Keep one month of rent in a local credit union"), true)
                ]
            ),
            (
                8,
                String(localized: "Bought a concentrated crypto position after a tip from a friend."),
                .deliberate,
                .money,
                82,
                String(localized: "Intentional speculative risk with asymmetric downside."),
                [
                    (String(localized: "Cap speculative assets at 5% of net worth"), false)
                ]
            ),
            (
                12,
                String(localized: "Unexpected ER visit and a surprise bill after insurance."),
                .blackSwan,
                .health,
                84,
                String(localized: "High-impact health cost that arrived without warning."),
                [
                    (String(localized: "Build a dedicated medical emergency fund"), false),
                    (String(localized: "Review out-of-network exposure on the plan"), true),
                    (String(localized: "Schedule the deferred annual checkup"), false)
                ]
            ),
            (
                16,
                String(localized: "Chose to train for a marathon while shipping a big release — accepted burnout risk."),
                .deliberate,
                .health,
                75,
                String(localized: "A known load you opted into."),
                [
                    (String(localized: "Block one recovery day each week"), true)
                ]
            ),
            (
                20,
                String(localized: "Partner’s employer relocated with little notice; housing plans scrambled."),
                .blackSwan,
                .relationships,
                69,
                String(localized: "A household shock driven by someone else’s employer decision."),
                [
                    (String(localized: "Draft a 30-day housing contingency plan"), false),
                    (String(localized: "List two backup neighborhoods and budgets"), false)
                ]
            ),
            (
                28,
                String(localized: "Agreed to co-sign a family loan after a long discussion of the risks."),
                .deliberate,
                .relationships,
                90,
                String(localized: "A chosen obligation with open eyes."),
                []
            ),
            (
                35,
                String(localized: "Cloud outage took down the only payment provider for a weekend."),
                .blackSwan,
                .work,
                73,
                String(localized: "Single-vendor dependency turned a vendor outage into lost revenue."),
                [
                    (String(localized: "Add a secondary payment provider"), false),
                    (String(localized: "Document a manual invoice fallback"), true)
                ]
            ),
            (
                40,
                String(localized: "Moved savings into a high-yield account — intentional and reversible."),
                .deliberate,
                .money,
                92,
                String(localized: "A deliberate, low-drama money move."),
                []
            )
        ]
        
        for sample in samples {
            let event = Swan(text: sample.text)
            event.timestamp = calendar.date(byAdding: .day, value: -sample.daysAgo, to: now) ?? now
            event.classification = sample.classification
            event.theme = sample.theme
            event.probability = sample.probability
            event.explanation = sample.explanation
            event.mitigationItems = sample.mitigations.map {
                MitigationItem(text: $0.0, isDone: $0.1)
            }
            context.insert(event)
        }
        
        let preMortem = PreMortem(worry: String(localized: "My primary income source disappears for 90 days"))
        preMortem.timestamp = calendar.date(byAdding: .day, value: -3, to: now) ?? now
        preMortem.theme = .work
        preMortem.scenario = String(localized: "If income stopped tomorrow, rent and runway would force rushed decisions within six weeks — especially with one dominant client and thin cash reserves.")
        preMortem.bufferItems = [
            MitigationItem(text: String(localized: "Raise cash runway to 4 months of fixed costs"), isDone: false),
            MitigationItem(text: String(localized: "No single client above 30% of revenue"), isDone: true),
            MitigationItem(text: String(localized: "Keep a ready list of three warm leads"), isDone: false)
        ]
        context.insert(preMortem)
    }
}
