//
//  FetchImageAsynchronouslyUseCase 2.swift
//  Gallery
//
//  Created by Illia Kniaziev on 28.12.2024.
//

import UIKit

protocol FetchImageAsynchronouslyUseCase {
    func execute(requestedId: String, targetSize: CGSize) async throws -> UIImage
}
