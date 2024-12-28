//
//  FetchImageAsynchronouslyUseCase.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//

import Foundation
import UIKit

final class FetchImageAsynchronouslyUseCase {
    let photosRepository: PhotosRepository
    
    init(photosRepository: PhotosRepository) {
        self.photosRepository = photosRepository
    }
    
    func execute(requestedId: String, targetSize: CGSize) async throws -> UIImage {
        try await photosRepository.requestImage(for: requestedId, targetSize: targetSize)
    }
}
