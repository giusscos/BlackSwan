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
    @EnvironmentObject var themeManager: ThemeManager
    
    var swan: Swan
    
    @State private var showingEditSheet = false
    
    init(swan: Swan) {
        self.swan = swan
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
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
                
                Button("Edit") {
                    showingEditSheet = true
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .fontWeight(.semibold)
                .background(.ultraThinMaterial)
                .foregroundStyle(.primary)
                .clipShape(Capsule())
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.vertical)
            
            Text(swan.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            Text(swan.classification.displayString)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(swan.text)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarBackButtonHidden()
        .foregroundStyle(.white)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(themeManager.gradient(for: swan))
        .fullScreenCover(isPresented: $showingEditSheet) {
            EditSwanView(swan: swan)
        }
    }
}

#Preview {
    SwanDetailsView(swan: Swan(text: "Lorem ipsum"))
        .environmentObject(ThemeManager())
}
