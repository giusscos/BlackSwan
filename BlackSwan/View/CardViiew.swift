//
//  CardViiew.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 11/04/25.
//

import SwiftUI

struct CardViiew: View {
    var item: Swan = Swan(title: "Test", text: "Black Swan")
    
    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .foregroundStyle(RadialGradient(colors: [.secondary, .primary], center: .topLeading, startRadius: 10, endRadius: 700))
            .frame(maxHeight: 500)
            .overlay {
                VStack(alignment: .leading) {
                    Text(item.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(item.text)
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
    CardViiew()
        .padding()
}
