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
    
    @FocusState var focusedField: Field?

    var swan: Swan?
    
    @State private var text: String = ""
    
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
                                .offset(x: 4, y: 8)
                        }
                    }
            }
            .padding()
            .navigationTitle(swan != nil ? "Edit event" : "Create event")
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
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        save()
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }
                    .disabled(text.isEmpty)
                }
                
                ToolbarItem(placement: .keyboard) {
                    Button {
                        focusedField = .none
                    } label: {
                        Label("Hide keyboard", systemImage: "keyboard.chevron.compact.down")
                    }
                    .disabled(text.isEmpty)
                }
            }
            .onAppear() {
                focusedField = .text
                
                if let swan = swan {
                    text = swan.text
                }
            }
        }
    }

    func save() {
        if text.isEmpty { return }
            
        if let event = swan {
            event.text = text
            
            if let result = calculateProbability(text) {
                event.classification = SwanClassification(rawValue: result) ?? .deliberate
            }
            
            dismiss()
            
            return
        }
        
        let newEvent = Swan(text: text)
        
        if let result = calculateProbability(text) {
            newEvent.classification = SwanClassification(rawValue: result) ?? .deliberate
        }
        
        modelContext.insert(newEvent)
        
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
