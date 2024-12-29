//
//  ImagesWithLocationsUseCase.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//

import Foundation
import Combine



final class ImagesWithLocationsUseCaseImplementation: ImagesWithLocationsUseCase {
    let readableStream: any ReadableStreamDataSource<ImageAsset>
    
    init(coreDataRepository: CoreDataRepository) {
        self.readableStream = coreDataRepository
            .fetchStreamWithPredicate(NSPredicate(format: "\(#keyPath(ImageEntity.locationLongitude)) != nil"))
    }
    
    func execute() -> AnyPublisher<[MapAssetAnnotation], Never> {
        readableStream
            .publisher
            .map { $0.compactMap(MapAssetAnnotation.init) }
            .eraseToAnyPublisher()
    }
}
