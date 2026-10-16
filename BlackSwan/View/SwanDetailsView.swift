//
//  SwanDetailsView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 11/04/25.
//

import SwiftData
import SwiftUI

struct SwanDetailsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var swan: Swan
    
    @State private var showingEditSheet = false
    @State private var confirmDelete = false
    @State private var isRefreshingInsight = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(swan.timestamp, format: .dateTime.day().month(.abbreviated).year(.twoDigits).hour().minute())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    ConfidenceBadge(probability: swan.probability, isOverride: swan.isManualOverride)
                }
                
                Label(swan.theme.displayString, systemImage: swan.theme.systemImage)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                
                Text(swan.text)
                    .font(.headline)
                
                if !swan.explanation.isEmpty {
                    SectionCard(title: "Why this classification") {
                        Text(swan.explanation)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if !swan.mitigationItems.isEmpty {
                    SectionCard(title: "Ways to limit impact") {
                        if swan.mitigationItems.contains(where: \.isDone) {
                            Text("\(swan.completedMitigationCount)/\(swan.mitigationItems.count) done")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        ForEach(swan.mitigationItems) { item in
                            ChecklistRow(item: item) {
                                swan.toggleMitigation(id: item.id)
                            }
                        }
                    }
                }
                
                if swan.explanation.isEmpty {
                    Button {
                        Task { await refreshInsight() }
                    } label: {
                        Label(
                            isRefreshingInsight ? LocalizedStringKey("Generating…") : LocalizedStringKey("Generate insight & plan"),
                            systemImage: "sparkles"
                        )
                    }
                    .disabled(isRefreshingInsight)
                }
                
                Text("Classifications can be wrong. Override below if needed.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(swan.classification.displayString)
        .fullScreenCover(isPresented: $showingEditSheet) {
            EditSwanView(swan: swan)
        }
        .confirmationDialog("Delete this event?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                deleteEvent()
            }
            Button("Cancel", role: .cancel) {}
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Theme", selection: Binding(
                        get: { swan.theme },
                        set: { swan.theme = $0 }
                    )) {
                        ForEach(RiskTheme.allCases) { theme in
                            Label(theme.displayString, systemImage: theme.systemImage)
                                .tag(theme)
                        }
                    }
                    
                    Picker("Classification", selection: Binding(
                        get: { swan.classification },
                        set: { newValue in
                            swan.classification = newValue
                            swan.isManualOverride = true
                            swan.clearInsight()
                        }
                    )) {
                        ForEach(SwanClassification.allCases, id: \.self) { classification in
                            Text(classification.displayString)
                                .tag(classification)
                        }
                    }
                    
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Edit text", systemImage: "pencil")
                    }
                    
                    Button {
                        Task { await refreshInsight() }
                    } label: {
                        Label("Refresh insight", systemImage: "sparkles")
                    }
                } label: {
                    Label("Actions", systemImage: "ellipsis.circle")
                }
            }
            
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    confirmDelete = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
    
    @MainActor
    private func refreshInsight() async {
        isRefreshingInsight = true
        defer { isRefreshingInsight = false }
        
        if let insight = await InsightService.generateInsight(
            for: swan.text,
            classification: swan.classification,
            probability: swan.probability
        ) {
            swan.apply(insight: insight)
        }
    }
    
    private func deleteEvent() {
        modelContext.delete(swan)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        SwanDetailsView(swan: Swan(text: "Lorem ipsum"))
    }
}
