//
//  PhotosRepositoryImplementation.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import Foundation
import Photos
import UIKit

enum PhotosError: Error {
    case unauthorised
    case assetNotFound
}

final class PhotosRepositoryImplementation: PhotosRepository {
    func requestAuthorization() async -> PHAuthorizationStatus {
        await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    }
    
    func fetchAllImageAssets() async throws -> [ImageAsset] {
        guard PHPhotoLibrary.authorizationStatus() == .authorized else {
            throw PhotosError.unauthorised
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 0
        fetchOptions.includeHiddenAssets = false
        fetchOptions.includeAllBurstAssets = false
        fetchOptions.includeAssetSourceTypes = [.typeUserLibrary]
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let results = PHAsset.fetchAssets(with: fetchOptions)
        return results
            .objects(at: .init(integersIn: 0..<results.count))
            .map {
                ImageAsset(
                    id: $0.localIdentifier,
                    creationDate: $0.creationDate,
                    location: $0.location,
                    pixelWidth: $0.pixelWidth,
                    pixelHeight: $0.pixelHeight,
                    aiCategory: nil
                )
            }
    }
    
    func requestImage(for asset: String, targetSize: CGSize) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [asset], options: nil)
            guard let phAsset = fetchResult.firstObject else {
                continuation.resume(throwing: PhotosError.assetNotFound)
                return
            }
            
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .none
            
            PHImageManager.default().requestImage(
                for: phAsset,
                targetSize: targetSize,
                contentMode: .default,
                options: options
            ) { image, info in
                if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                } else if let image = image {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(throwing: PhotosError.assetNotFound)
                }
            }
        }
    }
}
