//
//  SaveImageAssetUseCase.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import Foundation

final class SaveImageAssetUseCase {
    private let coreDataRepository: CoreDataRepository
    
    init(coreDataRepository: CoreDataRepository) {
        self.coreDataRepository = coreDataRepository
    }
    
    func execute(asset: ImageAsset) async throws {
        try await coreDataRepository.saveImageAsset(asset)
    }
}
