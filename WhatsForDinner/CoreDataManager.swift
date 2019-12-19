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
        
        //let container = NSPersistentCloudKitContainer(name: "MealModel")
        let container = NSPersistentContainer(name: "MealModel")
        
//        do {
//            try container.initializeCloudKitSchema()
//        } catch {
//
//        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
    }()
    
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
