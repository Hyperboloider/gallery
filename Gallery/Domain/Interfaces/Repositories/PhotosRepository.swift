//
//  PhotosRepository.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import Photos
import Foundation
import UIKit

protocol PhotosRepository {
    func requestAuthorization() async -> PHAuthorizationStatus
    func fetchAllImageAssets() async throws -> [ImageAsset]
    func requestImage(for asset: ImageAsset, targetSize: CGSize) async throws -> UIImage
}
