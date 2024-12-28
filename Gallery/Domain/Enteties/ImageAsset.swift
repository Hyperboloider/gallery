//
//  ImageAsset.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import CoreLocation

struct ImageAsset: Hashable, Equatable {
    var id: String
    var creationDate: Date?
    var location: CLLocation?
    var pixelWidth: Int
    var pixelHeight: Int
    var aiCategory: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ImageAsset, rhs: ImageAsset) -> Bool {
        lhs.id == rhs.id
    }
}
