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
                VStack(alignment: .leading) {
                    Text(swan.classification.displayString)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(swan.text)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .padding()
    }
}

#Preview {
    CardView(swan: Swan(text: "Black Swan"))
}
