//
//  ImageClassificationService.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import Foundation
import UIKit

protocol ImageClassificationService {
    func classify(image: UIImage) async throws -> ClassificationResult
}
