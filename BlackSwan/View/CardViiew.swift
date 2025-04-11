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
            .foregroundStyle(RadialGradient(colors: [.clear, .primary], center: .topLeading, startRadius: 10, endRadius: 700))
            .frame(maxHeight: 600)
            .overlay {
                VStack {
                    Text(item.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(item.text)
                        .font(.headline)
                }
            }
            .foregroundStyle(.white)
            .padding()
    }
}

#Preview {
    CardViiew()
        .padding()
}
