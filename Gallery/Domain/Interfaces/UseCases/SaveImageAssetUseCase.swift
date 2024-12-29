//
//  SaveImageAssetUseCase 2.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//


protocol SaveImageAssetUseCase {
    func execute(asset: ImageAsset) async throws
}