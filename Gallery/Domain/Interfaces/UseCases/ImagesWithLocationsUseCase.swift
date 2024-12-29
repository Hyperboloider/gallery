//
//  ImagesWithLocationsUseCase 2.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//


protocol ImagesWithLocationsUseCase {
    func execute() -> AnyPublisher<[MapAssetAnnotation], Never>
}