//
//  GradientSlider.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 11/04/25.
//

import SwiftUI

struct GradientSlider: View {
    @Binding var value: Double // Expected range: 0.0 to 1.0
    var gradient: LinearGradient
    var thumbColor: Color = .white
    var thumbSize: CGFloat = 28

    @State private var isDragging = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Gradient Track
                Capsule()
                    .fill(gradient)
                    .frame(height: thumbSize * 0.75) // Make track slightly smaller than thumb

                // Thumb Indicator
                Circle()
                    .fill(thumbColor)
                    .frame(width: thumbSize, height: thumbSize)
                    .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1)) // Subtle border
                    .shadow(radius: isDragging ? 5 : 2)
                    .offset(x: calculateThumbOffset(geometry: geometry))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gestureValue in
                                isDragging = true
                                updateValue(with: gestureValue, geometry: geometry)
                            }
                            .onEnded { gestureValue in
                                isDragging = false
                                updateValue(with: gestureValue, geometry: geometry)
                            }
                    )
            }
            // Center the ZStack vertically if needed, adjust height
            .frame(height: thumbSize) // Ensure view has height for thumb
        }
        .frame(height: thumbSize) // Define the overall height for the GeometryReader
    }

    private func calculateThumbOffset(geometry: GeometryProxy) -> CGFloat {
        let trackWidth = geometry.size.width - thumbSize
        return CGFloat(value) * trackWidth
    }

    private func updateValue(with gesture: DragGesture.Value, geometry: GeometryProxy) {
        let trackWidth = geometry.size.width - thumbSize
        let dragLocationX = gesture.location.x - thumbSize / 2 // Adjust for thumb center
        let newValue = min(max(0, dragLocationX / trackWidth), 1) // Clamp between 0 and 1
        self.value = Double(newValue)
    }
}

// MARK: - Preview
struct GradientSlider_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            // Example Hue Slider
            GradientSlider(
                value: .constant(0.5),
                gradient: LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hue: 0, saturation: 1, brightness: 1),
                        Color(hue: 1/6, saturation: 1, brightness: 1),
                        Color(hue: 2/6, saturation: 1, brightness: 1),
                        Color(hue: 3/6, saturation: 1, brightness: 1),
                        Color(hue: 4/6, saturation: 1, brightness: 1),
                        Color(hue: 5/6, saturation: 1, brightness: 1),
                        Color(hue: 1, saturation: 1, brightness: 1)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )

            // Example Saturation Slider
            GradientSlider(
                value: .constant(0.3),
                gradient: LinearGradient(
                    gradient: Gradient(colors: [Color(hue: 0.6, saturation: 0, brightness: 0.8), Color(hue: 0.6, saturation: 1, brightness: 0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
             // Example Brightness Slider
            GradientSlider(
                value: .constant(0.7),
                gradient: LinearGradient(
                    gradient: Gradient(colors: [Color(hue: 0.9, saturation: 0.7, brightness: 0), Color(hue: 0.9, saturation: 0.7, brightness: 1)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
        .padding()
    }
} 
