//
//  ChecklistRow.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 20/07/26.
//

import SwiftUI

struct ChecklistRow: View {
    let item: MitigationItem
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isDone ? Color.green : Color.secondary)
                    .font(.title3)
                
                Text(item.text)
                    .font(.subheadline)
                    .foregroundStyle(item.isDone ? .secondary : .primary)
                    .strikethrough(item.isDone)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.isDone ? Text("Completed: \(item.text)") : Text("Mark done: \(item.text)"))
    }
}

struct SectionCard<Content: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            content
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
