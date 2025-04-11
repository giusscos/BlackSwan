//
//  ContentView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 09/04/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Namespace var namespace
    
    @Query private var swans: [Swan]
    
    @State private var displayAddSwanSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if !swans.isEmpty {
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(swans) { item in
                                NavigationLink {
                                    
                                } label: {
                                    CardViiew(item: item)
                                        .frame(maxHeight: .infinity, alignment: .center)
                                        .matchedTransitionSource(id: item, in: namespace)
                                        .scrollTransition(
                                            axis: .horizontal
                                        ) { content, phase in
                                            content
                                                .rotationEffect(.degrees(phase.value * 3.5))
                                                .scaleEffect(phase.isIdentity ? 1 : 0.95)
                                                .offset(y: phase.isIdentity ? 0 : 50)
                                                .blur(radius: phase.isIdentity ? 0 : 3)
                                        }
                                        .containerRelativeFrame(.horizontal)
                                }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollIndicators(.hidden)
                    .scrollTargetBehavior(.viewAligned)
                } else {
                    RoundedRectangle(cornerRadius: 24)
                        .foregroundStyle(RadialGradient(colors: [.clear, .primary], center: .topLeading, startRadius: 10, endRadius: 700))
                        .frame(maxHeight: 600)
                        .overlay {
                            VStack {
                                Text("No contents yet")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Text("Click the add button to add your first content!")
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                            }
                            .foregroundStyle(.white)
                            .padding()
                        }
                        .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom, content: {
                Button {
                    displayAddSwanSheet = true
                } label: {
                    Label("Add", systemImage: "plus")
                        .labelStyle(.titleOnly)
                }
                .font(.headline)
                .foregroundStyle(.background)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.primary)
                .clipShape(Capsule())
            })
            .fullScreenCover(isPresented: $displayAddSwanSheet) {
                AddSwanView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Swan.self, inMemory: true)
}
