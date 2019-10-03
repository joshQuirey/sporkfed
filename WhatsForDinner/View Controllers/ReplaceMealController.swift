//
//  ReplacePlannedMealController.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 5/22/19.
//  Copyright © 2019 jquirey. All rights reserved.
//

import UIKit
import CoreData

class ReplaceMealController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    /////////////////////////////
    //Outlets
    /////////////////////////////
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    /////////////////////////////
    //Properties
    /////////////////////////////
    var managedObjectContext: NSManagedObjectContext?
    private var nextMealsforCategory: [Meal]?
    private var nextMeals: [Meal]?
    private var allMeals: [Meal]?
    
    var currentPlannedDay: PlannedDay?
    
    enum MealSections: Int {
        case NextCategory = 0, Next
    }
    
    /////////////////////////////
    //View Life Cycle
    /////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchNextMealsforCategory()
        fetchNextMeals()
        self.nextMealsforCategory = self.allMeals
        tableView.reloadData()
        
        searchBar.delegate = self
        searchBar.layer.borderWidth = 2
        //searchBar.layer.borderColor = UIColor(red: 77/255, green: 72/255, blue: 147/255, alpha: 1.0).cgColor
        searchBar.layer.borderColor = UIColor(named: "_Purple Background")!.cgColor
        self.navigationItem.titleView = searchBar
        self.navigationItem.hidesSearchBarWhenScrolling = true
        
        tableView.keyboardDismissMode = .onDrag
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    // MARK: - Table view data source
    private func fetchNextMealsforCategory() {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Meal> = Meal.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.predicate = NSPredicate(format: "(ANY tags.name == %@) AND estimatedNextDate != nil", currentPlannedDay!.category!)
        
        //fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Meal.mealName), ascending: true)]
        
        // Perform Fetch Request
        managedObjectContext!.performAndWait {
            do {
                // Execute Fetch Request
                let meals = try fetchRequest.execute()
                
                // Update Tickets
                self.allMeals = meals
                
            } catch {
                let fetchError = error as NSError
                print("Unable to Execute Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
        }
    }
    
    private func fetchNextMeals() {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Meal> = Meal.fetchRequest()

        // Configure Fetch Request
//        fetchRequest.predicate = NSPredicate(format: "(ANY tags.name != %@ AND ANY tags.name == nil) AND estimatedNextDate != nil", currentPlannedDay!.category!)
        fetchRequest.predicate = NSPredicate(format: "estimatedNextDate != nil")
        
        //fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Meal.mealName), ascending: true)]
        
        // Perform Fetch Request
        managedObjectContext!.performAndWait {
            do {
                // Execute Fetch Request
                let meals = try fetchRequest.execute()

                // Update Tickets
                if meals.count > 0 {
//                    print("meals greater than 0")
                    if self.allMeals?.count == 0 {
//                        print("all meals equals 0")
                        self.allMeals = meals
                    } else {
//                        print("all meals greater than 0")
                        for meal in meals {
                            if self.allMeals?.contains(meal) == false {
                                self.allMeals?.append(meal)
                            }
                        }
                        //self.allMeals?.append(contentsOf: meals)
                    }
                }
                
            } catch {
                let fetchError = error as NSError
                print("Unable to Execute Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            nextMealsforCategory = allMeals
            tableView.reloadData()
            return
        }
        
        nextMealsforCategory = allMeals!.filter({ Meal -> Bool in
            return (Meal.mealName?.lowercased().contains(searchText.lowercased()))!
        })
        
        tableView.reloadData()
    }
    
    /////////////////////////////
    //Table Functions
    /////////////////////////////
    func numberOfSections(in tableView: UITableView) -> Int {
        return nextMealsforCategory!.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 10))
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "replaceCell", for: indexPath) as! ReplaceTableViewCell
        
        guard let _meal = nextMealsforCategory?[indexPath.section] else { fatalError("Unexpected Index Path")}
        
        if (_meal.mealImage != nil) {
            cell.mealImage?.image = UIImage(data: _meal.mealImage!)
            cell.mealImage.layer.cornerRadius = 8
            cell.mealImage.clipsToBounds = true
            cell.mealImage.isHidden = false
        } else {
            cell.mealImage.isHidden = true
        }
    
        cell.mealName.text = _meal.mealName
    
        cell.mealCategories?.text = ""
        for _tag in (_meal.tags?.allObjects)! {
            let tag = _tag as! Tag
            cell.mealCategories?.text?.append("\(tag.name!) ")
        }
    
        if (_meal.prepTime != nil && _meal.prepTime! != "") {
            cell.prep?.text? = "Plan: \(_meal.prepTime!)"
        } else {
            cell.prep?.text? = " "
        }
    
        if (_meal.cookTime != nil && _meal.cookTime! != "") {
            cell.cook?.text? = "Cook: \(_meal.cookTime!)"
        } else {
            cell.cook?.text? = " "
        }
    
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (currentPlannedDay?.meal != nil) {
            guard let _currentMeal = currentPlannedDay?.meal else { fatalError("Unexpected Index Path")}
            //delete previous meal
            _currentMeal.estimatedNextDate = _currentMeal.previousDate
            _currentMeal.nextDate = nil
            _currentMeal.previousDate = nil
            _currentMeal.removeFromPlannedDays(currentPlannedDay!)
        }
        
        guard let _replaceMeal = nextMealsforCategory?[indexPath.section] else { fatalError("Unexpected Index Path")}
        //add next meal
        _replaceMeal.previousDate = _replaceMeal.estimatedNextDate
        _replaceMeal.estimatedNextDate = nil
        _replaceMeal.nextDate = currentPlannedDay!.date
        _replaceMeal.addToPlannedDays(currentPlannedDay!)
        
        self.dismiss(animated: true, completion: nil)
    }
}
