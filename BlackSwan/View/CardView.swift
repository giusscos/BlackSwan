//
//  CardView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 11/04/25.
//

import SwiftUI

struct CardView: View {
    var swan: Swan
    
    var body: some View {
        RoundedRectangle(cornerRadius: 32)
            .foregroundStyle(.ultraThinMaterial)
            .frame(maxHeight: 500)
            .overlay {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(swan.classification.displayString)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer(minLength: 8)
                        
                        ConfidenceBadge(probability: swan.probability, isOverride: swan.isManualOverride)
                    }
                    
                    Label(swan.theme.displayString, systemImage: swan.theme.systemImage)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Text(swan.text)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .lineLimit(6)
                    
                    if !swan.explanation.isEmpty {
                        Text(swan.explanation)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }
                    
                    if !swan.mitigationItems.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Protections \(swan.completedMitigationCount)/\(swan.mitigationItems.count)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            ProgressView(value: swan.mitigationProgress)
                                .tint(.primary)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .padding()
    }
}

struct ConfidenceBadge: View {
    let probability: Int
    var isOverride: Bool = false
    
    private var label: String {
        if isOverride { return "Manual" }
        if probability < 55 { return "Uncertain · \(probability)%" }
        return "\(probability)%"
    }
    
    private var tint: Color {
        if isOverride { return .secondary }
        if probability < 55 { return .orange }
        if probability < 75 { return .yellow }
        return .green
    }
    
    var body: some View {
        Text(label)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(tint.opacity(0.18), in: Capsule())
            .foregroundStyle(tint == .yellow ? Color.primary : tint)
    }
}

#Preview {
    let swan = Swan(text: "Sudden market crash wiped out a concentrated position overnight.")
    swan.classification = .blackSwan
    swan.probability = 82
    swan.theme = .money
    swan.explanation = "An abrupt, high-impact loss that was difficult to foresee from routine volatility."
    swan.mitigationItems = [
        MitigationItem(text: "Build a cash buffer", isDone: true),
        MitigationItem(text: "Cap single-position risk")
    ]
    return CardView(swan: swan)
}
