//
//  WeeklyReviewView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 20/07/26.
//

import SwiftData
import SwiftUI

struct WeeklyReviewView: View {
    @Query(sort: \Swan.timestamp, order: .reverse) private var allEvents: [Swan]
    @AppStorage("lastWeeklyReviewCompletedAt") private var lastReviewCompletedAt: Double = 0
    
    @State private var summary: WeeklyReviewSummary?
    @State private var isLoading = false
    
    private var weekEvents: [Swan] {
        FragilityAnalytics.events(inLastDays: 7, from: allEvents)
    }
    
    private var snapshot: FragilitySnapshot {
        FragilityAnalytics.snapshot(from: weekEvents)
    }
    
    private var openItems: [(event: Swan, item: MitigationItem)] {
        weekEvents.flatMap { event in
            event.mitigationItems.filter { !$0.isDone }.map { (event, $0) }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("A short look at the last 7 days — shocks logged, protections taken, one focus ahead.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 10) {
                    weekChip("Black Swans", "\(snapshot.blackSwanCount)")
                    weekChip("Deliberate", "\(snapshot.deliberateCount)")
                    weekChip("Open", "\(snapshot.openActions)")
                }
                
                if let summary {
                    SectionCard(title: "This week") {
                        Text(summary.headline)
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Focus")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text(summary.focus)
                                .font(.subheadline)
                        }
                        .padding(.top, 4)
                        
                        if !summary.wins.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Wins")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                ForEach(summary.wins, id: \.self) { win in
                                    Label(win, systemImage: "checkmark.seal")
                                        .font(.subheadline)
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                } else {
                    Button {
                        Task { await generate() }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Label("Generate weekly review", systemImage: "sparkles")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)
                }
                
                if !weekEvents.isEmpty {
                    SectionCard(title: "Events this week") {
                        ForEach(weekEvents) { event in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(event.classification.displayString)
                                        .font(.caption.weight(.semibold))
                                    Spacer()
                                    Label(event.theme.displayString, systemImage: event.theme.systemImage)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Text(event.text)
                                    .font(.subheadline)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 4)
                            
                            if event.id != weekEvents.last?.id {
                                Divider()
                            }
                        }
                    }
                }
                
                if !openItems.isEmpty {
                    SectionCard(title: "Close these next") {
                        ForEach(openItems.prefix(5), id: \.item.id) { pair in
                            ChecklistRow(item: pair.item) {
                                pair.event.toggleMitigation(id: pair.item.id)
                            }
                        }
                    }
                }
                
                if summary != nil {
                    Button("Mark review complete") {
                        lastReviewCompletedAt = Date().timeIntervalSince1970
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
                
                if lastReviewCompletedAt > 0 {
                    Text("Last completed \(Date(timeIntervalSince1970: lastReviewCompletedAt).formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
        }
        .navigationTitle("Weekly review")
        .task {
            if summary == nil, !weekEvents.isEmpty {
                await generate()
            }
        }
    }
    
    private func weekChip(_ title: LocalizedStringKey, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title3.weight(.bold))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    @MainActor
    private func generate() async {
        isLoading = true
        defer { isLoading = false }
        
        summary = await InsightService.generateWeeklyReview(
            blackSwanCount: snapshot.blackSwanCount,
            deliberateCount: snapshot.deliberateCount,
            completedActions: snapshot.completedActions,
            openActions: snapshot.openActions,
            topTheme: snapshot.topTheme
        )
    }
}

#Preview {
    NavigationStack {
        WeeklyReviewView()
    }
    .modelContainer(for: Swan.self, inMemory: true)
}
