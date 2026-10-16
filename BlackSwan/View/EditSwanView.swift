//
//  EditSwanView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 11/04/25.
//

import SwiftUI
import SwiftData

struct EditSwanView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    enum Field: Hashable {
        case text
    }
    
    @FocusState private var focusedField: Field?

    var swan: Swan?
    
    @State private var text: String = ""
    @State private var isSaving = false
    @State private var saveError: String?
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                TextEditor(text: $text)
                    .textEditorStyle(.plain)
                    .font(.headline)
                    .focused($focusedField, equals: .text)
                    .overlay(alignment: .topLeading) {
                        if text.isEmpty {
                            Text("Describe what happened…")
                                .font(.headline)
                                .foregroundStyle(.secondary.opacity(0.5))
                                .offset(x: 5, y: 8)
                                .allowsHitTesting(false)
                        }
                    }
                
                if isSaving {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text(InsightService.isAvailable
                             ? "Classifying & generating insight…"
                             : "Classifying…")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 8)
                }
                
                if let saveError {
                    Text(saveError)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .padding()
            .navigationTitle(swan != nil ? Text("Edit event") : Text("Create event"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        if #available(iOS 26, *) {
                            Label("Close", systemImage: "xmark")
                        } else {
                            Label("Close", systemImage: "xmark.circle.fill")
                        }
                    }
                    .disabled(isSaving)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await save() }
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                }
                
                ToolbarItem(placement: .keyboard) {
                    Button {
                        focusedField = nil
                    } label: {
                        Label("Hide keyboard", systemImage: "keyboard.chevron.compact.down")
                    }
                }
            }
            .interactiveDismissDisabled(isSaving)
            .onAppear {
                focusedField = .text
                if let swan {
                    text = swan.text
                }
            }
        }
    }

    @MainActor
    private func save() async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        isSaving = true
        saveError = nil
        defer { isSaving = false }
        
        guard let result = ClassificationService.classify(trimmed) else {
            saveError = "Could not classify this event. Try again."
            return
        }
        
        let target: Swan
        if let existing = swan {
            existing.text = trimmed
            existing.apply(classification: result)
            existing.clearInsight()
            existing.theme = RiskTheme.infer(from: trimmed)
            target = existing
        } else {
            let created = Swan(text: trimmed)
            created.apply(classification: result)
            modelContext.insert(created)
            target = created
        }
        
        if let insight = await InsightService.generateInsight(
            for: trimmed,
            classification: result.classification,
            probability: result.probability
        ) {
            target.apply(insight: insight)
        }
        
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Swan.self, configurations: config)
    let sampleSwan = Swan(text: "Sample text details.")

    return EditSwanView(swan: sampleSwan)
        .modelContainer(container)
}
