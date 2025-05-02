//
//  AddSwanView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 11/04/25.
//

import CoreML
import SwiftUI
import SwiftData

struct AddSwanView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
        
    @State var text: String = ""
    @State var probability: Int = 50
    @State var classificationResult: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                TextEditor(text: $text)
                    .font(.title3)
                    .fontWeight(.medium)
                    .textEditorStyle(.plain)
                    .overlay (alignment: .topLeading) {
                        if text.isEmpty {
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
                    addSwan(text: text)
                } label: {
                    Label("Save", systemImage: "square.and.arrow.up")
                        .labelStyle(.titleOnly)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.headline)
                        .foregroundStyle(.background)
                }
                .background(text.isEmpty ? .secondary : .primary)
                .clipShape(Capsule())
                .disabled(text.isEmpty)
                .frame(maxWidth: 400, alignment: .center)
            }
            .padding()
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
    
    func addSwan(text: String) {
        if text.isEmpty { return }
                
        let newSwan = Swan(text: text, timestamp: Date())
        
        let result = calculateProbability(text)
        
        newSwan.timestamp = Date()
        
        newSwan.classification = SwanClassification(rawValue: result ?? "") ?? .deliberate

        modelContext.insert(newSwan)
        
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
    NavigationStack {
        AddSwanView()
    }
}
