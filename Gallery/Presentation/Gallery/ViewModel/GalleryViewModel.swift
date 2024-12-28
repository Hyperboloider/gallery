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
    private let imageUseCase: FetchImageAsynchronouslyUseCase
    private let photosAccessAllowedSubject = CurrentValueSubject<Bool?, Never>(nil)
    private let processingProgressSubject = CurrentValueSubject<Double?, Never>(nil)
    private var bag = Set<AnyCancellable>()
    
    init(
        actions: GalleryViewModelActions,
        processingUseCase: ProcessUnprocessedAssetsUseCase,
        imagesDataSourceUseCase: ReactiveImagesDataSourceUseCase,
        imageUseCase: FetchImageAsynchronouslyUseCase
    ) {
        self.actions = actions
        self.processingUseCase = processingUseCase
        self.imagesDataSourceUseCase = imagesDataSourceUseCase
        self.imageUseCase = imageUseCase
    }
    
    func transform(input: GalleryViewModelInput) async -> GalleryViewModelOutput {
        input
            .itemSelectedPublisher
            .sink { [unowned self] asset in
                actions.itemSelected(asset)
            }
            .store(in: &bag)
        
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
            .map { [unowned self] categorizedImageSets in
                categorizedImageSets
                    .map { set in
                        CategorizedGridItems(
                            category: set.category,
                            models: set.images.map {
                                DetailsViewModel(imageAsset: $0, imageUseCase: imageUseCase, showsDetails: false)
                            }
                        )
                    }
            }
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
