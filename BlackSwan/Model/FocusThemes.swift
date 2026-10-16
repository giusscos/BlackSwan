//
//  FocusThemes.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 16/10/26.
//

import Foundation

/// The risk areas a person picked during onboarding, stored as comma-separated raw values.
enum FocusThemes {
    static let storageKey = "focusThemes"
    static let choices: [RiskTheme] = [.money, .work, .health, .relationships]

    static func decode(_ raw: String) -> [RiskTheme] {
        let values = Set(raw.split(separator: ",").map(String.init))
        return choices.filter { values.contains($0.rawValue) }
    }

    static func encode(_ themes: Set<RiskTheme>) -> String {
        choices.filter(themes.contains).map(\.rawValue).joined(separator: ",")
    }

    static func paywallHeadline(for raw: String) -> String {
        switch decode(raw).first {
        case .money: String(localized: "Protect your money from the next shock")
        case .work: String(localized: "Stay steady when work gets shaken")
        case .health: String(localized: "Be ready before health surprises hit")
        case .relationships: String(localized: "Protect the people who count on you")
        default: String(localized: "Be ready for the next surprise")
        }
    }

    /// A believable shock for the onboarding demo, matched to what the person worries about.
    static func demoEvent(for raw: String) -> DemoEvent {
        switch decode(raw).first {
        case .money:
            DemoEvent(
                text: String(localized: "My bank froze my account for a week, right before rent was due."),
                confidence: 81,
                mitigations: [
                    String(localized: "Keep one month of rent in a second bank"),
                    String(localized: "Set up a backup card for bills"),
                    String(localized: "Build a 3-month cash buffer")
                ]
            )
        case .health:
            DemoEvent(
                text: String(localized: "Unexpected ER visit and a surprise bill after insurance."),
                confidence: 84,
                mitigations: [
                    String(localized: "Start a medical emergency fund"),
                    String(localized: "Check out-of-network coverage"),
                    String(localized: "Book the checkup you postponed")
                ]
            )
        case .relationships:
            DemoEvent(
                text: String(localized: "My partner's job relocated with three weeks' notice."),
                confidence: 77,
                mitigations: [
                    String(localized: "Draft a 30-day housing backup plan"),
                    String(localized: "List two fallback neighborhoods"),
                    String(localized: "Agree on a shared moving budget")
                ]
            )
        default:
            DemoEvent(
                text: String(localized: "My biggest client cancelled with two weeks' notice."),
                confidence: 86,
                mitigations: [
                    String(localized: "Warm up two backup prospects"),
                    String(localized: "No client above 30% of revenue"),
                    String(localized: "Keep 3 months of expenses aside")
                ]
            )
        }
    }
}

struct DemoEvent {
    let text: String
    let confidence: Int
    let mitigations: [String]
}
