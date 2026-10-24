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
    
    /// Extra sample content for iPad screenshots, where the bigger screen would otherwise look empty.
    @MainActor
    static func insertTabletExtras(into context: ModelContext) {
        let calendar = Calendar.current
        let now = Date()
        
        let events = (try? context.fetch(FetchDescriptor<Swan>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)]))) ?? []
        if let latest = events.first {
            latest.explanation = String(localized: "An abrupt income shock from concentration in a single client. One decision outside your control removed most of next month's revenue, and there was no buffer to absorb it.")
            latest.mitigationItems += [
                MitigationItem(text: String(localized: "Ask for 50% upfront on new projects"), isDone: true),
                MitigationItem(text: String(localized: "Set an alert when cash drops below 60 days of costs"), isDone: false)
            ]
        }
        
        let plans = (try? context.fetch(FetchDescriptor<PreMortem>())) ?? []
        plans.first?.bufferItems += [
            MitigationItem(text: String(localized: "Agree a 60-day notice clause with every client"), isDone: false),
            MitigationItem(text: String(localized: "Cut fixed costs that don't earn their keep"), isDone: true)
        ]
        
        let extras: [(daysAgo: Int, worry: String, theme: RiskTheme, scenario: String, buffers: [(String, Bool)])] = [
            (
                9,
                String(localized: "A health issue keeps me from working for six weeks"),
                .health,
                String(localized: "Six weeks without income while bills keep coming, and no one who can cover your work."),
                [(String(localized: "Check what your insurance pays if you can't work"), false),
                 (String(localized: "Write down who could cover your clients"), true)]
            ),
            (
                21,
                String(localized: "My rent goes up 25% at renewal"),
                .money,
                String(localized: "A sudden jump in your biggest fixed cost squeezes savings and forces a rushed move."),
                [(String(localized: "Know the cheapest place you'd move to"), false),
                 (String(localized: "Save the difference for three months now"), false)]
            )
        ]
        for extra in extras {
            let plan = PreMortem(worry: extra.worry)
            plan.timestamp = calendar.date(byAdding: .day, value: -extra.daysAgo, to: now) ?? now
            plan.theme = extra.theme
            plan.scenario = extra.scenario
            plan.bufferItems = extra.buffers.map { MitigationItem(text: $0.0, isDone: $0.1) }
            context.insert(plan)
        }
    }
}
