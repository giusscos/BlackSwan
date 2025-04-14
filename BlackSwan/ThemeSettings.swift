import SwiftUI

enum ColorThemePreference: String, Codable, CaseIterable, Identifiable {
    case standard = "standard"
    case classificationBased = "classificationBased"
    case custom = "custom"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .standard:
            "Standard"
        case .classificationBased:
            "Classification Based"
        case .custom:
            "Custom"
        }
    }
}

// Define default colors for the standard theme if needed elsewhere,
// otherwise, we can just use .primary and .secondary directly in views.
struct StandardThemeColors {
    static let primary: Color = .primary
    static let secondary: Color = .secondary
} 
