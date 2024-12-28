//
//  MapViewModel.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//

import Foundation

final class MapViewModel {
    
    private let imagesWithLocationsUseCase: ImagesWithLocationsUseCase
    
    init(imagesWithLocationsUseCase: ImagesWithLocationsUseCase) {
        self.imagesWithLocationsUseCase = imagesWithLocationsUseCase
    }
    
    func transform(input: MapViewModelInput) -> MapViewModelOutput {
        return MapViewModelOutput(
            snapshotPublisher: imagesWithLocationsUseCase.execute()
        )
    }
    
}
