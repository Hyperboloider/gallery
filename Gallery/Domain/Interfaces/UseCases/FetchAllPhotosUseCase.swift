//
//  FetchAllPhotosUseCase 2.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//

protocol FetchAllPhotosUseCase {
    func execute() async throws -> [ImageAsset]
}
