//
//  ImagesWithLocationsUseCase.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//

import Foundation
import Combine

final class ImagesWithLocationsUseCase {
    let readableStream: any ReadableStreamDataSource<ImageAsset>
    
    init(coreDataRepository: CoreDataRepository) {
        self.readableStream = coreDataRepository
            .fetchStreamWithPredicate(NSPredicate(format: "\(#keyPath(ImageEntity.locationLongitude)) != nil"))
    }
    
    func execute() -> AnyPublisher<[ImageAsset], Never> {
        readableStream.publisher
    }
}
