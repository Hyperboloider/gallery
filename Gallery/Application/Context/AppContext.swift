//
//  AppContext.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import Foundation

final class AppContext {
    func makeGallerySceneContext() -> GallerySceneContext {
        let dependencies = GallerySceneContext.Dependencies()
        return GallerySceneContext(dependencies: dependencies)
    }
}

final class GallerySceneContext {
    // MARK: - Dependencies
    struct Dependencies {
        
    }
    
    private let dependencies: Dependencies
    private let photosRepository = PhotosRepositoryImplementation()
    private let imageClassificationService = try! FastViTService()
    private let coreDataManager = CoreDataManager()
    private lazy var coreDateRepository = CoreDataRepositoryImplementation(
        persistentContextProvider: coreDataManager
    )
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Use Cases
    lazy var processingUseCase = ProcessUnprocessedAssetsUseCase(
        photoLibraryService: photosRepository,
        coreDataRepository: coreDateRepository,
        imageClassificationService: imageClassificationService
    )
    
    lazy var imagesDataSourceUseCase = ReactiveImagesDataSourceUseCase(
        coreDataRepository: coreDateRepository
    )
    
    // MARK: - Navigation
    
    func makeGalleryCoordinator(navigationController: UINavigationController) -> GalleryCoordinator {
        return GalleryCoordinator(navigationController: navigationController, dependancies: self)
    }
}

extension GallerySceneContext: GalleryCoordinatorDependencies {
    func makeGalleryViewModel() -> GalleryViewModel {
        let actions = GalleryViewModelActions(requestPhotosAccess: photosRepository.requestAuthorization)
        return GalleryViewModel(
            actions: actions,
            processingUseCase: processingUseCase,
            imagesDataSourceUseCase: imagesDataSourceUseCase
        )
    }
    
    func makeGalleryViewController() -> UIViewController {
        let viewModel = makeGalleryViewModel()
        let viewController = GalleryViewController(viewModel: viewModel)
        return viewController
    }
}

import UIKit

protocol GalleryCoordinatorDependencies {
    func makeGalleryViewController() -> UIViewController
}

final class GalleryCoordinator: Coordinator {
    
    private let dependancies: GalleryCoordinatorDependencies
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController, dependancies: GalleryCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependancies = dependancies
    }
    
    func start() {
        let viewController = dependancies.makeGalleryViewController()
        navigationController?.pushViewController(viewController, animated: false)
    }
    
}
