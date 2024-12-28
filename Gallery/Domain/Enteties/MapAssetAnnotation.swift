//
//  MapAssetAnnotation.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//

import Foundation
import MapKit

final class MapAssetAnnotation: NSObject, MKAnnotation {
    let asset: ImageAsset
    
    var id: String
    var coordinate: CLLocationCoordinate2D
    
    init?(asset: ImageAsset) {
        guard let coordinate = asset.location?.coordinate else { return nil }
        self.asset = asset
        self.id = asset.id
        self.coordinate = coordinate
    }
}
