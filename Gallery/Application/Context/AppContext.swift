//
//  AppContext.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import Foundation

final class AppContext {
    func makeTabbarContext() -> TabBarSceneContext {
        TabBarSceneContext()
    }
}

final class GallerySceneContext {
    // MARK: - Dependencies
    struct Dependencies {
        let photosRepository: PhotosRepository
        let imageClassificationService: ImageClassificationService
        let coreDateRepository: CoreDataRepository
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Use Cases
    lazy var processingUseCase = ProcessUnprocessedAssetsUseCase(
        photoLibraryService: dependencies.photosRepository,
        coreDataRepository: dependencies.coreDateRepository,
        imageClassificationService: dependencies.imageClassificationService
    )
    
    lazy var imagesDataSourceUseCase = ReactiveImagesDataSourceUseCase(
        coreDataRepository: dependencies.coreDateRepository
    )
    
    // MARK: - Navigation
    
    func makeGalleryCoordinator(navigationController: UINavigationController) -> GalleryCoordinator {
        return GalleryCoordinator(navigationController: navigationController, dependancies: self)
    }
}

extension GallerySceneContext: GalleryCoordinatorDependencies {
    func makeGalleryViewModel() -> GalleryViewModel {
        let actions = GalleryViewModelActions(
            requestPhotosAccess: dependencies.photosRepository.requestAuthorization
        )
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

final class MapSceneContext: MapCoordinatorDependencies {
    struct Dependancies {
        let coreDateRepository: CoreDataRepository
    }
    
    private let dependancies: Dependancies
    
    private lazy var locationAssetsDataSource = ImagesWithLocationsUseCase(
        coreDataRepository: dependancies.coreDateRepository
    )
    
    init(dependencies: Dependancies) {
        self.dependancies = dependencies
    }
    
    func makeMapCoordinator(forNC nc: UINavigationController) -> MapCoordinator {
        MapCoordinator(navigationController: nc, dependancies: self)
    }
    
    func makeMapViewController() -> UIViewController {
        let viewModel = MapViewModel(imagesWithLocationsUseCase: locationAssetsDataSource)
        let viewController = MapViewController(viewModel: viewModel)
        return viewController
    }
}

protocol MapCoordinatorDependencies {
    func makeMapViewController() -> UIViewController
}

final class MapCoordinator: Coordinator {
    private let dependancies: MapCoordinatorDependencies
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController, dependancies: MapCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependancies = dependancies
    }
    
    func start() {
        let viewController = dependancies.makeMapViewController()
        navigationController?.pushViewController(viewController, animated: false)
    }
}

final class TabBarSceneContext: TabBarCoordinatorDependencies {
    private let photosRepository = PhotosRepositoryImplementation()
    private let imageClassificationService = try! FastViTService()
    private let coreDataManager = CoreDataManager()
    private lazy var coreDateRepository = CoreDataRepositoryImplementation(
        persistentContextProvider: coreDataManager
    )
    
    func makeTabbarCoordinator(forNC nc: UINavigationController) -> TabBarCoordinator {
        TabBarCoordinator(navigationController: nc, dependancies: self)
    }
    
    func makeGalleryCoordinator(forNC nc: UINavigationController) -> GalleryCoordinator {
        let galleryDependencies = GallerySceneContext.Dependencies(
            photosRepository: photosRepository,
            imageClassificationService: imageClassificationService,
            coreDateRepository: coreDateRepository
        )
        let galleryContext = GallerySceneContext(dependencies: galleryDependencies)
        return galleryContext.makeGalleryCoordinator(navigationController: nc)
    }
    
    func makeMapCoordinator(forNC nc: UINavigationController) -> MapCoordinator {
        let mapDependencies = MapSceneContext.Dependancies(
            coreDateRepository: coreDateRepository
        )
        let mapContext = MapSceneContext(dependencies: mapDependencies)
        return mapContext.makeMapCoordinator(forNC: nc)
    }
}

protocol TabBarCoordinatorDependencies {
    func makeGalleryCoordinator(forNC: UINavigationController) -> GalleryCoordinator
    func makeMapCoordinator(forNC: UINavigationController) -> MapCoordinator
}

final class TabBarCoordinator: Coordinator {
    private let dependancies: TabBarCoordinatorDependencies
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController, dependancies: TabBarCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependancies = dependancies
    }
    
    func start() {
        let galleryNavigationController = UINavigationController()
        galleryNavigationController.tabBarItem = UITabBarItem(
            title: "AI",
            image: UIImage(systemName: "sparkles.rectangle.stack"),
            tag: 0
        )
        dependancies
            .makeGalleryCoordinator(forNC: galleryNavigationController)
            .start()
        
        let mapNavigationController = UINavigationController()
        mapNavigationController.tabBarItem = UITabBarItem(
            title: "Map",
            image: UIImage(systemName: "map"),
            tag: 1
        )
        dependancies
            .makeMapCoordinator(forNC: mapNavigationController)
            .start()
        
        let tabbar = UITabBarController()
        tabbar.viewControllers = [galleryNavigationController, mapNavigationController]
        
        navigationController?.pushViewController(tabbar, animated: false)
    }
}
