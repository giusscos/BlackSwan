//
//  InsightsView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 20/07/26.
//

import Charts
import SwiftData
import SwiftUI

struct InsightsView: View {
    @Query(sort: \Swan.timestamp, order: .reverse) private var events: [Swan]
    
    private var snapshot: FragilitySnapshot {
        FragilityAnalytics.snapshot(from: events)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                scoreHeader
                
                Text(snapshot.summaryLine)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                statsRow
                
                if !snapshot.themeStats.isEmpty {
                    SectionCard(title: "Exposure by theme") {
                        VStack(spacing: 10) {
                            ForEach(snapshot.themeStats) { stat in
                                themeRow(stat)
                            }
                        }
                    }
                }
                
                if snapshot.recentWeeks.contains(where: { $0.blackSwanCount + $0.deliberateCount > 0 }) {
                    SectionCard(title: "Recent weeks") {
                        Chart(snapshot.recentWeeks) { week in
                            BarMark(
                                x: .value("Week", week.weekStart, unit: .weekOfYear),
                                y: .value("Black Swans", week.blackSwanCount)
                            )
                            .foregroundStyle(Color.primary.opacity(0.85))
                            
                            BarMark(
                                x: .value("Week", week.weekStart, unit: .weekOfYear),
                                y: .value("Deliberate", week.deliberateCount)
                            )
                            .foregroundStyle(Color.secondary.opacity(0.45))
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .weekOfYear)) { _ in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                            }
                        }
                        .frame(height: 180)
                        
                        HStack(spacing: 16) {
                            legendDot(color: .primary.opacity(0.85), title: "Black Swan")
                            legendDot(color: .secondary.opacity(0.45), title: "Deliberate")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
                
                if snapshot.openActions > 0 {
                    SectionCard(title: "Open protections") {
                        Text("Open mitigations across your events: \(snapshot.openActions). Closing them lowers fragility.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle("Fragility")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var scoreHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Fragility score")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text("\(snapshot.score)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                Text("/ 100")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: Double(snapshot.score), total: 100)
                .tint(scoreColor)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    private var scoreColor: Color {
        switch snapshot.score {
        case ..<35: return .green
        case ..<65: return .orange
        default: return .red
        }
    }
    
    private var statsRow: some View {
        HStack(spacing: 10) {
            statChip(title: "Events", value: "\(snapshot.eventCount)")
            statChip(title: "Black Swans", value: "\(snapshot.blackSwanCount)")
            statChip(title: "Actions done", value: "\(snapshot.completedActions)")
        }
    }
    
    private func statChip(title: LocalizedStringKey, value: String) -> some View {
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
    
    private func themeRow(_ stat: ThemeStat) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(stat.theme.displayString, systemImage: stat.theme.systemImage)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text("\(stat.blackSwanCount)/\(stat.totalCount)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: Double(stat.blackSwanCount), total: Double(max(stat.totalCount, 1)))
                .tint(.primary)
        }
    }
    
    private func legendDot(color: Color, title: LocalizedStringKey) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(title)
        }
    }
}

#Preview {
    NavigationStack {
        InsightsView()
    }
    .modelContainer(for: Swan.self, inMemory: true)
}
