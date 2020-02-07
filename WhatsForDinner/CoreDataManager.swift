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
//        var previousStore = container.persistentStoreCoordinator.persistentStore(for: previousStoreURL)
//        print("Old Store \(previousStore)")
        
        var needMigrate = false
        var needDeleteOld = false
        
        if FileManager.default.fileExists(atPath: previousStoreURL.path){
            needMigrate = true
            needDeleteOld = true
        } else { //No old data store, use new going forward
            //if FileManager.default.fileExists(atPath: persistentStoreURL.path){
                needMigrate = false
                needDeleteOld = false
            //}
        }
        
        //Add Old Store to coordinator
        if needMigrate {
            do {
                try container.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: previousStoreURL, options: options)
                    
            } catch {
                let addPersistentStoreError = error as NSError
                print("Unable to Add Persistent Store")
                print("\(addPersistentStoreError.localizedDescription)")
            }
        }
        
        //Get Old Store
//        previousStore = container.persistentStoreCoordinator.persistentStore(for: previousStoreURL)
        
        //var newStoreURL: URL
        //Add New Store to coordinator
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
                
            var newStoreURL = storeDescription.url!
            print("New \(newStoreURL)")
            //Both Old and New are in the coordinator
            print(container.persistentStoreCoordinator.persistentStores)
    
            //If Old Store Exists
            if needMigrate {
                do {
                    //Replace
                    try container.persistentStoreCoordinator.replacePersistentStore(at: newStoreURL, destinationOptions: options, withPersistentStoreFrom: previousStoreURL, sourceOptions: options, ofType: NSSQLiteStoreType)
                    //Migrate Old store to New store
                    //try container.persistentStoreCoordinator.migratePersistentStore(previousStore!, to: newStoreURL, options: options, withType: NSSQLiteStoreType)
                    
                } catch let error {
                        print("migrate failed with error : \(error)")
                }
                
                //??delete or truncate old store
                do {
                    //use replace persistentstore
                    try container.persistentStoreCoordinator.destroyPersistentStore(at: previousStoreURL, ofType: NSSQLiteStoreType, options: options)

                } catch let error {
                        print("destroy failed with error : \(error)")
                }
                
                container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                           if let error = error as NSError? {
                               fatalError("Unresolved error \(error), \(error.userInfo)")
                           }
                })
            }
            
            print(container.persistentStoreCoordinator.persistentStores)
            
        })
        
        if needDeleteOld {
            CoreDataManager.deleteDocumentAtUrl(url: previousStoreURL)

            var storeName = "MealModel.sqlite-shm"
            let fileManager = FileManager.default
            let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let shmDocumentURL = documentsDirectoryURL.appendingPathComponent(storeName)
            CoreDataManager.deleteDocumentAtUrl(url: shmDocumentURL)

            storeName = "MealModel.sqlite-wal"
            let walDocumentURL = documentsDirectoryURL.appendingPathComponent(storeName)
            CoreDataManager.deleteDocumentAtUrl(url: walDocumentURL)
        }
        
        return container
    }()
    
    //Delete of Old Store Files
    static func deleteDocumentAtUrl(url: URL){
        let fileCoordinator = NSFileCoordinator(filePresenter: nil)
        fileCoordinator.coordinate(writingItemAt: url, options: .forDeleting, error: nil, byAccessor: {
            (urlForModifying) -> Void in
            do {
                try FileManager.default.removeItem(at: urlForModifying)
            }catch let error {
                print("Failed to remove item with error: \(error.localizedDescription)")
            }
        })
    }
    
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
