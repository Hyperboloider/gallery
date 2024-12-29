//
//  FastViTService.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import CoreML
import Vision
import UIKit

enum ImageClassificationError: Error {
    case invalidImage
    case noResult
}

final class FastViTService: ImageClassificationService {
    private let model: VNCoreMLModel
    
    init() throws {
        let coreMLModel = try FastViTMA36F16(configuration: MLModelConfiguration()).model
        self.model = try VNCoreMLModel(for: coreMLModel)
    }
    
    func classify(image: UIImage) async throws -> ClassificationResult {
        guard let pixelBuffer = image.toCVPixelBuffer() else {
            throw ImageClassificationError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let results = request.results as? [VNClassificationObservation],
                      let topResult = results.first else {
                    continuation.resume(throwing: ImageClassificationError.noResult)
                    return
                }
                
                let classification = ClassificationResult(
                    label: topResult.identifier,
                    confidence: Double(topResult.confidence)
                )
                continuation.resume(returning: classification)
            }
            
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
