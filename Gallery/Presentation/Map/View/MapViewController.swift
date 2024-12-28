//
//  MapViewController.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//

import Foundation
import UIKit
import MapKit
import SwiftUI
import Combine

final class MapViewController: UIViewController {
    private let viewModel: MapViewModel
    private let selectionSubject = PassthroughSubject<ImageAsset, Never>()
    private var bag: Set<AnyCancellable> = []
    private let mapView = MKMapView()
    
    required init?(coder: NSCoder) { fatalError() }
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGreen
        configureUI()
        bindViewModel()
    }
    
    private func bindViewModel() {
        let output = viewModel.transform(
            input: MapViewModelInput(
                itemSelected: selectionSubject.eraseToAnyPublisher()
            )
        )
        output
            .snapshotPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] snapshot in
                updateAnnotations(with: snapshot)
            }
            .store(in: &bag)
    }
    
    private func configureUI() {
        configureMap()
        setupCompassButton()
    }
    
    private func configureMap() {
        mapView.delegate = self
        
        mapView.register(PhotoAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        view.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupCompassButton() {
        let compass = MKCompassButton(mapView: mapView)
        compass.compassVisibility = .visible
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: compass)
        mapView.showsCompass = false
    }
    
    private func updateAnnotations(with imageAssets: [MapAssetAnnotation]) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(imageAssets)
    }
    
    private let maxZoomLevel = 14
    private var previousZoomLevel: Int?
    private var currentZoomLevel: Int?  {
        willSet {
            self.previousZoomLevel = self.currentZoomLevel
        }
        didSet {
            guard let currentZoomLevel = self.currentZoomLevel else { return }
            guard let previousZoomLevel = self.previousZoomLevel else { return }
            var refreshRequired = false
            if currentZoomLevel > self.maxZoomLevel && previousZoomLevel <= self.maxZoomLevel {
                refreshRequired = true
            }
            if currentZoomLevel <= self.maxZoomLevel && previousZoomLevel > self.maxZoomLevel {
                refreshRequired = true
            }
            if refreshRequired {
                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)
                self.mapView.addAnnotations(annotations)
            }
        }
    }

    private var shouldCluster: Bool {
        if let zoomLevel = self.currentZoomLevel, zoomLevel <= maxZoomLevel {
            return false
        }
        return true
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let zoomWidth = mapView.visibleMapRect.size.width
        let zoomLevel = Int(log2(zoomWidth))
        self.currentZoomLevel = zoomLevel
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MapAssetAnnotation else { return nil }
        let view = PhotoAnnotationView(annotation: annotation, reuseIdentifier: PhotoAnnotationView.ReuseID)
        view.configure(withAnnotation: annotation.asset)
        view.clusteringIdentifier = shouldCluster ? "cluster" : nil
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? MapAssetAnnotation else { return }
        selectionSubject.send(annotation.asset)
    }
}
