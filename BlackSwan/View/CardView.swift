//
//  CardView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 11/04/25.
//

import SwiftUI

struct CardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var swan: Swan
    
    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .foregroundStyle(themeManager.gradient(for: swan))
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
            .foregroundStyle(.white)
    }
}

#Preview {
    CardView(swan: Swan(text: "Black Swan"))
        .environmentObject(ThemeManager())
        .padding()
}
