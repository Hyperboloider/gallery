//
//  ReactiveImagesDataSourceUseCase 2.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//

import Combine

protocol ReactiveImagesDataSourceUseCase {
    func createImagesDataSource(withGroupingStrategy groupingStrategy: GroupingPreference) -> AnyPublisher<[CategorizedImageSet], Never>
}
