//
//  GalleryViewController.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import Combine
import SnapKit
import Foundation
import UIKit
import SwiftUI

final class GalleryViewController: UIViewController {
    private let viewModel: GalleryViewModel
    private lazy var gridModel = CategorizedGridModel(onSelect: { [unowned self] in selectionSubject.send($0) })
    private let selectionSubject = PassthroughSubject<ImageAsset, Never>()
    private let groupingPreferenceSubject = CurrentValueSubject<ReactiveImagesDataSourceUseCase.GroupingPreference, Never>(.category)
    private var bag = Set<AnyCancellable>()
    
    private let allowAccessLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.text = "Allow access to photos"
        return label
    }()
    private let accessOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.5
        return view
    }()
    
    required init?(coder: NSCoder) { fatalError() }
    init(viewModel: GalleryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        configureUI()
        Task { await bindToViewModel() }
    }
    
    private func bindToViewModel() async {
        let output = await viewModel.transform(
            input: GalleryViewModelInput(
                itemSelectedPublisher: selectionSubject.eraseToAnyPublisher(),
                groupingPreferencePublisher: groupingPreferenceSubject.eraseToAnyPublisher()
            )
        )
        output
            .processingProgress
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] progress in
                if progress == 1 {
                    title = "AI"
                } else {
                    title = String(format: "AI: %.2f", progress * 100) + "%"
                }
            }
            .store(in: &bag)
        
        output
            .isPhotosAccessAuthorized
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isAllowed in
                if isAllowed {
                    removeAllowAccessOverlay()
                } else {
                    addAllowAccessOverlay()
                }
            }
            .store(in: &bag)
        
        output
            .snapshotPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] snapshot in
                gridModel.items = snapshot
            }
            .store(in: &bag)
    }
    
    private func configureUI() {
        configureNavigationBar()
        addCollectionView()
    }
    
    private func configureNavigationBar() {
        let monthAction = UIAction(
            title: "Month",
            state: groupingPreferenceSubject.value == .month ? .on : .off,
            handler: { _ in
            self.groupingPreferenceSubject.send(.month)
            self.configureNavigationBar()
        })
        
        let categoryAction = UIAction(
            title: "Category",
            state: groupingPreferenceSubject.value == .category ? .on : .off,
            handler: { _ in
            self.groupingPreferenceSubject.send(.category)
            self.configureNavigationBar()
        })
        
        let menu = UIMenu(title: "Select Grouping Preference", children: [monthAction, categoryAction])
        
        let menuBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.horizontal.3"),
            primaryAction: nil,
            menu: menu
        )
        
        self.navigationItem.rightBarButtonItem = menuBarButtonItem
    }
    
    private func addCollectionView() {
        let hostingController = UIHostingController(rootView: CategorizedGrid(model: gridModel))
        addChild(hostingController)
        hostingController.willMove(toParent: self)
        guard let grid = hostingController.view else { return }
        view.addSubview(grid)
        grid.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.horizontalEdges.equalToSuperview()
        }
    }
    
    private func addAllowAccessOverlay() {
        view.addSubview(accessOverlay)
        accessOverlay.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        accessOverlay.addSubview(allowAccessLabel)
        allowAccessLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func removeAllowAccessOverlay() {
        accessOverlay.removeFromSuperview()
    }
    
}
