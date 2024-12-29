//
//  FetchAllPhotosUseCase.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import Foundation



final class FetchAllPhotosUseCaseImplementation: FetchAllPhotosUseCase {
    let photosRepository: PhotosRepository
    
    init(photosRepository: PhotosRepository) {
        self.photosRepository = photosRepository
    }
    
    func execute() async throws -> [ImageAsset] {
        try await photosRepository.fetchAllImageAssets()
    }
    
}
