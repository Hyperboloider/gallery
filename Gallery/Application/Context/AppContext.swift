//
//  AppContext.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import Foundation

protocol Context {
    func makeCoordinator(navigationController: UINavigationController) -> Coordinator
}

final class AppContext {
    func makeTabbarContext() -> TabBarSceneContext {
        TabBarSceneContext()
    }
}

final class GallerySceneContext: Context {
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
    
    lazy var imagesDataSourceUseCase: ReactiveImagesDataSourceUseCase =
        ReactiveImagesDataSourceUseCaseImplementation(
            coreDataRepository: dependencies.coreDateRepository
        )
    
    private lazy var imageUseCase: FetchImageAsynchronouslyUseCase = FetchImageAsynchronouslyUseCaseImplementation(
        photosRepository: dependencies.photosRepository
    )
    
    // MARK: - Navigation
    
    func makeCoordinator(navigationController: UINavigationController) -> Coordinator {
        return GalleryCoordinator(navigationController: navigationController, dependancies: self)
    }
}

extension GallerySceneContext: GalleryCoordinatorDependencies {
    func requestPhotosAccess() async -> PHAuthorizationStatus {
        await dependencies.photosRepository.requestAuthorization()
    }
    
    func makeGalleryViewModel(withActions actions: GalleryViewModelActions) -> GalleryViewModel {
        GalleryViewModel(
            actions: actions,
            processingUseCase: processingUseCase,
            imagesDataSourceUseCase: imagesDataSourceUseCase,
            imageUseCase: imageUseCase
        )
    }
    
    func makeGalleryViewController(withActions actions: GalleryViewModelActions) -> UIViewController {
        let viewModel = makeGalleryViewModel(withActions: actions)
        let viewController = GalleryViewController(viewModel: viewModel)
        return viewController
    }
    
    func makeDetailsCoordinator(withAsset asset: ImageAsset, navigationController: UINavigationController) -> any Coordinator {
        let context = DetailsSceneContext(
            asset: asset,
            dependencies: DetailsSceneContext.Dependencies(photosRepository: dependencies.photosRepository)
        )
        return context.makeCoordinator(navigationController: navigationController)
    }
}

import UIKit
import SwiftUI
import Photos

protocol GalleryCoordinatorDependencies {
    func requestPhotosAccess() async -> PHAuthorizationStatus
    func makeGalleryViewController(withActions actions: GalleryViewModelActions) -> UIViewController
    func makeDetailsCoordinator(withAsset asset: ImageAsset, navigationController: UINavigationController) -> any Coordinator
}

final class GalleryCoordinator: Coordinator {
    
    private let dependancies: GalleryCoordinatorDependencies
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController, dependancies: GalleryCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependancies = dependancies
    }
    
    func start() {
        let actions = GalleryViewModelActions(
            requestPhotosAccess: dependancies.requestPhotosAccess,
            itemSelected: openDetails(withAsset:)
        )
        let viewController = dependancies.makeGalleryViewController(withActions: actions)
        navigationController?.pushViewController(viewController, animated: false)
    }
    
    private func openDetails(withAsset asset: ImageAsset) {
        guard let navigationController else { return }
        dependancies
            .makeDetailsCoordinator(withAsset: asset, navigationController: navigationController)
            .start()
    }
}

final class MapSceneContext: Context, MapCoordinatorDependencies {
    struct Dependancies {
        let photosRepository: PhotosRepository
        let coreDateRepository: CoreDataRepository
    }
    
    private let dependancies: Dependancies
    
    private lazy var locationAssetsDataSource: ImagesWithLocationsUseCase =
        ImagesWithLocationsUseCaseImplementation(
            coreDataRepository: dependancies.coreDateRepository
        )
    
    init(dependencies: Dependancies) {
        self.dependancies = dependencies
    }
    
    func makeCoordinator(navigationController nc: UINavigationController) -> Coordinator {
        MapCoordinator(navigationController: nc, dependancies: self)
    }
    
    func makeMapViewController(withActions actions: MapViewModelActions) -> UIViewController {
        let viewModel = MapViewModel(actions: actions, imagesWithLocationsUseCase: locationAssetsDataSource)
        let viewController = MapViewController(viewModel: viewModel)
        return viewController
    }
    
    func makeDetailsCoordinator(withAsset asset: ImageAsset, navigationController: UINavigationController) -> any Coordinator {
        let context = DetailsSceneContext(
            asset: asset,
            dependencies: DetailsSceneContext.Dependencies(photosRepository: dependancies.photosRepository)
        )
        return context.makeCoordinator(navigationController: navigationController)
    }
}

protocol MapCoordinatorDependencies {
    func makeMapViewController(withActions actions: MapViewModelActions) -> UIViewController
    func makeDetailsCoordinator(withAsset asset: ImageAsset, navigationController: UINavigationController) -> Coordinator
}

final class MapCoordinator: Coordinator {
    private let dependancies: MapCoordinatorDependencies
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController, dependancies: MapCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependancies = dependancies
    }
    
    func start() {
        let viewController = dependancies.makeMapViewController(
            withActions: MapViewModelActions(itemSelected: openDetails(withAsset:))
        )
        navigationController?.pushViewController(viewController, animated: false)
    }
    
    private func openDetails(withAsset asset: ImageAsset) {
        guard let navigationController else { return }
        dependancies
            .makeDetailsCoordinator(withAsset: asset, navigationController: navigationController)
            .start()
    }
}

final class TabBarSceneContext: Context, TabBarCoordinatorDependencies {
    private let photosRepository = PhotosRepositoryImplementation()
    private let imageClassificationService = try! FastViTService()
    private let coreDataManager = CoreDataManager()
    private lazy var coreDateRepository = CoreDataRepositoryImplementation(
        persistentContextProvider: coreDataManager
    )
    
    func makeCoordinator(navigationController nc: UINavigationController) -> Coordinator {
        TabBarCoordinator(navigationController: nc, dependancies: self)
    }
    
    func makeGalleryCoordinator(forNC nc: UINavigationController) -> Coordinator {
        let galleryDependencies = GallerySceneContext.Dependencies(
            photosRepository: photosRepository,
            imageClassificationService: imageClassificationService,
            coreDateRepository: coreDateRepository
        )
        let galleryContext = GallerySceneContext(dependencies: galleryDependencies)
        return galleryContext.makeCoordinator(navigationController: nc)
    }
    
    func makeMapCoordinator(forNC nc: UINavigationController) -> Coordinator {
        let mapDependencies = MapSceneContext.Dependancies(
            photosRepository: photosRepository,
            coreDateRepository: coreDateRepository
        )
        let mapContext = MapSceneContext(dependencies: mapDependencies)
        return mapContext.makeCoordinator(navigationController: nc)
    }
}

protocol TabBarCoordinatorDependencies {
    func makeGalleryCoordinator(forNC: UINavigationController) -> Coordinator
    func makeMapCoordinator(forNC: UINavigationController) -> Coordinator
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

final class DetailsSceneContext: Context, DetailsCoordinatorDependencies {
    struct Dependencies {
        let photosRepository: PhotosRepository
    }
    
    private let asset: ImageAsset
    private let dependencies: Dependencies
    
    
    private lazy var imageUseCase: FetchImageAsynchronouslyUseCase = FetchImageAsynchronouslyUseCaseImplementation(
        photosRepository: dependencies.photosRepository
    )
    
    init(asset: ImageAsset, dependencies: Dependencies) {
        self.asset = asset
        self.dependencies = dependencies
    }
    
    func makeCoordinator(navigationController nc: UINavigationController) -> Coordinator {
        DetailsCoordinator(navigationController: nc, dependancies: self)
    }
    
    func makeDetailsViewController() -> UIViewController {
        let viewModel = DetailsViewModel(imageAsset: asset, imageUseCase: imageUseCase)
        return UIHostingController(rootView: DetailsView(model: viewModel))
    }
}

protocol DetailsCoordinatorDependencies {
    func makeDetailsViewController() -> UIViewController
}

final class DetailsCoordinator: Coordinator {
    private let dependancies: DetailsCoordinatorDependencies
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController, dependancies: DetailsCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependancies = dependancies
    }
    
    func start() {
        let controller = dependancies.makeDetailsViewController()
        navigationController?.present(controller, animated: true)
    }
}
