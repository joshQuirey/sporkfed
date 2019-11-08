//
//  ListViewController.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 11/1/19.
//  Copyright © 2019 jquirey. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    /////////////////////////////
    //Outlets
    /////////////////////////////
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyTableLabel: UILabel!
    
    @IBAction func RefreshList(_ sender: Any) {
        fetchGroceries()
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

    var numberOfMeals: Int = 0
    
    var helpers = CoreDataHelpers()
    //define List struct
    struct GroceryList {
        var menuIndex: Int = 0
        var ingredientIndex: Int = 0
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
        if Groceries.count > 0 {
            print("already exists")
            //fetchMenu()
        } else {
            print(Groceries)
            fetchGroceries()
        }
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
    private func fetchGroceries() {
        plannedMenu = []
        numberOfMeals = 0
        Groceries = []
        
        // Execute Fetch Request
        let fullPlannedMenu: [PlannedDay] = helpers.fetchPlans(context: self.managedObjectContext!)
        //need to change planned menu to not include restaurant days or leftovers
        for menu in fullPlannedMenu {
            print(fullPlannedMenu)
            if (menu.meal != nil) {
//                print(menu)
                plannedMenu?.append(menu)
                numberOfMeals += 1
            }
        }
        
//        print(plannedMenu)
        //Reload Table View
        if (numberOfMeals > 0) {
            var groceryItem = GroceryList()
            var menuIndex: Int = 0
            for _planned in plannedMenu! {
                //Build Grocery List Array
//                print(_planned.meal?.mealName)
                if (_planned.meal?.mealName != nil) {
                    var ingredientIndex: Int = 0
                    for _ingredient in (_planned.meal!.ingredients!.allObjects as? [Ingredient])! {
                        groceryItem.menuIndex = menuIndex
                        groceryItem.ingredientIndex = ingredientIndex
                        groceryItem.plannedMenuItem = _planned.meal!.mealName!
                        //ingredients = meal?.ingredients?.allObjects as? [Ingredient]
                        groceryItem.ingredient = _ingredient.item!
                        Groceries.append(groceryItem)
                        ingredientIndex += 1
                    }
                    menuIndex += 1
                }
            }
            
            print(Groceries)
            tableView.reloadData()
        } else {
            //custom list
        }
    }
    
    private func refreshGroceries(_itemName: String, _menuIndex: Int, _isDeleted: Bool = false, _isComplete: Bool = false) {
            Groceries = []
            
            //Reload Table View
            if (numberOfMeals > 0) {
                var groceryItem = GroceryList()
                var menuIndex: Int = 0
                for _planned in plannedMenu! {
                    if (_planned.meal?.mealName != nil) {
                        var ingredientIndex: Int = 0
                        for _ingredient in (_planned.meal!.ingredients!.allObjects as? [Ingredient])! {
                            if _itemName != _ingredient.item || (_menuIndex != menuIndex && _itemName == _ingredient.item) {
                                groceryItem.menuIndex = menuIndex
                                groceryItem.ingredientIndex = ingredientIndex
                                groceryItem.plannedMenuItem = _planned.meal!.mealName!
                                groceryItem.ingredient = _ingredient.item!
                                //if in list and now marked complete
                                if _itemName == _ingredient.item && _menuIndex == menuIndex {
                                    groceryItem.isComplete = _isComplete
                                }
                                Groceries.append(groceryItem)
                                ingredientIndex += 1
                            }
                        }
                        menuIndex += 1
                    }
                }
                
                print(Groceries)
                tableView.reloadData()
            } else {
                //custom list
            }
        }

    /////////////////////////////
    //Table Functions
    /////////////////////////////
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //Must add 1 to account for last section of grocery list that will be ad-hoc
        print("Number of Sections \(numberOfMeals)")
        return numberOfMeals //+ 1
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0

        for _ingredient in Groceries {
            if (_ingredient.menuIndex == section) { //} && _ingredient.isDeleted == false) {
                count += 1
            }
        }
        
        print("Number of Rows \(count)")
        return count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let _plannedMenu = plannedMenu?[section] else { fatalError("Unexpected Index Path")}

        return _plannedMenu.meal?.mealName
    }
        
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 10))
//
//        return headerView
//    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groceryCell", for: indexPath)
        
        // Configure Cell
        if (numberOfMeals > 0) {
            configure(cell, at: indexPath)
        } else {
            //create custom list
        }
        
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        return cell
    }
        
        private func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
            
//            print(indexPath.section)
//            print(indexPath.row)
            // Fetch Meal
           // guard let _plannedMenu = plannedMenu?[indexPath.section] else { fatalError("Unexpected Index Path")}
            let object = Groceries.first(where: { $0.menuIndex == indexPath.section && $0.ingredientIndex == indexPath.row })
            
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: object!.ingredient)
            
            if object?.isComplete == true {
                let len = object?.ingredient.count
                attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 3, range: NSMakeRange(0, len!))
                attributedString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.systemRed, range: NSMakeRange(0, len!))
            }
            
            cell.textLabel!.attributedText = attributedString
//            cell.textLabel!.text = object?.ingredient
        }

        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let cancelAction = UIContextualAction(style: .destructive, title:  "Cancel", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                //let currentCell = tableView.cellForRow(at: indexPath)
                // Fetch Ingredient
                guard let currentItem = self.Groceries.first(where: { $0.menuIndex == indexPath.section && $0.ingredientIndex == indexPath.row}) else { fatalError("Unexpected Index Path") }
                
                //refresh groceries
                self.refreshGroceries(_itemName: currentItem.ingredient, _menuIndex: currentItem.menuIndex, _isDeleted: true)
                
                //Attempt Request for Review
                //AppStoreReviewManager.requestReviewIfAppropriate()

                success(true)
            })

            cancelAction.image = UIImage(systemName: "trash")
            //completeAction.
            cancelAction.backgroundColor = UIColor(red: 122/255, green: 00/255, blue: 38/255, alpha: 1.0)

            return UISwipeActionsConfiguration(actions: [cancelAction])
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let currentCell = tableView.cellForRow(at: indexPath)
        // Fetch Ingredient
        guard let currentItem = self.Groceries.first(where: { $0.menuIndex == indexPath.section && $0.ingredientIndex == indexPath.row}) else { fatalError("Unexpected Index Path") }
        
        self.refreshGroceries(_itemName: currentItem.ingredient, _menuIndex: currentItem.menuIndex, _isDeleted: false, _isComplete: true)
        //let len = (currentCell?.textLabel?.attributedText!.length)!
        //let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: (currentCell?.textLabel!.text)!)

        //attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 3, range: NSMakeRange(0, len))
        //attributedString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.systemRed, range: NSMakeRange(0, len))
//        attributedString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.systemRed, range: NSMakeRange(0, len))//
       // currentCell?.textLabel?.attributedText = attributedString
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //let currentCell = tableView.cellForRow(at: indexPath)
        // Fetch Ingredient
        guard let currentItem = self.Groceries.first(where: { $0.menuIndex == indexPath.section && $0.ingredientIndex == indexPath.row}) else { fatalError("Unexpected Index Path") }
        
        self.refreshGroceries(_itemName: currentItem.ingredient, _menuIndex: currentItem.menuIndex, _isDeleted: false, _isComplete: false)
        //let len = (currentCell?.textLabel?.attributedText!.length)!
          //let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: (currentCell?.textLabel!.text)!)
          //attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, len))
          //attributedString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.systemRed, range: NSMakeRange(0, len))
          //currentCell?.textLabel?.attributedText = attributedString
    }
}
