//
//  MapViewModelInput.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//

import Foundation
import Combine

struct MapViewModelInput {
    var itemSelected: AnyPublisher<ImageAsset, Never>
}
