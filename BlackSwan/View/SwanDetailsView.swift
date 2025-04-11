//
//  SwanDetailsView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 11/04/25.
//

import SwiftUI
import SwiftData

struct SwanDetailsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var swan: Swan
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedText: String
    
    init(swan: Swan) {
        self.swan = swan
        _editedTitle = State(initialValue: swan.title)
        _editedText = State(initialValue: swan.text)
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                if isEditing {
                    Button(role: .destructive) {
                        modelContext.delete(swan)
                        dismiss()
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .labelStyle(.titleOnly)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .fontWeight(.semibold)
                    .background(.red)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                } else {
                    Button {
                        dismiss()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .fontWeight(.semibold)
                    .foregroundStyle(.background)
                    .background(.primary)
                    .clipShape(Capsule())
                }
                
                Group {
                    if isEditing {
                        Button("Done") {
                            saveChanges()
                            withAnimation {
                                isEditing = false
                            }
                        }
                    } else {
                        Button("Edit") {
                            withAnimation {
                                isEditing = true
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .fontWeight(.semibold)
                .foregroundStyle(.background)
                .background(.primary)
                .clipShape(Capsule())
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.vertical)
            
            Text(swan.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            if isEditing {
                TextField("Title", text: $editedTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                TextEditor(text: $editedText)
                    .font(.headline)
                    .textEditorStyle(.plain)
                
            } else {
                Text(swan.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(swan.text)
                    .font(.headline)
            }
        }
        .navigationBarBackButtonHidden()
        .foregroundStyle(.white)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(RadialGradient(colors: [.secondary, .primary], center: .topLeading, startRadius: 10, endRadius: 700))
    }
    
    private func saveChanges() {
        swan.title = editedTitle
        swan.text = editedText
        swan.timestamp = Date()
    }
}

#Preview {
    SwanDetailsView(swan: Swan(title: "Test 1", text: "Lorem ipsum"))
}
