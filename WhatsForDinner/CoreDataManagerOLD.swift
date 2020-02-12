//
//  CoreDataManager.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 8/9/18.
//  Copyright © 2018 jquirey. All rights reserved.
//

import CoreData
import Foundation
import UIKit

open class CoreDataManagerOLD {
    private let modelName: String

    init(modelName: String) {
        self.modelName = modelName
        
        setupNotificationHandling()
    }
    
    func addMeal(withName name: String, atURL url: String) {
      }
    
    private func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(saveChanges(_:)),
                                       name: UIApplication.willTerminateNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(saveChanges(_:)),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)
    }
    
    @objc func saveChanges(_ notification: Notification?) {
        saveChanges()
    }
    
    private func saveChanges() {
        guard managedObjectContext.hasChanges else { return }
        
        do {
            try managedObjectContext.save()
        } catch {
            print("Unable to Save Managed Object Context")
            print("\(error), \(error.localizedDescription)")
        }
    }
    
    private lazy var managedObjectModel: NSManagedObjectModel? = {
        //Fetch Model URL
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            return nil
        }
        
        //Initialize Managed Object Model
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        
        return managedObjectModel
    }()
    
    private var persistentStoreURL: URL {
        //Helpers
        let storeName = "\(modelName).sqlite"
        let fileManager = FileManager.default
    
        //new
        let documentsDirectoryURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier:"group.co.app41.sporkfed")
        
        return documentsDirectoryURL!.appendingPathComponent(storeName)
    }
    
    //Used before the app group update
    private var oldPersistentStoreURL: URL {
        //Helpers
            let storeName = "\(modelName).sqlite"
            let fileManager = FileManager.default
        
            //old
            let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

            return documentsDirectoryURL.appendingPathComponent(storeName) as URL
    }
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        guard let managedObjectModel = self.managedObjectModel else {
            return nil
        }
        
        var options = [AnyHashable : Any]()
        options[NSMigratePersistentStoresAutomaticallyOption] = true
        options[NSInferMappingModelAutomaticallyOption] = true
        
        let oldPersistentStoreURL = self.oldPersistentStoreURL
        let persistentStoreURL = self.persistentStoreURL
        var targetURL : URL? = nil
        var needMigrate = false
        var needDeleteOld = false

        //Check if old data store exists
        if FileManager.default.fileExists(atPath: oldPersistentStoreURL.path){
            needMigrate = true
            targetURL = oldPersistentStoreURL
            needDeleteOld = true
        } else { //No old data store, use new going forward
            if FileManager.default.fileExists(atPath: persistentStoreURL.path){
                needMigrate = false
                targetURL = persistentStoreURL
                needDeleteOld = false
            }
        }
    
       if targetURL == nil {
           targetURL = persistentStoreURL
       }
        
        //Initialize Persistent Store Coordinator
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        if needMigrate {
            do {
                try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: targetURL!, options: options)
                if let store = persistentStoreCoordinator.persistentStore(for: targetURL!) {
                    do {
                        try persistentStoreCoordinator.migratePersistentStore(store, to: persistentStoreURL, options: options, withType: NSSQLiteStoreType)
                    } catch let error {
                        print("migrate failed with error : \(error)")
                    }
                }
            } catch {
                 let addPersistentStoreError = error as NSError
                 print("Unable to Add Persistent Store")
                 print("\(addPersistentStoreError.localizedDescription)")
            }
        } else {
            do {
                try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL as URL, options: options)
            } catch {
                let addPersistentStoreError = error as NSError
    
                print("Unable to Add Persistent Store")
                print("\(addPersistentStoreError.localizedDescription)")
            }
        }
        
        if needDeleteOld {
            CoreDataManagerOLD.deleteDocumentAtUrl(url: oldPersistentStoreURL)

            var storeName = "s\(modelName).sqlite-shm"
            let fileManager = FileManager.default
            let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let shmDocumentURL = documentsDirectoryURL.appendingPathComponent(storeName)
            CoreDataManagerOLD.deleteDocumentAtUrl(url: shmDocumentURL)

            storeName = "\(modelName).sqlite-wal"
            let walDocumentURL = documentsDirectoryURL.appendingPathComponent(storeName)
            CoreDataManagerOLD.deleteDocumentAtUrl(url: walDocumentURL)
        }
                
        return persistentStoreCoordinator
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
    
    private lazy var persistentContainer: NSPersistentContainer = {
        //let container = NSPersistentContainer(name: "MealModel")
        let container = NSPersistentCloudKitContainer(name: "MealModel")
        
        //initialize schema
//        guard let description = container.persistentStoreCoordinator.first else {
//            fatalError("Could not retrieve a persistent store description")
//        }
//        let id = "iCloud.co.app41.sporkfed.MealModel"
//        let options = NSPersistentCloudKitContainerOptions(containerIdentifier: id)
        do {
            try container.initializeCloudKitSchema()
        } catch {
            print("Unable to initialize CloudKit schema: \(error.localizedDescription)")
        }
        
        
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    public private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        //Initialize
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        //Configure
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    
    
    
    
    
    
    
    
}
