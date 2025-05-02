//
//  EditSwanView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 11/04/25.
//

import SwiftUI
import SwiftData
import CoreML

struct EditSwanView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    enum Field: Hashable {
        case text
    }

    @Bindable var swan: Swan
    @State var probability: Int = 50
    @State var classificationResult: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                TextEditor(text: $swan.text)
                    .font(.title3)
                    .fontWeight(.medium)
                    .textEditorStyle(.plain)
                    .overlay (alignment: .topLeading) {
                        if swan.text.isEmpty {
                            Text("Description")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.tertiary)
                                .textEditorStyle(.plain)
                                .offset(x: 4, y: 8)
                        }
                    }
                    .padding(.vertical)

                Button {
                    saveChanges()
                } label: {
                    Label("Save Changes", systemImage: "square.and.arrow.down")
                        .labelStyle(.titleOnly)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.headline)
                        .foregroundStyle(.background)
                }
                .background(swan.text.isEmpty ? .secondary : .primary)
                .clipShape(Capsule())
                .disabled(swan.text.isEmpty)
                .frame(maxWidth: 400, alignment: .center)
            }
            .padding()
            .navigationTitle("Edit Swan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark.circle.fill")
                    }
                    .tint(.primary)
                }
            }
        }
    }

    func saveChanges() {
        if swan.text.isEmpty { return }
        
        let result = calculateProbability(swan.text)
        
        swan.classification = SwanClassification(rawValue: result ?? "") ?? .deliberate
        
        dismiss()
    }
    
    func calculateProbability(_ inputText: String) -> String? {
        do {
            let config = MLModelConfiguration()
            let model = try BlackSwanV250000Finance(configuration: config)
            let result = try model.prediction(text: inputText)
            
            return result.label
        } catch {
            print("Error calculating probability: \(error)")
            return nil
        }
    }
}

#Preview {
    // Create a dummy Swan in memory for the preview
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Swan.self, configurations: config)
    let sampleSwan = Swan(text: "Sample text details.")

    return EditSwanView(swan: sampleSwan)
        .modelContainer(container)
} 
