//
//  GalleryViewModelInput.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import Combine

struct GalleryViewModelInput {
    var groupingPreferencePublisher: AnyPublisher<ReactiveImagesDataSourceUseCase.GroupingPreference, Never>
}
