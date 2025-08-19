//
//  Swan.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 09/04/25.
//

import Foundation
import SwiftData
import SwiftUI

enum SwanClassification: String, Codable, CaseIterable {
    case blackSwan = "blackSwan"
    case deliberate = "deliberate"

    var displayString: String {
        switch self {
        case .blackSwan:
            return "Black Swan"
        case .deliberate:
            return "Deliberate"
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
    
    init(text: String) {
        self.id = UUID()
        self.text = text
        self.timestamp = Date()
    }
}
