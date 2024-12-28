//
//  CoreDataManager.swift
//  Gallery
//
//  Created by Illia Kniaziev on 27.12.2024.
//

import Foundation
import CoreData

protocol CoreDataContainerProvider {
    var container: NSPersistentContainer { get }
}

protocol CoreDataContextProvider {
    var mainContext: NSManagedObjectContext { get }
    func makeNewPrivateContext() -> NSManagedObjectContext
}

final class CoreDataManager: CoreDataContainerProvider, CoreDataContextProvider {
    
    private enum ContainerOptionSet: CaseIterable {
        case remoteChangeNotificationEnabled
        case historyTracking
        
        var coreDataOption: (NSObject, String) {
            switch self {
            case .remoteChangeNotificationEnabled:
                (false /*true*/ as NSNumber, NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            case .historyTracking:
                (false /*true*/ as NSNumber, NSPersistentHistoryTrackingKey)
            }
        }
    }
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Images")
        guard let description = container.persistentStoreDescriptions.first else {
            preconditionFailure("Failed to retrieve a persistent store description.")
        }
//        
//        ContainerOptionSet.allCases
//            .map { $0.coreDataOption }
//            .forEach(description.setOption)
        
        container.loadPersistentStores { storeDescription, error in
            guard let error else { return }
            preconditionFailure(error.localizedDescription)
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.name = "MainViewContext"
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        container.viewContext
    }
    
    func makeNewPrivateContext() -> NSManagedObjectContext {
        let taskContext = container.newBackgroundContext()
        taskContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        taskContext.undoManager = nil
        return taskContext
    }
    
}
