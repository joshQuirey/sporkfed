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
    @IBOutlet weak var _item: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBAction func Done(_ sender: Any) {
        //dismiss Keyboard
        _item.resignFirstResponder()
        _item.text = ""
    }
    
    /////////////////////////////
    //Properties
    /////////////////////////////
//    var managedObjectContext: NSManagedObjectContext?
    private var currentIndex: Int?
    var plannedMenu: [PlannedDay]?
    var numberOfMeals: Int = 0
    var sectionOfAddedItems: Int = 0
    var rowMaxOfAddedItems: Int = 0
    var addedItemsExist: Bool = false
    var helpers = CoreDataHelpers()
    var Groceries: [GroceryList] = []
    var AddedGroceries: [GroceryList] = []
    
    private var hasMealsInList: Bool {
        guard let plannedMenu = plannedMenu else { return false }
        return plannedMenu.count > 0
    }
    
    /////////////////////////////
    //View Life Cycle
    /////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _item.delegate = self
        
        title = "Grocery List"
        let tabBar = tabBarController as! BaseTabBarController
//        managedObjectContext = CoreDataManager.context //tabBar.coreDataManager.managedObjectContext

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
        
        setupNotificationHandling()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchGroceries()
    }
    
    private func setupNotificationHandling() {
         let notificationCenter = NotificationCenter.default
         notificationCenter.addObserver(self,
                                        selector: #selector(managedObjectContextObjectsDidChange(_:)),
                                        name: Notification.Name.NSManagedObjectContextObjectsDidChange,
                                        object: CoreDataManager.context) // self.managedObjectContext)
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
                    let keyboardHeight: CGFloat = (endFrame?.size.height)! - 60
                    self.bottomConstraint?.constant = keyboardHeight
                } else {
                    self.bottomConstraint?.constant = 10.0
                }
            }
                
            self.tableView.scrollToBottomRow(section: sectionOfAddedItems)
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
            tableView.scrollToBottomRow(section: sectionOfAddedItems)
            textField.text = nil
        }

        return true
    }
    
    /////////////////////////////
    //Core Data Functions
    /////////////////////////////
    @objc private func managedObjectContextObjectsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        var groceryListDidChange = false
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> {
            print("Context Inserts Exist Grocery")
            for insert in inserts {
                if let item = insert as? GroceryList {
                    Groceries.append(item)

                    if item.mealIndex == sectionOfAddedItems {
                        AddedGroceries.append(item)
                    }
                    
                    groceryListDidChange = true
                }
            }
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
            print("Context Updates Exist Grocery")
            for update in updates {
                if update is GroceryList {
                    groceryListDidChange = true
                }
            }
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> {
            print("Context Deletes Exist Grocery")
            for delete in deletes {
                if let item = delete as? GroceryList {
                    if let index = Groceries.firstIndex(of: item) {
                        Groceries.remove(at: index)
                        groceryListDidChange = true
                    }
                }
            }
        }
        
        if groceryListDidChange {
            tableView.reloadData()
            groceryListDidChange = false
        }
    }
    
    func deleteGroceries() {
        helpers.deleteGroceries(context: CoreDataManager.context)  // self.managedObjectContext!)
    }
    
    func fetchGroceries() {
        plannedMenu = []
        numberOfMeals = 0
        Groceries = []
               
        // Execute Fetch Request
        let fullPlannedMenu: [PlannedDay] = helpers.fetchPlans(context: CoreDataManager.context) // self.managedObjectContext!)
        //need to change planned menu to not include restaurant days or leftovers
        for menu in fullPlannedMenu {
           if (menu.meal != nil) {
               plannedMenu?.append(menu)
                numberOfMeals += 1
           }
        }
        
        Groceries = helpers.fetchGroceries(context: CoreDataManager.context) // managedObjectContext!)
        var prevMeal: String = ""

        for item in Groceries {
            if item.mealName != "" {
                if prevMeal == "" {
                    prevMeal = item.mealName!
                    //numberOfMeals += 1
                }
            }

            prevMeal = item.mealName!
        }
        
        print("Fetch Number of Meals \(numberOfMeals)")
        sectionOfAddedItems = numberOfMeals
    }
    
    func refreshList() {
        helpers.deleteGroceries(context: CoreDataManager.context) // self.managedObjectContext!)

        plannedMenu = []
        numberOfMeals = 0
        Groceries = []
        
        // Execute Fetch Request
        let fullPlannedMenu: [PlannedDay] = helpers.fetchPlans(context: CoreDataManager.context) // self.managedObjectContext!)
        //need to change planned menu to not include restaurant days or leftovers
        for menu in fullPlannedMenu {
            if (menu.meal != nil) {
                plannedMenu?.append(menu)
                numberOfMeals += 1
            }
        }
                
        sectionOfAddedItems = numberOfMeals
        //Reload Table View
        if (numberOfMeals > 0) {
            var groceryItem = GroceryList()
            var mealIndex: Int = 0
            for _planned in plannedMenu! {
                if (_planned.meal?.mealName != nil) {
                    var itemIndex: Int = 0
                   
                    for _ingredient in (_planned.meal!.ingredients!.allObjects as? [Ingredient])! {
                        groceryItem = GroceryList(context: CoreDataManager.context) // managedObjectContext!)
                        groceryItem.mealName = _planned.meal!.mealName!
                        groceryItem.mealIndex = Int16(mealIndex)
                        groceryItem.itemIndex = Int16(itemIndex)
                        groceryItem.itemName = _ingredient.item!
                        groceryItem.isComplete = false

                        itemIndex += 1
                    }
                    mealIndex += 1
                }
            }
        } else {
            //custom list
        }
    }
    
    /////////////////////////////
    //Helper Functions
    /////////////////////////////
    func uncrossGroceries() {
        for item in Groceries {
            if item.isComplete == true {
                item.isComplete = false
            }
        }
    }
    
    @IBAction func elipsesButton(_ sender: Any) {
        let alert = UIAlertController(title: "List Options", message:nil, preferredStyle: .actionSheet)

        let syncImage = UIImage(systemName: "arrow.counterclockwise")
        let syncAction = UIAlertAction(title: "Sync Menu", style: .default , handler:{ (UIAlertAction)in
            DispatchQueue.main.async {
                self.refreshList()
            }
        })
        syncAction.setValue(syncImage, forKey: "image")
        alert.addAction(syncAction)

        let deleteImage = UIImage(systemName: "trash")
        let deleteAction = UIAlertAction(title: "Delete All Items", style: .default , handler:{ (UIAlertAction)in
            DispatchQueue.main.async {
                self.deleteGroceries()
            }
        })
        deleteAction.setValue(deleteImage, forKey: "image")
        alert.addAction(deleteAction)

        let uncrossImage = UIImage(systemName: "strikethrough")
        let uncrossAction = UIAlertAction(title: "Uncross All Items", style: .default , handler:{ (UIAlertAction)in
            DispatchQueue.main.async {
                self.uncrossGroceries()
            }
        })
        uncrossAction.setValue(uncrossImage, forKey: "image")
        alert.addAction(uncrossAction)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler:{ (UIAlertAction)in
        }))

        alert.view.tintColor = UIColor(named: "_Purple to Teal")!
        self.present(alert, animated: true, completion: nil)
        }

    func addNewItem() {
        let groceryItem = GroceryList(context: CoreDataManager.context) // managedObjectContext!)
        groceryItem.mealIndex = Int16(sectionOfAddedItems)

        if self.Groceries.count > 0 {
            guard let lastAddedItem = self.Groceries.last else { fatalError("Unexpected Result")}
              
            if lastAddedItem.mealIndex == sectionOfAddedItems {
                groceryItem.itemIndex = lastAddedItem.itemIndex + 1
            } else {
                groceryItem.itemIndex = 0
            }
        } else {
            groceryItem.itemIndex = 0
        }
            
        groceryItem.mealName = ""
        groceryItem.itemName = _item.text!
        groceryItem.isComplete = false
        
        rowMaxOfAddedItems += 1
        addedItemsExist = true
    }
    
    /////////////////////////////
    //Table Functions
    /////////////////////////////
    func numberOfSections(in tableView: UITableView) -> Int {
        print("Number of Sections \(numberOfMeals+1)")
        return numberOfMeals + 1
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0

        for _ingredient in Groceries {
            if (_ingredient.mealIndex == section) {
                    count += 1
            }
        }
        
        print("Number of Rows \(count)")
        return count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor(named: "_Off-White Background to Tertiary")
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.frame.size.width, height: 35))
        label.font = .systemFont(ofSize: 20)
        label.textColor = .systemGray
        view.layer.cornerRadius = 8
        
        if (sectionOfAddedItems != section && sectionOfAddedItems != 0) {
            label.text = plannedMenu![section].meal?.mealName//_plannedMenu?.mealName
        } else {
            label.text = "Additional Items"
        }
        
        view.addSubview(label)
        //_view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groceryCell", for: indexPath)
        
        // Configure Cell
        let object = Groceries.first(where: { $0.mealIndex == indexPath.section && $0.itemIndex == indexPath.row })
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: object!.itemName!)
            
        if object?.isComplete == true {
            let len = object?.itemName?.count
            attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 3, range: NSMakeRange(0, len!))
            attributedString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor(named: "_Purple to Teal")!, range: NSMakeRange(0, len!))
        }
            
        cell.textLabel!.attributedText = attributedString
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var isComplete: Bool = false
        let currentCell = tableView.cellForRow(at: indexPath)
        
        // Fetch Ingredient
        guard let currentIndex = self.Groceries.firstIndex(where: { $0.mealIndex == indexPath.section && $0.itemIndex == indexPath.row}) else { fatalError("Unexpected Index Path") }
        
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
                attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 5, range: NSMakeRange(0, len))
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
            guard let currentItem = self.Groceries.first(where: { $0.mealIndex == indexPath.section && $0.itemIndex == indexPath.row}) else { fatalError("Unexpected Index Path") }
            
            //remove item
            currentItem.managedObjectContext?.delete(currentItem)
            let menuItems = self.Groceries.filter({ $0.mealIndex == indexPath.section })
            
            for item in menuItems {
                if item.itemIndex > indexPath.row {
                    guard let item = self.Groceries.first(where: { $0.mealIndex == indexPath.section && $0.itemIndex == item.itemIndex}) else { fatalError("Unexpected Index Path") }
                    item.itemIndex -= 1
                }
            }

            success(true)
        })

        cancelAction.image = UIImage(systemName: "trash")
        cancelAction.backgroundColor = UIColor(red: 122/255, green: 00/255, blue: 38/255, alpha: 1.0)
        return UISwipeActionsConfiguration(actions: [cancelAction])
    }
}


extension UITableView {
    func scrollToBottomRow(section: Int) {
        DispatchQueue.main.async {
            guard self.numberOfSections > 0 else { return }
            //print("number of sections - \(self.numberOfSections)")
            // Make an attempt to use the bottom-most section with at least one row
            var section = max(self.numberOfSections - 1, 0)
            var row = max(self.numberOfRows(inSection: section), 0)
            //print("section - \(section)")
            //print("row - \(row)")
            var indexPath = IndexPath(row: row, section: section)
            // Ensure the index path is valid, otherwise use the section above (sections can
            // contain 0 rows which leads to an invalid index path)
            if !self.indexPathIsValid(indexPath) {
                section = max(section, 0)
                row = max(self.numberOfRows(inSection: section) - 1, 0)
                indexPath = IndexPath(row: row, section: section)
            }
            
            while !self.indexPathIsValid(indexPath) {
                section = max(section-1, 0)
                row = max(self.numberOfRows(inSection: section) - 1, 0)
                indexPath = IndexPath(row: row, section: section)
                print("section2 - \(section)")
                print("row2 - \(row)")
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
