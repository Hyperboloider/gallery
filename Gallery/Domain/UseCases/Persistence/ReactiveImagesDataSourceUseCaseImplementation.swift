//
//  ReactiveImagesDataSourceUseCase.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import Foundation
import Combine



final class ReactiveImagesDataSourceUseCaseImplementation: ReactiveImagesDataSourceUseCase {
    let readableStream: any ReadableStreamDataSource<ImageAsset>
    
    init(coreDataRepository: CoreDataRepository) {
        self.readableStream = coreDataRepository.fetchStreamWithPredicate(nil)
    }
    
    func createImagesDataSource(withGroupingStrategy groupingStrategy: GroupingPreference) -> AnyPublisher<[CategorizedImageSet], Never> {
        readableStream
            .publisher
            .map { self.map(snapshot: $0, strategy: groupingStrategy) }
            .map { $0.sorted(by: { $0.category < $1.category }) }
            .eraseToAnyPublisher()
    }
    
    private func map(snapshot: [ImageAsset], strategy: GroupingPreference) -> [CategorizedImageSet] {
        let dict = switch strategy {
        case .month:
            Dictionary(grouping: snapshot) { asset in
                guard let date = asset.creationDate else { return "Unknown Date" }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM"
                return formatter.string(from: date)
            }
        case .category:
            Dictionary(grouping: snapshot) { asset in
                asset.aiCategory ?? "Other"
            }
        }
        return dict.map { key, value in
            CategorizedImageSet(category: key, images: value)
        }
    }

}
