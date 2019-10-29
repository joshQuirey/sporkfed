//
//  CoreDataHelpers.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 10/29/19.
//  Copyright © 2019 jquirey. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataHelpers {

    func fetchMeals(context: NSManagedObjectContext) -> [Meal] {
        var meals: [Meal] = []
        
        let fetchRequest: NSFetchRequest<Meal> = Meal.fetchRequest()
        //Sort Alphabetically
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Meal.mealName), ascending: true)]
        
        context.performAndWait {
            do {
                meals = try fetchRequest.execute()
            } catch {
                let fetchError = error as NSError
                print("Unable to Execute Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
        }
        
        return meals
    }

    func fetchMealsUpNext(context: NSManagedObjectContext) -> [Meal] {
        var meals: [Meal] = []
        
        let fetchRequest: NSFetchRequest<Meal> = Meal.fetchRequest()
        //Sort Alphabetically
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Meal.estimatedNextDate), ascending: true)]

        context.performAndWait {
            do {
                meals = try fetchRequest.execute()
            } catch {
                let fetchError = error as NSError
                print("Unable to Execute Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
        }
        
        return meals
    }

    func fetchMealsFavorites(context: NSManagedObjectContext) -> [Meal] {
        var meals: [Meal] = []
        
        let fetchRequest: NSFetchRequest<Meal> = Meal.fetchRequest()

        // Configure Fetch Request
        fetchRequest.predicate = NSPredicate(format: "favorite == 1")

        //Sort Alphabetically
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Meal.estimatedNextDate), ascending: true)]

        context.performAndWait {
            do {
                meals = try fetchRequest.execute()
            } catch {
                let fetchError = error as NSError
                print("Unable to Execute Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
        }
        
        return meals
    }

    func fetchMeal(name: String, context: NSManagedObjectContext) -> Meal {
        var meal = Meal()
        
        let fetchRequest: NSFetchRequest<Meal> = Meal.fetchRequest()

        // Configure Fetch Request
        fetchRequest.predicate = NSPredicate(format: "mealName == %@",name)

        //Sort Alphabetically
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Meal.estimatedNextDate), ascending: true)]

        context.performAndWait {
            do {
                let meals = try fetchRequest.execute()
                meal = meals[0]
            } catch {
                let fetchError = error as NSError
                print("Unable to Execute Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
        }
        
        return meal
    }

}
