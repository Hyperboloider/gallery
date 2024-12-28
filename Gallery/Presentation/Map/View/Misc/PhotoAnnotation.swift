//
//  PhotoAnnotation.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//

import MapKit
import CoreLocation
import SwiftUI

class PhotoAnnotationView: MKAnnotationView {
    static let ReuseID = "unicycleAnnotation"
    
    /// - Tag: ClusterIdentifier
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = "unicycleAnnotation"
//        canShowCallout = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subviews.forEach { $0.removeFromSuperview() }
    }
    
    func configure(withAnnotation annotation: ImageAsset) {
        self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.bounds = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.centerOffset = CGPoint(x: 0, y: -25)
        
        let hostingController = UIHostingController(rootView: AsyncImageView(identifier: annotation.id))
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        hostingController.view.layer.cornerRadius = 25
        hostingController.view.layer.masksToBounds = true
        addSubview(hostingController.view)
    }
}
