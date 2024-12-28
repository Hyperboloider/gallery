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
        let output = viewModel.transform(input: .init())
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
    }
    
    private func configureMap() {
        mapView.delegate = self
        mapView.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
        mapView.register(
            MKAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier
        
        )
        view.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func updateAnnotations(with imageAssets: [ImageAsset]) {
        mapView.removeAnnotations(mapView.annotations)
        let newAnnotations = imageAssets.map(PhotoAnnotation.init)
        mapView.addAnnotations(newAnnotations)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(
        _ mapView: MKMapView,
        viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {
        guard let photoAnnotation = annotation as? PhotoAnnotation else { return nil }
        
        let identifier = "PhotoAnnotationView"
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        
        view.annotation = annotation
        view.canShowCallout = false
        
        let hostingController = UIHostingController(rootView: AsyncImageView(identifier: photoAnnotation.asset.id))
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        hostingController.view.layer.cornerRadius = 25
        hostingController.view.layer.masksToBounds = true
        
        if view.subviews.isEmpty {
            view.addSubview(hostingController.view)
        } else {
            view.subviews.first?.removeFromSuperview()
            view.addSubview(hostingController.view)
        }
        
        return view
    }
    
    func mapView(
        _ mapView: MKMapView,
        clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]
    ) -> MKClusterAnnotation {
        let clusterAnnotation = MKClusterAnnotation(memberAnnotations: memberAnnotations)
        return clusterAnnotation
    }
}
