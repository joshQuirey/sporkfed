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

open class CoreDataManager {
    //static let manager = CoreDataManager()
    private let modelName: String
    //private init() { self.modelName = "MealModel" }
    
    
//    class var sharedInstance : CoreDataManager {
//        struct Static {
//            static var onceToken: dispatch_once_t = 0
//            static var instance: CoreDataManager? = nil
//        }
//        dispatch_once(&Static.onceToken) {
//            Static.instance = CoreDataManager()
//        }
//        return Static.instance!
//    }
    
    init(modelName: String) {
        self.modelName = modelName
        
        setupNotificationHandling()
    }
    
    func addMeal(withName name: String, atURL url: String) {
      //  let meal = Meal(context: managedObjectContext)
      //  meal.mealName = name
      //  meal.mealDesc = url
      //  saveChanges()
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
    
    private var oldPersistentStoreURL: URL { //used before the app group update
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

        if FileManager.default.fileExists(atPath: oldPersistentStoreURL.path){
           needMigrate = true
           targetURL = oldPersistentStoreURL
            needDeleteOld = true
        } else {
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
            CoreDataManager.deleteDocumentAtUrl(url: oldPersistentStoreURL)
        
            var storeName = "\(modelName).sqlite-shm"
            let fileManager = FileManager.default
            let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let shmDocumentURL = documentsDirectoryURL.appendingPathComponent(storeName)
            CoreDataManager.deleteDocumentAtUrl(url: shmDocumentURL)
        
            storeName = "\(modelName).sqlite-wal"
            let walDocumentURL = documentsDirectoryURL.appendingPathComponent(storeName)
            CoreDataManager.deleteDocumentAtUrl(url: walDocumentURL)
        }
        
        print(persistentStoreCoordinator.persistentStores)

        
//        do {
//            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: oldPersistentStoreURL as URL, options: options)
//        } catch {
//            let addPersistentStoreError = error as NSError
//
//            print("Unable to Add Persistent Store")
//            print("\(addPersistentStoreError.localizedDescription)")
//        }

        //Migrate old to new
//        if let oldStore = persistentStoreCoordinator.persistentStore(for: oldPersistentStoreURL) {
//            do {
//                print(persistentStoreCoordinator.persistentStores)
//                let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
//              try persistentStoreCoordinator.migratePersistentStore(oldStore, to: persistentStoreURL, options: options, withType: NSSQLiteStoreType)
//
//                print(persistentStoreCoordinator.persistentStores)
//               // self.deleteDatabase(url: oldPersistentStoreURL)
//               // self.cleanDb()
//            } catch {
//              // Handle error
//              print("Failed to move from: \(oldPersistentStoreURL) to \(persistentStoreURL)")
//            }
//        }
            
        //add new store to psc
//        do {
//            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
//            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL as URL, options: options)
//            print(persistentStoreCoordinator.persistentStores)
//        } catch {
//            let addPersistentStoreError = error as NSError
//
//            print("Unable to Add Persistent Store")
//            print("\(addPersistentStoreError.localizedDescription)")
//        }
        
        return persistentStoreCoordinator
    }()
    
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
        let container = NSPersistentContainer(name: "MealModel")
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
