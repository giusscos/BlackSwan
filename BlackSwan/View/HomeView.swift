//
//  HomeView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 02/05/25.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(Store.self) private var store
    @Environment(\.modelContext) private var modelContext
    @Namespace private var namespace
    
    @State private var selectedClassification: SwanClassification? = nil
    @State private var sortOrder: SortOrder = .reverse
    @State private var manageSubscription = false
    @State private var displayAddSwanSheet = false
    
    @Query(sort: \Swan.timestamp, order: .reverse) private var allSwans: [Swan]
    
    private var swans: [Swan] {
        var filtered = allSwans
        if let classification = selectedClassification {
            filtered = filtered.filter { $0.classification == classification }
        }
        if sortOrder == .forward {
            filtered = filtered.sorted { $0.timestamp < $1.timestamp }
        }
        return filtered
    }
    
    private var snapshot: FragilitySnapshot {
        FragilityAnalytics.snapshot(from: allSwans)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if !allSwans.isEmpty {
                fragilityBanner
            }
            
            Text("On-device AI can make mistakes — check confidence and override when needed.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.vertical, 8)
            
            if !swans.isEmpty {
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(swans) { item in
                            NavigationLink {
                                SwanDetailsView(swan: item)
                                    .navigationTransition(.zoom(sourceID: item.id, in: namespace))
                            } label: {
                                CardView(swan: item)
                                    .frame(maxHeight: .infinity, alignment: .center)
                                    .matchedTransitionSource(id: item.id, in: namespace)
                                    .scrollTransition(axis: .horizontal) { content, phase in
                                        content
                                            .rotationEffect(.degrees(phase.value * 8))
                                            .scaleEffect(phase.isIdentity ? 1 : 0.9)
                                            .offset(y: phase.isIdentity ? 0 : 40)
                                            .blur(radius: phase.isIdentity ? 0 : 3)
                                    }
                                    .containerRelativeFrame(.horizontal)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.viewAligned)
            } else {
                RoundedRectangle(cornerRadius: 32)
                    .foregroundStyle(.regularMaterial)
                    .frame(maxHeight: 500)
                    .overlay {
                        VStack(spacing: 12) {
                            Text("No events yet")
                                .font(.headline)
                            
                            Text("Log a shock or a chosen risk. We’ll classify it, suggest protections, and track your fragility over time.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            NavigationLink {
                                PreMortemView()
                            } label: {
                                Label("Or run a pre-mortem", systemImage: "shield.lefthalf.filled")
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Black Swan")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    displayAddSwanSheet = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            
            ToolbarItemGroup(placement: .topBarLeading) {
                NavigationLink {
                    InsightsView()
                } label: {
                    Label("Fragility", systemImage: "chart.line.uptrend.xyaxis")
                }
                
                NavigationLink {
                    WeeklyReviewView()
                } label: {
                    Label("Review", systemImage: "calendar")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    NavigationLink {
                        PreMortemView()
                    } label: {
                        Label("Pre-mortem", systemImage: "shield.lefthalf.filled")
                    }
                    
                    Button {
                        MockData.insertSampleContent(into: modelContext)
                    } label: {
                        Label("Add mock data", systemImage: "wand.and.stars")
                    }
                    
                    if !allSwans.isEmpty {
                        Divider()
                        
                        Picker("Filter by Type", selection: $selectedClassification) {
                            Text("All")
                                .tag(Optional<SwanClassification>.none)
                            
                            ForEach(SwanClassification.allCases, id: \.self) { classification in
                                Text(classification.displayString)
                                    .tag(Optional(classification))
                            }
                        }
                        
                        Picker("Sort by Date", selection: $sortOrder) {
                            Text("Newest First")
                                .tag(SortOrder.reverse)
                            
                            Text("Oldest First")
                                .tag(SortOrder.forward)
                        }
                        
                        Divider()
                    }
                    
                    Button {
                        manageSubscription.toggle()
                    } label: {
                        Text("Manage subscription")
                    }
                } label: {
                    if #available(iOS 26, *) {
                        Label("Menu", systemImage: "ellipsis")
                    } else {
                        Label("Menu", systemImage: "ellipsis.circle")
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $displayAddSwanSheet) {
            EditSwanView()
        }
        .manageSubscriptionsSheet(isPresented: $manageSubscription, subscriptionGroupID: store.groupId)
    }
    
    private var fragilityBanner: some View {
        NavigationLink {
            InsightsView()
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Fragility \(snapshot.score)")
                        .font(.subheadline.weight(.semibold))
                    Text(snapshot.summaryLine)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environment(Store())
    }
}
