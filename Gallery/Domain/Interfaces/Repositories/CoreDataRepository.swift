//
//  CoreDataRepository.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import Foundation
import Combine

protocol CoreDataRepository {
    func saveImageAsset(_ asset: ImageAsset) async throws
    func fetchWithPredicate(_ predicate: NSPredicate?) async throws -> [ImageAsset]
    func fetchStreamWithPredicate(_ predicate: NSPredicate?) -> any ReadableStreamDataSource<ImageAsset>
}
