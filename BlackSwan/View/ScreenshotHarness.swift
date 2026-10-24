//
//  ScreenshotHarness.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 16/10/26.
//

#if DEBUG
import SwiftData
import SwiftUI
import TipKit

/// Debug-only: opens one screen straight away, filled with sample data in the current language,
/// so App Store captures can be scripted. Launch with `-ScreenshotScreen <name>`.
struct ScreenshotHarness: View {
    enum Screen: String {
        case home, detail, fragility, review, premortem, demo, hook, paywall
    }

    static var requestedScreen: Screen? {
        UserDefaults.standard.string(forKey: "ScreenshotScreen").flatMap(Screen.init(rawValue:))
    }

    let screen: Screen

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Swan.timestamp, order: .reverse) private var swans: [Swan]
    @State private var isSeeded = false
    @State private var isHoldingPaywall = false

    var body: some View {
        Group {
            if isSeeded {
                content
            } else {
                Color(.systemBackground)
            }
        }
        .task {
            reseed()
            isSeeded = true
        }
    }

    @ViewBuilder
    private var content: some View {
        switch screen {
        case .home:
            NavigationStack { HomeView() }
        case .detail:
            NavigationStack {
                if let swan = swans.first {
                    SwanDetailsView(swan: swan)
                }
            }
        case .fragility:
            NavigationStack { InsightsView() }
        case .review:
            NavigationStack { WeeklyReviewView() }
        case .premortem:
            NavigationStack { PreMortemView(showsLatest: true) }
        case .demo:
            ConceptOnboardingView(hasCompletedOnboarding: .constant(false), initialPage: 2)
        case .hook:
            ConceptOnboardingView(hasCompletedOnboarding: .constant(false), initialPage: 0)
        case .paywall:
            PaywallView(isHoldingPaywall: $isHoldingPaywall)
        }
    }

    /// Sample text is stored in the language it was inserted in, so start fresh every launch.
    private func reseed() {
        try? modelContext.delete(model: Swan.self)
        try? modelContext.delete(model: PreMortem.self)
        MockData.insertSampleContent(into: modelContext)
        if UIDevice.current.userInterfaceIdiom == .pad {
            MockData.insertTabletExtras(into: modelContext)
        }
        try? modelContext.save()
        Tips.hideAllTipsForTesting()
        UserDefaults.standard.set(WhatsNewView.contentVersion, forKey: "lastSeenWhatsNewVersion")
    }
}
#endif
