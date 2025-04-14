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

    enum Field: Hashable {
        case text
    }

    @Bindable var swan: Swan

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
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.headline)
                .foregroundStyle(.background)
                .background(swan.text.isEmpty ? .secondary : .primary)
                .clipShape(Capsule())
                .disabled(swan.text.isEmpty)
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
        swan.timestamp = Date()
        dismiss()
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
