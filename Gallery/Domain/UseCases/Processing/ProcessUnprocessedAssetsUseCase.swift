//
//  ProcessUnprocessedAssetsUseCase.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import Foundation

final class ProcessUnprocessedAssetsUseCase {
    private enum Constants {
        static let targetSize: CGSize = CGSize(width: 224, height: 224)
    }
    
    private let photoLibraryService: PhotosRepository
    private let coreDataRepository: CoreDataRepository
    private let imageClassificationService: ImageClassificationService
    
    init(
        photoLibraryService: PhotosRepository,
        coreDataRepository: CoreDataRepository,
        imageClassificationService: ImageClassificationService
    ) {
        self.photoLibraryService = photoLibraryService
        self.coreDataRepository = coreDataRepository
        self.imageClassificationService = imageClassificationService
    }
    
    func execute(progressHandler: @escaping (Double) -> Void) async throws {
        async let allAssets = try await photoLibraryService
            .fetchAllImageAssets()
        async let processedAssets = try await coreDataRepository
            .fetchWithPredicate(nil)
        
        let (allAssetsSet, processedAssetsSet) = try await (Set(allAssets), Set(processedAssets))
        
        let unprocessedAssets = allAssetsSet.subtracting(processedAssetsSet)
        let totalAssets = unprocessedAssets.count
        
        print("TO process", unprocessedAssets.count)
        
        guard totalAssets > 0 else {
            progressHandler(1)
            return
        }
        
        for (index, asset) in unprocessedAssets.enumerated() {
            guard let image = try? await photoLibraryService.requestImage(
                for: asset,
                targetSize: Constants.targetSize
            ) else {
                print("Could not load image for asset with ID: \(asset.id)")
                continue
            }
            
            do {
                let classification = try await imageClassificationService.classify(image: image)
                
                var updatedAsset = asset
                updatedAsset.aiCategory = classification.confidence > 0.4 ? classification.label : nil
                
                try await coreDataRepository.saveImageAsset(updatedAsset)
                
                let progressValue = Double(index + 1) / Double(totalAssets)
                progressHandler(progressValue)
                print("Processed asset \(asset.id): \(classification.label)", progressValue)
            } catch {
                print("Error processing asset \(asset.id): \(error)")
            }
        }
    }
}
