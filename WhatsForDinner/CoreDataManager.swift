//
//  CoreDataManager.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 12/16/19.
//  Copyright © 2019 jquirey. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    //private init() {}
    
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentCloudKitContainer(name: "MealModel")
        //let container = NSPersistentContainer(name: "MealModel")
        
        do {
            try container.initializeCloudKitSchema()
        } catch {

        }
        
        var options = [AnyHashable : Any]()
               options[NSMigratePersistentStoresAutomaticallyOption] = true
               options[NSInferMappingModelAutomaticallyOption] = true
        
        var previousStoreURL = previousLocalPersistentStoreURL
        print("Old \(previousStoreURL)")
        var previousStore = container.persistentStoreCoordinator.persistentStore(for: previousStoreURL)
        print("Old Store \(previousStore)")
        do {
            try container.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: previousStoreURL, options: options)
                
        } catch {
            let addPersistentStoreError = error as NSError
            print("Unable to Add Persistent Store")
            print("\(addPersistentStoreError.localizedDescription)")
        }
        previousStore = container.persistentStoreCoordinator.persistentStore(for: previousStoreURL)
        print("Old Store \(previousStore)")
        
        //var newStoreURL: URL
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
                
            var newStoreURL = storeDescription.url!
            print("New \(newStoreURL)")
            
            print("test test test")
            print(container.persistentStoreCoordinator.persistentStores)
            print("end test end test end test")
    
   
            if (previousStore != nil) {
                do {
                    try container.persistentStoreCoordinator.migratePersistentStore(previousStore!, to: newStoreURL, options: options, withType: NSSQLiteStoreType)
                    
                } catch let error {
                        print("migrate failed with error : \(error)")
                }
                
                do {
                    try container.persistentStoreCoordinator.destroyPersistentStore(at: previousStoreURL, ofType: NSSQLiteStoreType, options: options)

                } catch let error {
                        print("destroy failed with error : \(error)")
                }
            }
            
            print("test test test")
            print(container.persistentStoreCoordinator.persistentStores)
            print("end test end test end test")
            
            
        })
        
        
        
        return container
    }()
    
    static var previousLocalPersistentStoreURL: URL {
        //Helpers
        let storeName = "MealModel.sqlite"
        let fileManager = FileManager.default
    
        //new
        let documentsDirectoryURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier:"group.co.app41.sporkfed")
        
        return documentsDirectoryURL!.appendingPathComponent(storeName)
    }
    
    func migrateLocalToCloud() {

    }
    
    static func saveContext() {
        
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
