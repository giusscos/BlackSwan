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
                    .textEditorStyle(.plain)
                    .font(.headline)
                    .overlay (alignment: .topLeading) {
                        if text.isEmpty {
                            Text("Description")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.tertiary)
                                .textEditorStyle(.plain)
                                .offset(x: 5, y: 8)
                        }
                    }
            }
            .navigationTitle("Create Event")
            .padding(8)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .destructive) {
                        dismiss()
                    } label: {
                        if #available(iOS 26, *) {
                            Label("Close", systemImage: "xmark")
                        } else {
                            Label("Close", systemImage: "xmark.circle.fill")
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addSwan(text: text)
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }
                    .tint(.blue)
                    .disabled(text.isEmpty)
                }
            }
        }
    }
    
    func addSwan(text: String) {
        if text.isEmpty { return }
                
        let newSwan = Swan(text: text)
        
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
