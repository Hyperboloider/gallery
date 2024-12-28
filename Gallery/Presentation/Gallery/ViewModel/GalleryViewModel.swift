//
//  GalleryViewModel.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import Combine

final class GalleryViewModel {
    private let actions: GalleryViewModelActions
    private let processingUseCase: ProcessUnprocessedAssetsUseCase
    private let imagesDataSourceUseCase: ReactiveImagesDataSourceUseCase
    private let photosAccessAllowedSubject = CurrentValueSubject<Bool?, Never>(nil)
    private let processingProgressSubject = CurrentValueSubject<Double?, Never>(nil)
    
    init(
        actions: GalleryViewModelActions,
        processingUseCase: ProcessUnprocessedAssetsUseCase,
        imagesDataSourceUseCase: ReactiveImagesDataSourceUseCase
    ) {
        self.actions = actions
        self.processingUseCase = processingUseCase
        self.imagesDataSourceUseCase = imagesDataSourceUseCase
    }
    
    func transform(input: GalleryViewModelInput) async -> GalleryViewModelOutput {
        let authorizationStatus = await actions.requestPhotosAccess()
        photosAccessAllowedSubject.send(authorizationStatus == .authorized)
        
        Task {
            try? await processingUseCase.execute {
                self.processingProgressSubject.send($0)
            }
        }
        
        let snapshotPublisher = input
            .groupingPreferencePublisher
            .compactMap { [weak self] in
                self?.imagesDataSourceUseCase.createImagesDataSource(withGroupingStrategy: $0)
            }
            .switchToLatest()
            .eraseToAnyPublisher()
        
        return .init(
            isPhotosAccessAuthorized: compactSubject(photosAccessAllowedSubject),
            processingProgress: compactSubject(processingProgressSubject),
            snapshotPublisher: snapshotPublisher
        )
    }
    
    private func compactSubject<T, E>(_ subject: CurrentValueSubject<T?, E>) -> AnyPublisher<T, E> {
        subject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
}
