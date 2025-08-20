//
//  HomeView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 02/05/25.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Namespace var namespace
    
    @State private var selectedClassification: SwanClassification? = nil
    @State private var sortOrder: SortOrder = .reverse
    
    @State private var manageSubscription: Bool = false
    
    @Query(sort: \Swan.timestamp, order: .reverse) private var allSwans: [Swan]
    
    var swans: [Swan] {
        var filtered = allSwans
        if let classification = selectedClassification {
            filtered = filtered.filter { $0.classification == classification }
        }
        if sortOrder == .forward {
            filtered = filtered.sorted { $0.timestamp < $1.timestamp }
        }
        return filtered
    }
    
    @State private var displayAddSwanSheet: Bool = false
    
    var body: some View {
        VStack {
            Text("This app can make mistake")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(8)
            
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
                                    .scrollTransition(
                                        axis: .horizontal
                                    ) { content, phase in
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
                        VStack {
                            Text("No contents yet")
                                .font(.headline)
                            
                            Text("Click the add button to add your first content!")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    displayAddSwanSheet = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if !allSwans.isEmpty {
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
        .manageSubscriptionsSheet(isPresented: $manageSubscription, subscriptionGroupID: Store().groupId)
    }
}

#Preview {
    HomeView()
}
