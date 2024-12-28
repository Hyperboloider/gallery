//
//  PhotoAnnotation.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//

import MapKit
import CoreLocation

class PhotoAnnotation: NSObject, MKAnnotation {
    let asset: ImageAsset
    var coordinate: CLLocationCoordinate2D { asset.location?.coordinate ?? .init() }
    
    init(asset: ImageAsset) {
        self.asset = asset
        super.init()
    }
}
