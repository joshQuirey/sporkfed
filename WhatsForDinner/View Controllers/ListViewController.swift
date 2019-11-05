//
//  ListViewController.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 11/1/19.
//  Copyright © 2019 jquirey. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController {
    /////////////////////////////
    //Outlets
    /////////////////////////////
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyTableLabel: UILabel!
    
    @IBAction func RefreshList(_ sender: Any) {
        fetchMenu()
    }
    
    /////////////////////////////
    //Properties
    /////////////////////////////
    var managedObjectContext: NSManagedObjectContext?
    private var currentIndex: Int?
    
    var plannedMenu: [PlannedDay]? {
        didSet {
            updateView()
        }
    }
    
    var helpers = CoreDataHelpers()
    //define List struct
    struct GroceryList {
        var plannedMenuItem: String = ""
        var ingredient: String = ""
        var isComplete: Bool = false
        var isDeleted: Bool  = false
    }
    
    var Groceries: [GroceryList] = []
    
    private var hasMealsInList: Bool {
        guard let plannedMenu = plannedMenu else { return false }
        return plannedMenu.count > 0
    }
    
    private func updateView() {
        tableView.isHidden = !hasMealsInList
        emptyTableLabel.isHidden = hasMealsInList
    }
    
    /////////////////////////////
    //View Life Cycle
    /////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Grocery List"
        let tabBar = tabBarController as! BaseTabBarController
        managedObjectContext = tabBar.coreDataManager.managedObjectContext

       self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
             if #available(iOS 13.0, *) {
                 let appearance = UINavigationBarAppearance()
                 appearance.configureWithOpaqueBackground()
                 appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "_White to Teal Label")!]
                 appearance.backgroundColor = UIColor(named: "_Teal Background")!
                 self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
                 
                 appearance.backgroundColor = UIColor(named: "_Teal Background to Tertiary")
                 self.navigationController?.navigationBar.standardAppearance = appearance
             } else {
                 // Fallback on earlier versions
             }
        
        updateView()

//        if (UIAccessibility.isBoldTextEnabled) {
//            self.navigationItem.rightBarButtonItem?.image = nil
//            self.navigationItem.rightBarButtonItem?.title = "Plan"
//            emptyTableLabel.text = "Once you have your Meals Saved, Select Plan to Get Started!"
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //fetchMenu()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//            guard let identifier = segue.identifier else { return }
//
//         switch identifier {
//         case Segue.CreatePlan:
//             guard let destination = segue.destination as? CreatePlanViewController else {
//                 return
//             }
//
//             destination.managedObjectContext = self.managedObjectContext
//
//             //Determine Plan Starting Date
//             var startDate = Date()
//             if (plannedDays!.count > 0) {
//                 startDate = (plannedDays?.last?.date)!
//             }
//
//             destination.startingDatePicker.date = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
//
//         default:
//             break
//         }
    }
    
    /////////////////////////////
    //Core Data Functions
    /////////////////////////////
    private func fetchMenu() {
        plannedMenu = nil
        
        // Execute Fetch Request
        plannedMenu = helpers.fetchPlans(context: self.managedObjectContext!)
        
        //Reload Table View
        if (plannedMenu!.count > 0) {
            var groceryItem = GroceryList()

            for _planned in plannedMenu! {
                //Build Grocery List Array
                
                for _ingredient in (_planned.meal!.ingredients!.allObjects as? [Ingredient])! {
                    groceryItem.plannedMenuItem = _planned.meal!.mealName!
                    //ingredients = meal?.ingredients?.allObjects as? [Ingredient]
                    groceryItem.ingredient = _ingredient.item!
                    Groceries.append(groceryItem)
                }
            }
            
            print(Groceries)
            tableView.reloadData()
        } else {
            //custom list
        }
    }
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    /////////////////////////////
    //Table Functions
    /////////////////////////////
    func numberOfSections(in tableView: UITableView) -> Int {
        //Must add 1 to account for last section of grocery list that will be ad-hoc
        print((plannedMenu?.count)! + 1)
        return (plannedMenu?.count)! + 1
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //ingredients.count
        print(section)
        let count = plannedMenu![section].meal?.ingredients?.count
//        if count == 0 {
//            count = 1
//        }
        
        return count!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let _plannedMenu = plannedMenu?[section] else { fatalError("Unexpected Index Path")}
        return _plannedMenu.meal?.mealName
    }
        
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 10))

        return headerView
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groceryCell", for: indexPath)
        
        // Configure Cell
        if (plannedMenu!.count > 0) {
            configure(cell, at: indexPath)
        } else {
            //create custom list
        }
//
//        if (cell.mealName.text == "👨‍🍳 Restaurant" || cell.mealName.text == "🍴 Leftovers") {
//            cell.selectionStyle = UITableViewCell.SelectionStyle.none
//            cell.isUserInteractionEnabled = false
//        } else {
//            cell.selectionStyle = UITableViewCell.SelectionStyle.default
//            cell.isUserInteractionEnabled = true
//        }
        
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
        return cell
    }
        
        private func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
            // Fetch Meal
            guard let _plannedMenu = plannedMenu?[indexPath.section] else { fatalError("Unexpected Index Path")}
            print(indexPath.section)
            print(indexPath)
            
            // Configure Cell
//            var item = Groceries.first(where: _plannedMenu.meal?.mealName)
//            cell.textLabel
//
//            if (_plannedDay.meal != nil) {
//                if (_plannedDay.meal!.mealImage != nil) {
//                    cell.mealImage?.image = UIImage(data: _plannedDay.meal!.mealImage!)
//                    cell.mealImage.layer.cornerRadius = 8 //cell.mealImage.frame.height/2
//                    cell.mealImage.clipsToBounds = true
//                    cell.mealImage.isHidden = false
//                } else {
//                    cell.mealImage.isHidden = true
//                }

        }
}

//        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//            let cancelAction = UIContextualAction(style: .destructive, title:  "Cancel", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
//                // Fetch Day
//                guard let _plannedDay = self.plannedDays?[indexPath.section] else { fatalError("Unexpected Index Path") }
//
//                // Delete Day
//                if (_plannedDay.meal != nil) {
//                    guard let _meal = _plannedDay.meal else { fatalError("Unexpected Index Path")}
//                    _meal.estimatedNextDate = _meal.previousDate
//                    _meal.nextDate = nil
//                    _meal.previousDate = nil
//                }
//
//                //Need to roll back the planned date for each of the meals coming up after the meal deleted
//                self.managedObjectContext!.delete(_plannedDay)
//
//                //Update the dates for remaining planned days to be a day earlier
//                var i = indexPath.section + 1
//
//                while (i < self.plannedDays!.count) {
//                    self.plannedDays?[i].date = Calendar.current.date(byAdding: .day, value: -1, to: (self.plannedDays?[i].date)!)
//                    self.plannedDays?[i].planEndDate = Calendar.current.date(byAdding: .day, value: -1, to: (self.plannedDays?[i].planEndDate)!)
//
//                    if (self.plannedDays?[i].meal != nil) {
//                        guard let _nextMeal = self.plannedDays?[i].meal else { fatalError("Unexpected Index Path") }
//
//                        _nextMeal.nextDate = Calendar.current.date(byAdding: .day, value: -1, to: _nextMeal.nextDate!)
//                    }
//
//                    i += 1
//                }
//
//                //Attempt Request for Review
//                AppStoreReviewManager.requestReviewIfAppropriate()
//                success(true)
//            })
//
//            cancelAction.image = UIImage(systemName: "trash")
//            //completeAction.
//            cancelAction.backgroundColor = UIColor(red: 122/255, green: 00/255, blue: 38/255, alpha: 1.0)
//
//            return UISwipeActionsConfiguration(actions: [cancelAction])
//        }
//
//        func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//    //COMPLETE
//            let completeAction = UIContextualAction(style: .destructive, title:  "Complete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
//
//                // Fetch Day
//                guard let _plannedDay = self.plannedDays?[indexPath.section] else { fatalError("Unexpected Index Path")}
//
//                if (_plannedDay.meal != nil) {
//                    guard let _meal = _plannedDay.meal else { fatalError("Unexpected Index Path")}
//                    _meal.estimatedNextDate = Calendar.current.date(byAdding: .day, value: Int(_meal.frequency), to: _meal.nextDate!)
//                    _meal.nextDate = nil
//                    _meal.previousDate = nil
//                }
//
//                _plannedDay.isCompleted = true
//                self.managedObjectContext!.delete(_plannedDay)
//
//                //Attempt Request for Review
//                AppStoreReviewManager.requestReviewIfAppropriate()
//                success(true)
//            })
//
//            completeAction.image = UIImage(systemName: "checkmark.circle")
//            //completeAction.backgroundColor = UIColor(red: 150/255, green: 217/255, blue: 217/255, alpha: 1.0)
//            completeAction.backgroundColor = UIColor(named: "_Teal Label")!
//    //REPLACE
//            let replaceAction = UIContextualAction(style: .normal, title:  "Replace", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
//                self.currentIndex = indexPath.section
//                self.performSegue(withIdentifier: "ReplacePlannedMeal", sender: tableView)
//
//                //Attempt Request for Review
//                AppStoreReviewManager.requestReviewIfAppropriate()
//                success(true)
//            })
//
//            replaceAction.image = UIImage(systemName: "arrow.right.arrow.left")
//            replaceAction.title = "Replace" //24E7
//            //replaceAction.title = "\u{2190}\u{2192}\n Replace" //24E7
//            //replaceAction.title = UIImage(systemname: "game controller")
//            //replaceAction.backgroundColor = UIColor(red: 137/255, green: 186/255, blue: 217/255, alpha: 1.0)
//            replaceAction.backgroundColor = UIColor(named: "_Blue Label")!
//    //SHUFFLE
//            let shuffleAction = UIContextualAction(style: .normal, title:  "Shuffle", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
//                // Fetch Day
//                guard let _plannedDay = self.plannedDays?[indexPath.section] else { fatalError("Unexpected Index Path")}
//
//                //Get next meal for current planned category
//                var next = Meal(context: self.managedObjectContext!)
//                next = self.getNextMealforCategory(_category: _plannedDay.category!, _date: _plannedDay.date!, _nextMeal: &next)!
//
//                //If No Meal returned, just get the next meal regardless of category
//                if (next.mealName == nil) {
//                    next = self.getNextMeal(_date: _plannedDay.date!, _nextMeal: &next)
//                }
//
//                //If No Meal still not found, keep the current planned meal in place
//                if (next.mealName == nil) {
//
//                } else {
//                    //Fetch Current Meal
//                    if (_plannedDay.meal != nil) {
//                        guard let _meal = _plannedDay.meal else { fatalError("Unexpected Index Path")}
//
//                        if (_meal.mealName != next.mealName) {
//                            //delete previous meal
//                            _meal.estimatedNextDate = _meal.previousDate
//                            _meal.nextDate = nil
//                            _meal.previousDate = nil
//                            _meal.removeFromPlannedDays(_plannedDay)
//                        }
//                    }
//
//                    //add next meal
//                    next.previousDate = next.estimatedNextDate
//                    next.estimatedNextDate = nil
//                    next.nextDate = _plannedDay.date
//                    next.addToPlannedDays(_plannedDay)
//                }
//
//                //Attempt Request for Review
//                AppStoreReviewManager.requestReviewIfAppropriate()
//                success(true)
//            })
//
//            shuffleAction.image = UIImage(systemName: "shuffle")
//            shuffleAction.title = "\u{2682}\u{2683}\nShuffle"
//            //shuffleAction.backgroundColor = UIColor(red: 137/255, green: 186/255, blue: 217/255, alpha: 1.0)
//            shuffleAction.backgroundColor = UIColor(named: "_Blue Label")!
//            return UISwipeActionsConfiguration(actions: [completeAction,replaceAction,shuffleAction])
//        }
//
