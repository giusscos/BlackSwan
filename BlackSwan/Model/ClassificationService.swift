//
//  ClassificationService.swift
//  BlackSwan
//
//  Created by Giuseppe Cosenza on 20/07/26.
//

import CoreML
import Foundation
import NaturalLanguage

struct ClassificationResult: Sendable {
    let classification: SwanClassification
    /// Confidence for the chosen label, 0...100.
    let probability: Int
    let rawLabel: String
}

enum ClassificationService {
    private static let model: BlackSwanV250000Finance? = {
        do {
            return try BlackSwanV250000Finance(configuration: MLModelConfiguration())
        } catch {
            print("Failed to load Core ML model: \(error)")
            return nil
        }
    }()
    
    private static let languageModel: NLModel? = {
        guard let model else { return nil }
        return try? NLModel(mlModel: model.model)
    }()
    
    /// Maps Create ML labels (`blackSwan` / `noBlackSwan`) onto app classifications.
    static func mapLabel(_ rawLabel: String) -> SwanClassification {
        switch rawLabel {
        case "blackSwan":
            return .blackSwan
        case "noBlackSwan", "deliberate":
            return .deliberate
        default:
            return .deliberate
        }
    }
    
    static func classify(_ text: String) -> ClassificationResult? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let model else { return nil }
        
        do {
            let prediction = try model.prediction(text: trimmed)
            let label = prediction.label
            let classification = mapLabel(label)
            
            let confidence = languageModel?
                .predictedLabelHypotheses(for: trimmed, maximumCount: 2)[label]
                ?? 0.7
            let probability = Int((confidence * 100).rounded())
            
            return ClassificationResult(
                classification: classification,
                probability: max(0, min(100, probability)),
                rawLabel: label
            )
        } catch {
            print("Classification failed: \(error)")
            return nil
        }
    }
}
