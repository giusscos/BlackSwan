//
//  Swan.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 09/04/25.
//

import Foundation
import SwiftData

@Model
final class Swan {
    var id: UUID = UUID()
    var title: String = ""
    var text: String = ""
    var timestamp: Date = Date()
    
    init(id: UUID = UUID(), title: String, text: String, timestamp: Date = Date()) {
        self.id = id
        self.title = title
        self.text = text
        self.timestamp = timestamp
    }
}
