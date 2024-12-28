//
//  CoreDataRepositoryImplementation.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import Foundation
import CoreData
import CoreLocation
import Combine
import UIKit

final class CoreDataRepositoryImplementation: CoreDataRepository {
    private let persistentContextProvider: CoreDataContextProvider
    
    init(persistentContextProvider: CoreDataContextProvider) {
        self.persistentContextProvider = persistentContextProvider
    }
    
    func saveImageAsset(_ asset: ImageAsset) async throws {
        try await persistentContextProvider.mainContext.perform {
            let entity = ImageEntity(context: self.persistentContextProvider.mainContext)
            entity.id = asset.id
            entity.creationDate = asset.creationDate
            entity.pixelWidth = Int16(asset.pixelWidth)
            entity.pixelHeight = Int16(asset.pixelHeight)
            entity.aiCategory = asset.aiCategory
            if let location = asset.location {
                entity.locationLatitude = location.coordinate.latitude
                entity.locationLongitude = location.coordinate.longitude
            }
            try self.persistentContextProvider.mainContext.save()
        }
    }
    
    func fetchWithPredicate(_ predicate: NSPredicate?) async throws -> [ImageAsset] {
        let context = self.persistentContextProvider.mainContext
        let fetchRequest: NSFetchRequest<ImageEntity> = ImageEntity.fetchRequest()
        fetchRequest.predicate = predicate
        
        let entities = try context.fetch(fetchRequest)
        return entities.compactMap(map(dbObject:))
    }
    
    func fetchStreamWithPredicate(_ predicate: NSPredicate?) -> any ReadableStreamDataSource<ImageAsset> {
        let context = self.persistentContextProvider.mainContext
        let fetchRequest: NSFetchRequest<ImageEntity> = ImageEntity.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        return ObservableDataSource(
            fetchController: fetchedResultsController,
            mapper: map(dbObject:)
        )
    }
    
    private func map(dbObject: ImageEntity) -> ImageAsset? {
        guard let id = dbObject.id else { return nil }
        return ImageAsset(
            id: id,
            creationDate: dbObject.creationDate,
            location: CLLocation(latitude: dbObject.locationLatitude, longitude: dbObject.locationLongitude),
            pixelWidth: Int(dbObject.pixelWidth),
            pixelHeight: Int(dbObject.pixelHeight),
            aiCategory: dbObject.aiCategory
        )
    }
}

protocol ReadableStreamDataSource<Element> {
    associatedtype Element
    var publisher: AnyPublisher<[Element], Never> { get }
}

final class ObservableDataSource<ResultType: NSFetchRequestResult, OutputType>
    : NSObject, NSFetchedResultsControllerDelegate, ReadableStreamDataSource {
    
    typealias Mapper = (ResultType) -> OutputType?
    
    private let fetchController: NSFetchedResultsController<ResultType>
    private let mapper: Mapper
    private var snapshotSubject = CurrentValueSubject<[ResultType]?, Never>(nil)
    
    var publisher: AnyPublisher<[OutputType], Never> {
        snapshotSubject
            .compactMap { $0 }
            .map { $0.compactMap(self.mapper) }
            .eraseToAnyPublisher()
    }
    
    init(fetchController: NSFetchedResultsController<ResultType>, mapper: @escaping Mapper) {
        self.fetchController = fetchController
        self.mapper = mapper
        super.init()
        fetchController.delegate = self
        try! fetchController.performFetch()
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        guard let objects = fetchController.fetchedObjects
        else { return }
        snapshotSubject.send(objects)
    }
}
