//
//  GalleryViewModelInput.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import Combine

struct GalleryViewModelInput {
    var itemSelectedPublisher: AnyPublisher<ImageAsset, Never>
    var groupingPreferencePublisher: AnyPublisher<GroupingPreference, Never>
}
