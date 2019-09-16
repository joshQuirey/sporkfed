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
    
        //let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let documentsDirectoryURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier:"group.co.app41.sporkfed")
        
        return documentsDirectoryURL!.appendingPathComponent(storeName)
        
        
    }
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        guard let managedObjectModel = self.managedObjectModel else {
            return nil
        }
        
        //Helper
        let persistentStoreURL = self.persistentStoreURL
        //Initialize Persistent Store Coordinator
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL as URL, options: options)
        } catch {
            let addPersistentStoreError = error as NSError
            
            print("Unable to Add Persistent Store")
            print("\(addPersistentStoreError.localizedDescription)")
        }
        
        return persistentStoreCoordinator
    }()
    
    private lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "MealModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
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
