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
            return String(localized: "Black Swan")
        case .deliberate:
            return String(localized: "Deliberate")
        }
    }
}

enum RiskTheme: String, Codable, CaseIterable, Identifiable {
    case money
    case work
    case health
    case relationships
    case other
    
    var id: String { rawValue }
    
    var displayString: String {
        switch self {
        case .money: return String(localized: "Money")
        case .work: return String(localized: "Work")
        case .health: return String(localized: "Health")
        case .relationships: return String(localized: "Relationships")
        case .other: return String(localized: "Other")
        }
    }
    
    var systemImage: String {
        switch self {
        case .money: return "dollarsign.circle.fill"
        case .work: return "briefcase.fill"
        case .health: return "heart.fill"
        case .relationships: return "person.2.fill"
        case .other: return "circle.grid.cross.fill"
        }
    }
    
    static func infer(from text: String) -> RiskTheme {
        let lower = text.lowercased()
        // English plus the app's other languages (de, es, fr, it).
        let moneyKeys = ["money", "cash", "invest", "stock", "market", "debt", "bank", "salary", "rent", "price", "loss", "finance", "portfolio", "crypto",
                         "geld", "aktie", "schulden", "miete", "gehalt", "dinero", "deuda", "banco", "alquiler", "sueldo", "bolsa",
                         "argent", "dette", "banque", "loyer", "salaire", "bourse", "soldi", "debito", "banca", "affitto", "stipendio", "borsa", "mercato"]
        let workKeys = ["job", "work", "boss", "client", "career", "layoff", "freelance", "business", "startup", "office",
                        "arbeit", "chef", "kunde", "kündigung", "trabajo", "jefe", "cliente", "despido", "empresa",
                        "travail", "patron", "emploi", "licenciement", "entreprise", "lavoro", "capo", "licenziamento", "azienda", "ufficio"]
        let healthKeys = ["health", "sick", "hospital", "doctor", "injury", "mental", "burnout", "illness",
                          "gesundheit", "krank", "arzt", "krankenhaus", "salud", "enfermo", "médico", "lesión",
                          "santé", "malade", "hôpital", "médecin", "blessure", "salute", "malato", "ospedale", "medico", "infortunio"]
        let relationshipKeys = ["partner", "spouse", "family", "friend", "relationship", "divorce", "breakup", "kids",
                                "familie", "freund", "scheidung", "kinder", "pareja", "familia", "amigo", "divorcio", "hijos",
                                "famille", "amie", "divorce", "enfants", "couple", "famiglia", "amico", "divorzio", "figli", "compagno"]
        
        func score(_ keys: [String]) -> Int {
            keys.reduce(0) { $0 + (lower.contains($1) ? 1 : 0) }
        }
        
        let ranked: [(RiskTheme, Int)] = [
            (.money, score(moneyKeys)),
            (.work, score(workKeys)),
            (.health, score(healthKeys)),
            (.relationships, score(relationshipKeys))
        ]
        
        return ranked.max(by: { $0.1 < $1.1 }).flatMap { $0.1 > 0 ? $0.0 : nil } ?? .other
    }
}

struct MitigationItem: Codable, Identifiable, Equatable, Hashable {
    var id: UUID
    var text: String
    var isDone: Bool
    
    init(id: UUID = UUID(), text: String, isDone: Bool = false) {
        self.id = id
        self.text = text
        self.isDone = isDone
    }
}

@Model
final class Swan {
    var id: UUID = UUID()
    var text: String = ""
    var timestamp: Date = Date()
    
    /// Classifier confidence for the current label, 0...100.
    var probability: Int = 50
    var classification: SwanClassification = SwanClassification.deliberate
    
    /// On-device Foundation Model explanation (empty when unavailable).
    var explanation: String = ""
    /// JSON-encoded `[MitigationItem]`.
    var mitigationsJSON: String = "[]"
    var isManualOverride: Bool = false
    var themeRaw: String = RiskTheme.other.rawValue
    
    var theme: RiskTheme {
        get { RiskTheme(rawValue: themeRaw) ?? .other }
        set { themeRaw = newValue.rawValue }
    }
    
    var mitigationItems: [MitigationItem] {
        get {
            guard let data = mitigationsJSON.data(using: .utf8),
                  let items = try? JSONDecoder().decode([MitigationItem].self, from: data) else {
                return []
            }
            return items
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let string = String(data: data, encoding: .utf8) {
                mitigationsJSON = string
            } else {
                mitigationsJSON = "[]"
            }
        }
    }
    
    var completedMitigationCount: Int {
        mitigationItems.filter(\.isDone).count
    }
    
    var mitigationProgress: Double {
        let items = mitigationItems
        guard !items.isEmpty else { return 0 }
        return Double(items.filter(\.isDone).count) / Double(items.count)
    }
    
    init(text: String) {
        self.id = UUID()
        self.text = text
        self.timestamp = Date()
        self.themeRaw = RiskTheme.infer(from: text).rawValue
    }
    
    func apply(classification result: ClassificationResult) {
        classification = result.classification
        probability = result.probability
        isManualOverride = false
    }
    
    func apply(insight: EventInsight) {
        explanation = insight.explanation
        mitigationItems = insight.mitigations.map { MitigationItem(text: $0) }
        if let theme = insight.theme {
            self.theme = theme
        }
    }
    
    func clearInsight() {
        explanation = ""
        mitigationItems = []
    }
    
    func toggleMitigation(id: UUID) {
        var items = mitigationItems
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].isDone.toggle()
        mitigationItems = items
    }
}

@Model
final class PreMortem {
    var id: UUID = UUID()
    var worry: String = ""
    var scenario: String = ""
    /// JSON-encoded `[MitigationItem]` used as buffers / prep actions.
    var buffersJSON: String = "[]"
    var timestamp: Date = Date()
    var themeRaw: String = RiskTheme.other.rawValue
    
    var theme: RiskTheme {
        get { RiskTheme(rawValue: themeRaw) ?? .other }
        set { themeRaw = newValue.rawValue }
    }
    
    var bufferItems: [MitigationItem] {
        get {
            guard let data = buffersJSON.data(using: .utf8),
                  let items = try? JSONDecoder().decode([MitigationItem].self, from: data) else {
                return []
            }
            return items
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let string = String(data: data, encoding: .utf8) {
                buffersJSON = string
            } else {
                buffersJSON = "[]"
            }
        }
    }
    
    init(worry: String) {
        self.id = UUID()
        self.worry = worry
        self.timestamp = Date()
        self.themeRaw = RiskTheme.infer(from: worry).rawValue
    }
    
    func toggleBuffer(id: UUID) {
        var items = bufferItems
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].isDone.toggle()
        bufferItems = items
    }
}
