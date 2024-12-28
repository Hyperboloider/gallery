//
//  MapViewModel.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//

import Foundation
import Combine

final class MapViewModel {
    
    private let imagesWithLocationsUseCase: ImagesWithLocationsUseCase
    private let actions: MapViewModelActions
    private var bag = Set<AnyCancellable>()
    
    init(actions: MapViewModelActions, imagesWithLocationsUseCase: ImagesWithLocationsUseCase) {
        self.actions = actions
        self.imagesWithLocationsUseCase = imagesWithLocationsUseCase
    }
    
    func transform(input: MapViewModelInput) -> MapViewModelOutput {
        input
            .itemSelected
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] asset in
                actions.itemSelected(asset)
            }
            .store(in: &bag)
        
        return MapViewModelOutput(
            snapshotPublisher: imagesWithLocationsUseCase.execute()
        )
    }
    
}
