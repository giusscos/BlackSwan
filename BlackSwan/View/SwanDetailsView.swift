//
//  SwanDetailsView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 11/04/25.
//

import SwiftUI

struct SwanDetailsView: View {
    var swan: Swan = Swan(title: "Test 1", text: "Lorem ipsum")
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(Date(), format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            Text(swan.title)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(swan.text)
                .font(.headline)
        }
        .navigationBarBackButtonHidden()
        .foregroundStyle(.white)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(RadialGradient(colors: [.secondary, .primary], center: .topLeading, startRadius: 10, endRadius: 700))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
                    .tint(.white)
            }
        }
    }
}

#Preview {
    SwanDetailsView()
}
