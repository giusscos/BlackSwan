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
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.headline)
                .foregroundStyle(.background)
                .background(text.isEmpty ? .secondary : .primary)
                .clipShape(Capsule())
                .disabled(text.isEmpty)
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
        
        calculateProbability(text)

        newSwan.timestamp = Date()
        
        newSwan.probability = probability
        
        newSwan.classification = SwanClassification(rawValue: classificationResult) ?? .deliberate

        modelContext.insert(newSwan)
        
        dismiss()
    }
    
    func calculateProbability(_ inputText: String) {
        do {
            let config = MLModelConfiguration()

            let modelText = try BlackSwanTextClassifier(configuration: config)
            
            let modelTabular = try BlackSwanTabularClassifier(configuration: config)
            
            let resultText = try modelText.prediction(text: inputText)
            let resultTabular = try modelTabular.prediction(text: inputText)
            
            classificationResult = resultText.label
            probability = Int(resultTabular.probability)
        } catch {
            print(error)
        }
    }
}

#Preview {
    NavigationStack {
        AddSwanView()
    }
}
