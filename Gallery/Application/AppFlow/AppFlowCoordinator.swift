//
//  AppFlowCoordinator.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import UIKit

final class AppFlowCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let appContext: AppContext
    
    init(navigationController: UINavigationController, appContext: AppContext) {
        self.navigationController = navigationController
        self.appContext = appContext
    }
 
    func start() {
        let context = appContext.makeTabbarContext()
        let coordinator = context.makeCoordinator(navigationController: navigationController)
        coordinator.start()
    }
}
