//
//  ClassifyImageUseCase.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import UIKit

final class ClassifyImageUseCase {
    private let imageClassificationService: ImageClassificationService
    
    init(imageClassificationService: ImageClassificationService) {
        self.imageClassificationService = imageClassificationService
    }
    
    func execute(image: UIImage) async throws -> ClassificationResult {
        return try await imageClassificationService.classify(image: image)
    }
}
