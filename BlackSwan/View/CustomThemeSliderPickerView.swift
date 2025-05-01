//
//  CustomThemeSliderPickerView.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 11/04/25.
//

import SwiftUI

struct CustomThemeSliderPickerView: View {
    @Binding var primaryColor: Color
    @Binding var secondaryColor: Color
    
    @Environment(\.dismiss) var dismiss
    
    enum EditingColor: String, CaseIterable, Identifiable {
        case primary = "Primary"
        case secondary = "Secondary"
        var id: String { self.rawValue }
    }
    
    @State private var selectedColorType: EditingColor = .primary
    
    // HSB state for the currently edited color
    @State private var hue: Double = 0.0
    @State private var saturation: Double = 0.0
    @State private var brightness: Double = 0.0
    
    // A dummy Swan for the preview card
    private let previewSwan = Swan(text: "Custom Theme")

    // Define gradients for the sliders
    private var hueGradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [
            Color(hue: 0, saturation: 1, brightness: 1),
            Color(hue: 1/6, saturation: 1, brightness: 1),
            Color(hue: 2/6, saturation: 1, brightness: 1),
            Color(hue: 3/6, saturation: 1, brightness: 1),
            Color(hue: 4/6, saturation: 1, brightness: 1),
            Color(hue: 5/6, saturation: 1, brightness: 1),
            Color(hue: 1, saturation: 1, brightness: 1)
        ]), startPoint: .leading, endPoint: .trailing)
    }

    private var saturationGradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [
            Color(hue: hue, saturation: 0, brightness: brightness),
            Color(hue: hue, saturation: 1, brightness: brightness)
        ]), startPoint: .leading, endPoint: .trailing)
    }

    private var brightnessGradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [
            Color(hue: hue, saturation: saturation, brightness: 0),
            Color(hue: hue, saturation: saturation, brightness: 1)
        ]), startPoint: .leading, endPoint: .trailing)
    }

    // Extracted subviews
    private var previewCard: some View {
        CardView(swan: previewSwan)
            .scaleEffect(0.8)
            .padding(.vertical)
    }

    private var colorControl: some View {
        Picker("Editing Color", selection: $selectedColorType) {
            ForEach(EditingColor.allCases) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    private var sliderControls: some View {
        VStack(alignment: .leading) {
            Text("Hue").font(.caption)
            GradientSlider(value: $hue, gradient: hueGradient)
            
            Text("Saturation").font(.caption)
            GradientSlider(value: $saturation, gradient: saturationGradient)
            
            Text("Brightness").font(.caption)
            GradientSlider(value: $brightness, gradient: brightnessGradient)
        }
        .padding()
    }

    var body: some View {
        NavigationView {
            VStack {
                previewCard
                colorControl
                sliderControls
                Spacer() // Push controls up
            }
            .navigationTitle("Custom Colors")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear(perform: updateHSBState)
            .onChange(of: selectedColorType) { _, _ in updateHSBState() }
            .onChange(of: [hue, saturation, brightness]) { _, _ in updateBoundColor() }
        }
    }
    
    // Update the HSB sliders based on the selected bound color
    private func updateHSBState() {
        let colorToEdit = (selectedColorType == .primary) ? primaryColor : secondaryColor
        let components = colorToEdit.hsb
        hue = components.hue
        saturation = components.saturation
        brightness = components.brightness
    }
    
    // Update the bound color (primary or secondary) based on the HSB sliders
    private func updateBoundColor() {
        let newColor = Color(hue: hue, saturation: saturation, brightness: brightness)
        if selectedColorType == .primary {
            primaryColor = newColor
        } else {
            secondaryColor = newColor
        }
    }
}

// Extension to get HSB components from Color
// Note: This is a simplified version. Color conversion can be complex.
extension Color {
    var hsb: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        UIColor(self).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (h, s, b, a)
    }
}

// Preview needs bindings
struct CustomThemeSliderPickerView_Previews: PreviewProvider {
    static var previews: some View {
        CustomThemeSliderPickerView(
            primaryColor: .constant(.blue),
            secondaryColor: .constant(.cyan)
        )
    }
} 
