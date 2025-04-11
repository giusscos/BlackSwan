//
//  AddSwanView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 11/04/25.
//

import SwiftUI
import SwiftData

struct AddSwanView: View {
    enum Field: Hashable {
        case title
        case text
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State var title: String = ""
    @State var text: String = ""
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                TextField("Title", text: $title)
                    .lineLimit(1)
                    .font(.title)
                    .fontWeight(.bold)
                    .focused($focusedField, equals: .title)
                
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
                    .focused($focusedField, equals: .text)
                
                Button {
                    if title.isEmpty {
                        focusedField = .title
                    } else if text.isEmpty {
                        focusedField = .text
                    } else {
                        addSwan(title: title, text: text)
                    }
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
                .disabled(title.isEmpty && text.isEmpty)
            }
            .padding()
            //            .overlay(alignment: .bottom, content: {
            //                Color.clear
            //                    .background(.thickMaterial)
            //                    .frame(maxWidth: .infinity)
            //                    .mask(
            //                        LinearGradient(
            //                            gradient: Gradient(colors: [.black, .black, .clear, .clear, .clear, .clear, .clear, .clear]),
            //                            startPoint: .bottom,
            //                            endPoint: .top
            //                        )
            //                    )
            //
            //            })
            .toolbar {
                //                ToolbarItem(placement: .topBarLeading) {
                //                    Text(Date(), format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                //                        .fontWeight(.semibold)
                //                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .fontWeight(.semibold)
                            .font(.title)
                            .tint(.primary)
                    }
                }
                
                ToolbarItem(placement: .keyboard) {
                    Button {
                        focusedField = nil
                    } label: {
                        Text("Done")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                }
            }
        }
    }
    
    func addSwan(title: String, text: String) {
        if title.isEmpty && text.isEmpty { return }
        
        let newSwan = Swan(title: title, text: text, timestamp: Date())
        
        modelContext.insert(newSwan)
        
        dismiss()
    }
}

#Preview {
    NavigationStack {
        AddSwanView()
    }
}
