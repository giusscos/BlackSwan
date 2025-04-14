//
//  Swan.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 09/04/25.
//

import Foundation
import SwiftData
import SwiftUI

enum SwanClassification: String, Codable {
    case blackSwan = "black_swan"
    case deliberate = "deliberate"

    var displayString: String {
        switch self {
        case .blackSwan:
            return "Black Swan"
        case .deliberate:
            return "Deliberate"
        }
    }

    // Define colors for each classification
    var primaryColor: Color {
        switch self {
        case .blackSwan:
            return .black // Or a very dark gray
        case .deliberate:
            return Color.blue // Or another distinct color
        }
    }

    var secondaryColor: Color {
        switch self {
        case .blackSwan:
            return Color(white: 0.15) // Dark gray
        case .deliberate:
            return Color.cyan // Lighter blue/teal
        }
    }
}

@Model
final class Swan {
    var id: UUID = UUID()
    var text: String = ""
    var timestamp: Date = Date()
    
    var probability: Int = 50
    var classification: SwanClassification = SwanClassification.deliberate
    
    init(id: UUID = UUID(), text: String, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
    }
}
