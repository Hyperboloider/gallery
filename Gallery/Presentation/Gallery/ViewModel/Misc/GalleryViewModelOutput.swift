//
//  GalleryViewModelOutput.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import Combine

struct GalleryViewModelOutput {
    var isPhotosAccessAuthorized: AnyPublisher<Bool, Never>
    var processingProgress: AnyPublisher<Double, Never>
    var snapshotPublisher: AnyPublisher<[CategorizedGridItems], Never>
}
