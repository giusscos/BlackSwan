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
                "Largest client paused the retainer with two weeks’ notice. Cash flow tight next month.",
                .blackSwan,
                .work,
                78,
                "An abrupt income shock from concentration in a single client.",
                [
                    ("Warm two backup prospects this week", false),
                    ("Cut discretionary spend for 30 days", true),
                    ("Keep 3 months of expenses in a separate buffer", false)
                ]
            ),
            (
                2,
                "Took a calculated equity grant instead of higher salary — known trade-off.",
                .deliberate,
                .work,
                88,
                "A foreseeable compensation choice with clear upside and downside.",
                []
            ),
            (
                5,
                "Regional bank stress rumor briefly froze a transfer I needed for rent.",
                .blackSwan,
                .money,
                71,
                "Infrastructure/finance friction that was hard to price in advance.",
                [
                    ("Split operating cash across two banks", false),
                    ("Keep one month of rent in a local credit union", true)
                ]
            ),
            (
                8,
                "Bought a concentrated crypto position after a tip from a friend.",
                .deliberate,
                .money,
                82,
                "Intentional speculative risk with asymmetric downside.",
                [
                    ("Cap speculative assets at 5% of net worth", false)
                ]
            ),
            (
                12,
                "Unexpected ER visit and a surprise bill after insurance.",
                .blackSwan,
                .health,
                84,
                "High-impact health cost that arrived without warning.",
                [
                    ("Build a dedicated medical emergency fund", false),
                    ("Review out-of-network exposure on the plan", true),
                    ("Schedule the deferred annual checkup", false)
                ]
            ),
            (
                16,
                "Chose to train for a marathon while shipping a big release — accepted burnout risk.",
                .deliberate,
                .health,
                75,
                "A known load you opted into.",
                [
                    ("Block one recovery day each week", true)
                ]
            ),
            (
                20,
                "Partner’s employer relocated with little notice; housing plans scrambled.",
                .blackSwan,
                .relationships,
                69,
                "A household shock driven by someone else’s employer decision.",
                [
                    ("Draft a 30-day housing contingency plan", false),
                    ("List two backup neighborhoods and budgets", false)
                ]
            ),
            (
                28,
                "Agreed to co-sign a family loan after a long discussion of the risks.",
                .deliberate,
                .relationships,
                90,
                "A chosen obligation with open eyes.",
                []
            ),
            (
                35,
                "Cloud outage took down the only payment provider for a weekend.",
                .blackSwan,
                .work,
                73,
                "Single-vendor dependency turned a vendor outage into lost revenue.",
                [
                    ("Add a secondary payment provider", false),
                    ("Document a manual invoice fallback", true)
                ]
            ),
            (
                40,
                "Moved savings into a high-yield account — intentional and reversible.",
                .deliberate,
                .money,
                92,
                "A deliberate, low-drama money move.",
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
        
        let preMortem = PreMortem(worry: "My primary income source disappears for 90 days")
        preMortem.timestamp = calendar.date(byAdding: .day, value: -3, to: now) ?? now
        preMortem.theme = .work
        preMortem.scenario = "If income stopped tomorrow, rent and runway would force rushed decisions within six weeks — especially with one dominant client and thin cash reserves."
        preMortem.bufferItems = [
            MitigationItem(text: "Raise cash runway to 4 months of fixed costs", isDone: false),
            MitigationItem(text: "No single client above 30% of revenue", isDone: true),
            MitigationItem(text: "Keep a ready list of three warm leads", isDone: false)
        ]
        context.insert(preMortem)
    }
}
