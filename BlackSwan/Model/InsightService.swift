//
//  InsightService.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 20/07/26.
//

import Foundation

struct EventInsight: Sendable, Equatable {
    var explanation: String
    var mitigations: [String]
    var theme: RiskTheme?
}

struct PreMortemPlan: Sendable, Equatable {
    var scenario: String
    var buffers: [String]
    var theme: RiskTheme
}

struct WeeklyReviewSummary: Sendable, Equatable {
    var headline: String
    var focus: String
    var wins: [String]
}

enum InsightService {
    static var isAvailable: Bool {
        if #available(iOS 26.0, *) {
            return FoundationInsightBackend.isAvailable
        }
        return false
    }
    
    static func generateInsight(
        for text: String,
        classification: SwanClassification,
        probability: Int
    ) async -> EventInsight? {
        if #available(iOS 26.0, *) {
            if let insight = await FoundationInsightBackend.generate(
                text: text,
                classification: classification,
                probability: probability
            ) {
                return insight
            }
        }
        
        // Offline fallback: theme + generic mitigations for Black Swans.
        let theme = RiskTheme.infer(from: text)
        guard classification == .blackSwan || probability < 60 else {
            return EventInsight(
                explanation: "This looks like a foreseeable or chosen risk.",
                mitigations: [],
                theme: theme
            )
        }
        
        return EventInsight(
            explanation: "This may be a high-impact surprise. Build buffers so one shock cannot wipe you out.",
            mitigations: defaultMitigations(for: theme),
            theme: theme
        )
    }
    
    static func generatePreMortem(for worry: String) async -> PreMortemPlan? {
        if #available(iOS 26.0, *) {
            if let plan = await FoundationInsightBackend.generatePreMortem(worry: worry) {
                return plan
            }
        }
        
        let theme = RiskTheme.infer(from: worry)
        return PreMortemPlan(
            scenario: "If “\(worry)” hit hard next month, the damage would come from lack of buffers and single points of failure.",
            buffers: defaultMitigations(for: theme),
            theme: theme
        )
    }
    
    static func generateWeeklyReview(
        blackSwanCount: Int,
        deliberateCount: Int,
        completedActions: Int,
        openActions: Int,
        topTheme: RiskTheme?
    ) async -> WeeklyReviewSummary? {
        if #available(iOS 26.0, *) {
            if let summary = await FoundationInsightBackend.generateWeeklyReview(
                blackSwanCount: blackSwanCount,
                deliberateCount: deliberateCount,
                completedActions: completedActions,
                openActions: openActions,
                topTheme: topTheme
            ) {
                return summary
            }
        }
        
        let themeName = topTheme?.displayString ?? "overall exposure"
        return WeeklyReviewSummary(
            headline: "This week: \(blackSwanCount) Black Swan\(blackSwanCount == 1 ? "" : "s"), \(deliberateCount) deliberate.",
            focus: "Reduce fragility in \(themeName). Close \(max(openActions, 1)) open mitigation\(openActions == 1 ? "" : "s").",
            wins: completedActions > 0
                ? ["You completed \(completedActions) protective action\(completedActions == 1 ? "" : "s")."]
                : ["You logged events — awareness is the first buffer."]
        )
    }
    
    static func defaultMitigations(for theme: RiskTheme) -> [String] {
        switch theme {
        case .money:
            return [
                "Keep 3–6 months of expenses in a separate cash buffer",
                "Cap any single investment or income source at a fixed % of net worth / income",
                "Write a one-page plan for a 30% income drop"
            ]
        case .work:
            return [
                "Document key processes so one person is not a single point of failure",
                "Warm two backup clients, roles, or income paths this month",
                "Set a hard limit on concentration in one employer or client"
            ]
        case .health:
            return [
                "Book the deferred checkup or specialist visit",
                "Build a 2-week recovery buffer in your calendar and finances",
                "Identify one stress load you can cut for 30 days"
            ]
        case .relationships:
            return [
                "Have one honest conversation about the fragile spot",
                "Reduce dependence on a single relationship for support or housing",
                "Schedule a recurring check-in before the next crisis"
            ]
        case .other:
            return [
                "Name the worst realistic downside in one sentence",
                "Add one redundant option (backup plan, spare resource, exit path)",
                "Shrink exposure so the same shock hurts less next time"
            ]
        }
    }
}

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct GenerableEventInsight {
    @Guide(description: "One or two short sentences explaining why this event fits the given classification.")
    var explanation: String
    
    @Guide(description: "Up to three practical actions to reduce exposure or prepare for similar events.")
    var mitigations: [String]
    
    @Guide(description: "Best-fit life domain: money, work, health, relationships, or other.")
    var theme: String
}

@available(iOS 26.0, *)
@Generable
struct GenerablePreMortem {
    @Guide(description: "A short vivid scenario of how this worry could become a high-impact surprise.")
    var scenario: String
    
    @Guide(description: "Three concrete buffers or prep actions to limit damage.")
    var buffers: [String]
    
    @Guide(description: "Best-fit life domain: money, work, health, relationships, or other.")
    var theme: String
}

@available(iOS 26.0, *)
@Generable
struct GenerableWeeklyReview {
    @Guide(description: "One sentence headline summarizing the week.")
    var headline: String
    
    @Guide(description: "One concrete focus for next week.")
    var focus: String
    
    @Guide(description: "Up to two short wins or encouraging observations.")
    var wins: [String]
}

@available(iOS 26.0, *)
enum FoundationInsightBackend {
    static var isAvailable: Bool {
        switch SystemLanguageModel.default.availability {
        case .available:
            return true
        default:
            return false
        }
    }
    
    private static func mapTheme(_ raw: String) -> RiskTheme {
        RiskTheme(rawValue: raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()) ?? .other
    }
    
    static func generate(
        text: String,
        classification: SwanClassification,
        probability: Int
    ) async -> EventInsight? {
        guard isAvailable else { return nil }
        
        let session = LanguageModelSession(instructions: """
            You help people understand rare, high-impact "Black Swan" events versus deliberate, \
            foreseeable risks. Be concise, practical, and calm. Do not invent facts that are not \
            in the event text. Do not contradict the provided classification. Theme must be one of: \
            money, work, health, relationships, other.
            """)
        
        let prompt = """
            Event: \(text)
            
            Classifier label: \(classification.displayString)
            Classifier confidence: \(probability)%
            
            Explain briefly why this classification fits, pick a theme, and suggest up to three \
            concrete ways to limit damage or prepare.
            """
        
        do {
            let response = try await session.respond(
                to: prompt,
                generating: GenerableEventInsight.self
            )
            let content = response.content
            let tips = content.mitigations
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .prefix(3)
            
            return EventInsight(
                explanation: content.explanation.trimmingCharacters(in: .whitespacesAndNewlines),
                mitigations: Array(tips),
                theme: mapTheme(content.theme)
            )
        } catch {
            print("Foundation Model insight failed: \(error)")
            return nil
        }
    }
    
    static func generatePreMortem(worry: String) async -> PreMortemPlan? {
        guard isAvailable else { return nil }
        
        let session = LanguageModelSession(instructions: """
            You run pre-mortems: imagine a worry has already become a painful surprise, then propose \
            practical buffers. Be concrete and calm. Theme must be one of: money, work, health, \
            relationships, other.
            """)
        
        let prompt = """
            Worry: \(worry)
            
            Describe a short scenario of how this could hit hard within a month, then give three \
            buffers that would limit the damage.
            """
        
        do {
            let response = try await session.respond(
                to: prompt,
                generating: GenerablePreMortem.self
            )
            let content = response.content
            let buffers = content.buffers
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .prefix(3)
            
            return PreMortemPlan(
                scenario: content.scenario.trimmingCharacters(in: .whitespacesAndNewlines),
                buffers: Array(buffers),
                theme: mapTheme(content.theme)
            )
        } catch {
            print("Foundation Model pre-mortem failed: \(error)")
            return nil
        }
    }
    
    static func generateWeeklyReview(
        blackSwanCount: Int,
        deliberateCount: Int,
        completedActions: Int,
        openActions: Int,
        topTheme: RiskTheme?
    ) async -> WeeklyReviewSummary? {
        guard isAvailable else { return nil }
        
        let session = LanguageModelSession(instructions: """
            You write short weekly fragility reviews. Encouraging, practical, no fluff.
            """)
        
        let prompt = """
            Black Swan events: \(blackSwanCount)
            Deliberate events: \(deliberateCount)
            Mitigations completed: \(completedActions)
            Mitigations still open: \(openActions)
            Most fragile theme: \(topTheme?.displayString ?? "unclear")
            
            Write a headline, one next-week focus, and up to two wins.
            """
        
        do {
            let response = try await session.respond(
                to: prompt,
                generating: GenerableWeeklyReview.self
            )
            let content = response.content
            return WeeklyReviewSummary(
                headline: content.headline.trimmingCharacters(in: .whitespacesAndNewlines),
                focus: content.focus.trimmingCharacters(in: .whitespacesAndNewlines),
                wins: Array(
                    content.wins
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                        .prefix(2)
                )
            )
        } catch {
            print("Foundation Model weekly review failed: \(error)")
            return nil
        }
    }
}
#else
@available(iOS 26.0, *)
enum FoundationInsightBackend {
    static var isAvailable: Bool { false }
    
    static func generate(
        text: String,
        classification: SwanClassification,
        probability: Int
    ) async -> EventInsight? { nil }
    
    static func generatePreMortem(worry: String) async -> PreMortemPlan? { nil }
    
    static func generateWeeklyReview(
        blackSwanCount: Int,
        deliberateCount: Int,
        completedActions: Int,
        openActions: Int,
        topTheme: RiskTheme?
    ) async -> WeeklyReviewSummary? { nil }
}
#endif
