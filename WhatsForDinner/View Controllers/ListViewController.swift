//
//  ListViewController.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 11/1/19.
//  Copyright © 2019 jquirey. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    /////////////////////////////
    //Outlets
    /////////////////////////////
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyTableLabel: UILabel!
    @IBOutlet weak var _item: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBAction func RefreshList(_ sender: Any) {
        fetchGroceries()
        if AddedGroceries.count > 0 {
            for item in AddedGroceries {
                Groceries.append(item)
            }
        }
        tableView.reloadData()
    }
    
    @IBAction func Done(_ sender: Any) {
        //dismiss Keyboard
        _item.resignFirstResponder()
        _item.text = ""
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
    var sectionOfAddedItems: Int = 0
    var rowMaxOfAddedItems: Int = 0
    var addedItemsExist: Bool = false
    
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
    var AddedGroceries: [GroceryList] = []
    
    private var hasMealsInList: Bool {
        guard let plannedMenu = plannedMenu else { return false }
        return plannedMenu.count > 0
    }
    
    private func updateView() {
        //tableView.isHidden = !hasMealsInList
        //emptyTableLabel.isHidden = hasMealsInList
    }
    
    /////////////////////////////
    //View Life Cycle
    /////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _item.delegate = self
        
        title = "Grocery List"
        let tabBar = tabBarController as! BaseTabBarController
        managedObjectContext = tabBar.coreDataManager.managedObjectContext

        tableView.tableFooterView = UIView()
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        
        if #available(iOS 13.0, *) {
         let appearance = UINavigationBarAppearance()
         appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
         appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "_White to Teal Label")!]
         appearance.backgroundColor = UIColor(named: "_Teal Background")!
         self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
         
         appearance.backgroundColor = UIColor(named: "_Teal Background to Tertiary")
         self.navigationController?.navigationBar.standardAppearance = appearance
        } else {
         // Fallback on earlier versions
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        
        updateView()

    }
    
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.bottomConstraint?.constant = 10.0
            } else {
                if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                    //print(keyboardSize.height)
                    //print(endFrame?.size.height)
                    let keyboardHeight: CGFloat = (endFrame?.size.height)! - 60
                    self.bottomConstraint?.constant = keyboardHeight
                } else {
                    self.bottomConstraint?.constant = 10.0
                }
            }
                
            self.tableView.scrollToBottomRow()
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil
            )
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (addedItemsExist) {
            let indexPath = NSIndexPath(row: 0, section: sectionOfAddedItems)
            tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.text != nil && textField.text != "") {
            addNewItem()
            tableView.scrollToBottomRow()
            textField.text = nil
        }

        return true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if Groceries.count > 0 {
            print("already exists")
            //fetchMenu()
        } else {
            print(Groceries)
            fetchGroceries()
            tableView.reloadData()
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    }
    
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
        
        sectionOfAddedItems = numberOfMeals
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
            
            //Add Additional Items
            
            print(Groceries)
           //tableView.reloadData()
        } else {
            //custom list
        }
    }

    func addNewItem() {
        var groceryItem = GroceryList()
        groceryItem.menuIndex = sectionOfAddedItems
        print(sectionOfAddedItems)
        print(addedItemsExist)
        //Have to check to see if there are items at this index first
        //guard let itemsExist = self.Groceries.filter({ $0.menuIndex == indexOfAddedItems }) else { fatalError("Unexpected Index Path")}
        
        //if addedItemsExist == true {
        if self.Groceries.count > 0 {
            guard let lastAddedItem = self.Groceries.last else { fatalError("Unexpected Result")}
               //self.Groceries.last(where: { $0.menuIndex == indexOfAddedItems }) else { fatalError("Unexpected Index Path")}
            if lastAddedItem.menuIndex == sectionOfAddedItems {
                //groceryItem.menuIndex = sectionOfAddedItems
                groceryItem.ingredientIndex = lastAddedItem.ingredientIndex + 1
            } else {
                //groceryItem.menuIndex = sectionOfAddedItems
                groceryItem.ingredientIndex = 0
            }
        } else {
            groceryItem.ingredientIndex = 0
        }
            
            groceryItem.plannedMenuItem = ""
            groceryItem.ingredient = _item.text!
            Groceries.append(groceryItem)
            AddedGroceries.append(groceryItem)
            rowMaxOfAddedItems += 1
            addedItemsExist = true
            tableView.reloadData()
    }
    
    
    /////////////////////////////
    //Table Functions
    /////////////////////////////
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //Must add 1 to account for last section of grocery list that will be ad-hoc
        print("Number of Sections \(numberOfMeals+1)")
       
        return numberOfMeals + 1
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
        tableView.sectionIndexBackgroundColor = UIColor(named: "_Teal Label")
    
        tableView.sectionIndexColor = UIColor(named: "_Teal Label")
        if (sectionOfAddedItems != section) {
            guard let _plannedMenu = plannedMenu?[section] else { fatalError("Unexpected Index Path")}
            return _plannedMenu.meal?.mealName
        } else {
            return "Additional Items"
        }
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groceryCell", for: indexPath)
        
        // Configure Cell
//        if (numberOfMeals > 0) {
            let object = Groceries.first(where: { $0.menuIndex == indexPath.section && $0.ingredientIndex == indexPath.row })
            
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: object!.ingredient)
            
            if object?.isComplete == true {
                let len = object?.ingredient.count
                attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 3, range: NSMakeRange(0, len!))
                attributedString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor(named: "_Purple Label")!, range: NSMakeRange(0, len!))
            }
            
            cell.textLabel!.attributedText = attributedString
//        } else {
//            //create custom list
//
//        }
        
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var isComplete: Bool = false
        let currentCell = tableView.cellForRow(at: indexPath)
        // Fetch Ingredient
        //guard let currentItem = self.Groceries.first(where: { $0.menuIndex == indexPath.section && $0.ingredientIndex == indexPath.row}) else { fatalError("Unexpected Index Path") }
        guard let currentIndex = self.Groceries.firstIndex(where: { $0.menuIndex == indexPath.section && $0.ingredientIndex == indexPath.row}) else { fatalError("Unexpected Index Path") }
        
        isComplete = self.Groceries[currentIndex].isComplete
        
        let completeAction = UIContextualAction(style: .destructive, title:  "Cancel", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            if isComplete == true {
                self.Groceries[currentIndex].isComplete = false
                
                let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: (currentCell?.textLabel!.text)!)
                currentCell?.textLabel?.attributedText = attributedString
            } else {
                self.Groceries[currentIndex].isComplete = true
                let len = (currentCell?.textLabel?.attributedText!.length)!
                let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: (currentCell?.textLabel!.text)!)
                attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 3, range: NSMakeRange(0, len))
                attributedString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor(named: "_Purple Label")!, range: NSMakeRange(0, len))
        
                currentCell?.textLabel?.attributedText = attributedString
            }
            
            success(true)
        })

        if isComplete == false {
            completeAction.image = UIImage(systemName: "checkmark")
        } else {
            completeAction.image = UIImage(systemName: "xmark")
        }
        
        completeAction.backgroundColor = UIColor(named: "_Purple Label")
        return UISwipeActionsConfiguration(actions: [completeAction])
    }
    

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cancelAction = UIContextualAction(style: .destructive, title:  "Cancel", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            // Fetch Ingredient Index
            guard let currentIndex = self.Groceries.firstIndex(where: { $0.menuIndex == indexPath.section && $0.ingredientIndex == indexPath.row}) else { fatalError("Unexpected Index Path") }
            
            //remove item
            self.Groceries.remove(at: currentIndex)
            //update ingredient index
            let menuItems = self.Groceries.filter({ $0.menuIndex == indexPath.section })
            for item in menuItems {
                if item.ingredientIndex > indexPath.row {
                    guard let itemIndex = self.Groceries.firstIndex(where: { $0.menuIndex == indexPath.section && $0.ingredientIndex == item.ingredientIndex}) else { fatalError("Unexpected Index Path") }
                    self.Groceries[itemIndex].ingredientIndex -= 1
                }
            }
            
            //Attempt Request for Review
            //AppStoreReviewManager.requestReviewIfAppropriate()
            tableView.reloadData()
            success(true)
        })

        cancelAction.image = UIImage(systemName: "trash")
        cancelAction.backgroundColor = UIColor(red: 122/255, green: 00/255, blue: 38/255, alpha: 1.0)
        return UISwipeActionsConfiguration(actions: [cancelAction])
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let currentCell = tableView.cellForRow(at: indexPath)
//        guard let currentIndex = self.Groceries.firstIndex(where: { $0.menuIndex == indexPath.section && $0.ingredientIndex == indexPath.row}) else { fatalError("Unexpected Index Path") }
//        Groceries[currentIndex].isComplete = true
//
//        let len = (currentCell?.textLabel?.attributedText!.length)!
//        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: (currentCell?.textLabel!.text)!)
//        attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 3, range: NSMakeRange(0, len))
//        attributedString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.systemRed, range: NSMakeRange(0, len))
//        attributedString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.systemRed, range: NSMakeRange(0, len))//
//        currentCell?.textLabel?.attributedText = attributedString
//
//         let selectionFeedback = UIImpactFeedbackGenerator(style: .medium)
//        selectionFeedback.prepare()
//        selectionFeedback.impactOccurred()
//    }
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let currentCell = tableView.cellForRow(at: indexPath)
//        guard let currentIndex = self.Groceries.firstIndex(where: { $0.menuIndex == indexPath.section && $0.ingredientIndex == indexPath.row}) else { fatalError("Unexpected Index Path") }
//
//        Groceries[currentIndex].isComplete = false
//
//        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: (currentCell?.textLabel!.text)!)
//        currentCell?.textLabel?.attributedText = attributedString
//
//        let selectionFeedback = UIImpactFeedbackGenerator(style: .medium)
//        selectionFeedback.prepare()
//        selectionFeedback.impactOccurred()
//    }
}


extension UITableView {
    func scrollToBottomRow() {
        DispatchQueue.main.async {
            guard self.numberOfSections > 0 else { return }
            
            // Make an attempt to use the bottom-most section with at least one row
            var section = max(self.numberOfSections - 1, 0)
            var row = max(self.numberOfRows(inSection: section) - 1, 0)
            var indexPath = IndexPath(row: row, section: section)
            
            // Ensure the index path is valid, otherwise use the section above (sections can
            // contain 0 rows which leads to an invalid index path)
            while !self.indexPathIsValid(indexPath) {
                section = max(section - 1, 0)
                row = max(self.numberOfRows(inSection: section) - 1, 0)
                indexPath = IndexPath(row: row, section: section)
                
                // If we're down to the last section, attempt to use the first row
                if indexPath.section == 0 {
                    indexPath = IndexPath(row: 0, section: 0)
                    break
                }
            }
            
            // In the case that [0, 0] is valid (perhaps no data source?), ensure we don't encounter an
            // exception here
            guard self.indexPathIsValid(indexPath) else { return }
            
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func indexPathIsValid(_ indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        let row = indexPath.row
        return section < self.numberOfSections && row < self.numberOfRows(inSection: section)
    }
}
