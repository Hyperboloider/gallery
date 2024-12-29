//
//  ClassifyImageUseCase 2.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//

import UIKit

protocol ClassifyImageUseCase {
    func execute(image: UIImage) async throws -> ClassificationResult
}
