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
    
    init(swan: Swan) {
        self.swan = swan
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(swan.timestamp, format: .dateTime.day().month(.abbreviated).year(.twoDigits).hour().minute())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            Text(swan.text)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(8)
        .navigationTitle(swan.classification.displayString)
        .fullScreenCover(isPresented: $showingEditSheet) {
            EditSwanView(swan: swan)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
            
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    deleteEvent()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
    
    private func deleteEvent() {
        modelContext.delete(swan)
        
        dismiss()
    }
}

#Preview {
    SwanDetailsView(swan: Swan(text: "Lorem ipsum"))
}
