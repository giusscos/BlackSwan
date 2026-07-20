//
//  PreMortemView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 20/07/26.
//

import SwiftData
import SwiftUI

struct PreMortemView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PreMortem.timestamp, order: .reverse) private var saved: [PreMortem]
    
    @State private var worry = ""
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var selected: PreMortem?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Assume the painful surprise already happened. Then build buffers so the real version hurts less.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("What would hurt you if it happened next month?")
                        .font(.subheadline.weight(.semibold))
                    
                    TextField("e.g. My biggest client disappears overnight", text: $worry, axis: .vertical)
                        .lineLimit(3...5)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        Task { await generate() }
                    } label: {
                        if isGenerating {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Label("Run pre-mortem", systemImage: "shield.lefthalf.filled")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(worry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGenerating)
                    
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(14)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                if let selected {
                    planDetail(selected)
                }
                
                if !saved.isEmpty {
                    SectionCard(title: "Saved pre-mortems") {
                        ForEach(saved) { item in
                            Button {
                                self.selected = item
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.worry)
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(.primary)
                                            .lineLimit(2)
                                        Label(item.theme.displayString, systemImage: item.theme.systemImage)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            .buttonStyle(.plain)
                            
                            if item.id != saved.last?.id {
                                Divider()
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle("Pre-mortem")
    }
    
    @ViewBuilder
    private func planDetail(_ plan: PreMortem) -> some View {
        SectionCard(title: "If it already happened") {
            Text(plan.scenario)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        
        SectionCard(title: "Buffers to build") {
            if plan.bufferItems.isEmpty {
                Text("No buffers yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(plan.bufferItems) { item in
                    ChecklistRow(item: item) {
                        plan.toggleBuffer(id: item.id)
                    }
                }
            }
        }
    }
    
    @MainActor
    private func generate() async {
        let trimmed = worry.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }
        
        guard let plan = await InsightService.generatePreMortem(for: trimmed) else {
            errorMessage = "Could not generate a pre-mortem. Try again."
            return
        }
        
        let entry = PreMortem(worry: trimmed)
        entry.scenario = plan.scenario
        entry.theme = plan.theme
        entry.bufferItems = plan.buffers.map { MitigationItem(text: $0) }
        modelContext.insert(entry)
        selected = entry
        worry = ""
    }
}

#Preview {
    NavigationStack {
        PreMortemView()
    }
    .modelContainer(for: PreMortem.self, inMemory: true)
}
