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
    /////////////////////////////
    //Create Plans
    /////////////////////////////
    func getNumberAvailableMeals(context: NSManagedObjectContext) -> Int? {
        var count = 0
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Meal> = Meal.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.predicate = NSPredicate(format: "estimatedNextDate != nil")

        // Perform Fetch Request
        context.performAndWait {
            do {
                // Execute Fetch Request
                let meals = try fetchRequest.execute()
                count = meals.count
               
            } catch {
                let fetchError = error as NSError
                print("Unable to Execute Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
        }
        
        return count
    }
    
    func getNextMealforCategory(context: NSManagedObjectContext, _plannedCategory: String) -> [Meal] {
        var meals: [Meal] = []
        
        let fetchRequest: NSFetchRequest<Meal> = Meal.fetchRequest()

        //Fetch Meals using Category
        fetchRequest.predicate = NSPredicate(format: "(ANY tags.name == %@) AND estimatedNextDate != nil", _plannedCategory)
        
        //Sort by estimated next date
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Meal.estimatedNextDate), ascending:true)]
        
        //Perform Fetch Request
        context.performAndWait {
            do {
                //Execute Fetch Request
                meals = try fetchRequest.execute()
            } catch {
                let fetchError = error as NSError
                print("Unable to Execute Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
        }
        
        return meals
    }
    
    func getNextMeals(context: NSManagedObjectContext) -> [Meal] {
        var meals: [Meal] = []
              
        let fetchRequest: NSFetchRequest<Meal> = Meal.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "estimatedNextDate != nil")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Meal.estimatedNextDate), ascending:true)]
        
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
    
    
    /////////////////////////////
    //Fetch Plans
    /////////////////////////////
    func fetchPlans(context: NSManagedObjectContext) -> [PlannedDay]  {
        var plannedDays: [PlannedDay] = []
        
        let fetchRequest: NSFetchRequest<PlannedDay> = PlannedDay.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "isCompleted == nil")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(PlannedDay.date), ascending: true)]
        
        context.performAndWait {
            do {
                plannedDays = try fetchRequest.execute()
            } catch {
                let fetchError = error as NSError
                print("Unable to Execute Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
        }
        
        return plannedDays
    }
    
    /////////////////////////////
    //Fetch Meals
    /////////////////////////////
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

    /////////////////////////////
    //Fetch Groceries
    /////////////////////////////
    func fetchGroceries(context: NSManagedObjectContext) -> [GroceryList] {
        var groceries: [GroceryList] = []
        
        let fetchRequest: NSFetchRequest<GroceryList> = GroceryList.fetchRequest()
        //Sort Alphabetically
        var byMealIndex = NSSortDescriptor(key: #keyPath(GroceryList.mealIndex), ascending: true)
        //fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(GroceryList.mealIndex), ascending: true)]
        var byItemIndex = NSSortDescriptor(key: #keyPath(GroceryList.itemIndex), ascending: true)
        fetchRequest.sortDescriptors = [byMealIndex,byItemIndex]
        
        context.performAndWait {
            do {
                groceries = try fetchRequest.execute()
            } catch {
                let fetchError = error as NSError
                print("Unable to Execute Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
        }
        
        return groceries
    }
}
