//
//  FragilityAnalytics.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 20/07/26.
//

import Foundation

struct ThemeStat: Identifiable, Equatable {
    var id: RiskTheme { theme }
    let theme: RiskTheme
    let blackSwanCount: Int
    let totalCount: Int
    
    var share: Double {
        guard totalCount > 0 else { return 0 }
        return Double(blackSwanCount) / Double(totalCount)
    }
}

struct WeekBucket: Identifiable, Equatable {
    var id: Date { weekStart }
    let weekStart: Date
    let blackSwanCount: Int
    let deliberateCount: Int
}

struct FragilitySnapshot: Equatable {
    let eventCount: Int
    let blackSwanCount: Int
    let deliberateCount: Int
    let completedActions: Int
    let openActions: Int
    let score: Int
    let topTheme: RiskTheme?
    let themeStats: [ThemeStat]
    let recentWeeks: [WeekBucket]
    let summaryLine: String
    
    static let empty = FragilitySnapshot(
        eventCount: 0,
        blackSwanCount: 0,
        deliberateCount: 0,
        completedActions: 0,
        openActions: 0,
        score: 0,
        topTheme: nil,
        themeStats: [],
        recentWeeks: [],
        summaryLine: String(localized: "Log a few events to see where you’re fragile.")
    )
}

enum FragilityAnalytics {
    static func snapshot(from events: [Swan], now: Date = .now, calendar: Calendar = .current) -> FragilitySnapshot {
        guard !events.isEmpty else { return .empty }
        
        let blackSwans = events.filter { $0.classification == .blackSwan }
        let deliberate = events.filter { $0.classification == .deliberate }
        
        let allMitigations = events.flatMap(\.mitigationItems)
        let completed = allMitigations.filter(\.isDone).count
        let open = allMitigations.count - completed
        
        var themeTotals: [RiskTheme: (black: Int, total: Int)] = [:]
        for theme in RiskTheme.allCases {
            themeTotals[theme] = (0, 0)
        }
        for event in events {
            var pair = themeTotals[event.theme] ?? (0, 0)
            pair.total += 1
            if event.classification == .blackSwan {
                pair.black += 1
            }
            themeTotals[event.theme] = pair
        }
        
        let themeStats = RiskTheme.allCases.compactMap { theme -> ThemeStat? in
            let pair = themeTotals[theme] ?? (0, 0)
            guard pair.total > 0 else { return nil }
            return ThemeStat(theme: theme, blackSwanCount: pair.black, totalCount: pair.total)
        }
        .sorted { $0.blackSwanCount > $1.blackSwanCount }
        
        let topTheme = themeStats.first(where: { $0.blackSwanCount > 0 })?.theme
            ?? themeStats.first?.theme
        
        let weeks = weekBuckets(from: events, now: now, calendar: calendar, count: 6)
        
        // Higher = more fragile. Weighted by Black Swan share, open actions, and theme concentration.
        let blackShare = Double(blackSwans.count) / Double(events.count)
        let openPressure = min(1, Double(open) / Double(max(allMitigations.count, 1)))
        let concentration: Double = {
            guard let top = themeStats.first, events.count > 0 else { return 0 }
            return Double(top.totalCount) / Double(events.count)
        }()
        let raw = (blackShare * 55) + (openPressure * 25) + (concentration * 20)
        let score = Int(raw.rounded())
        
        let summary: String
        if events.count < 3 {
            summary = String(localized: "Keep logging — patterns get useful after a handful of events.")
        } else if let topTheme {
            summary = String(localized: "Most exposure sits in \(topTheme.displayString). Open mitigations: \(open).")
        } else {
            summary = String(localized: "Black Swans logged: \(blackSwans.count). Close open mitigations to lower fragility.")
        }
        
        return FragilitySnapshot(
            eventCount: events.count,
            blackSwanCount: blackSwans.count,
            deliberateCount: deliberate.count,
            completedActions: completed,
            openActions: open,
            score: min(100, max(0, score)),
            topTheme: topTheme,
            themeStats: themeStats,
            recentWeeks: weeks,
            summaryLine: summary
        )
    }
    
    static func events(
        inLastDays days: Int,
        from events: [Swan],
        now: Date = .now,
        calendar: Calendar = .current
    ) -> [Swan] {
        guard let start = calendar.date(byAdding: .day, value: -days, to: now) else { return [] }
        return events.filter { $0.timestamp >= start }
    }
    
    private static func weekBuckets(
        from events: [Swan],
        now: Date,
        calendar: Calendar,
        count: Int
    ) -> [WeekBucket] {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: now) else { return [] }
        
        var buckets: [WeekBucket] = []
        for offset in (0..<count).reversed() {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -offset, to: interval.start),
                  let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else {
                continue
            }
            
            let inWeek = events.filter { $0.timestamp >= weekStart && $0.timestamp < weekEnd }
            buckets.append(
                WeekBucket(
                    weekStart: weekStart,
                    blackSwanCount: inWeek.filter { $0.classification == .blackSwan }.count,
                    deliberateCount: inWeek.filter { $0.classification == .deliberate }.count
                )
            )
        }
        return buckets
    }
}
