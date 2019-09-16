//
//  PlanViewController.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 8/7/18.
//  Copyright © 2018 jquirey. All rights reserved.
//

import UIKit
import CoreData


struct MyVariables {
    static var test = "strings"
}


class PlanViewController: UIViewController {
    /////////////////////////////
    //Outlets
    /////////////////////////////
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyTableLabel: UILabel!
    
    /////////////////////////////
    //Properties
    /////////////////////////////
    var managedObjectContext: NSManagedObjectContext?
    private var currentIndex: Int?
    
    var plannedDays: [PlannedDay]? {
        didSet {
            updateView()
        }
    }
    
    private var hasPlans: Bool {
        guard let plannedDays = plannedDays else { return false }
        return plannedDays.count > 0
    }
    
    /////////////////////////////
    //Segues
    /////////////////////////////
    private enum Segue {
        static let CreatePlan = "CreatePlan"
        static let ViewPlannedMeal = "ViewPlannedMeal"
        static let ReplacePlannedMeal = "ReplacePlannedMeal"
    }
    
    private func updateView() {
        tableView.isHidden = !hasPlans
        emptyTableLabel.isHidden = hasPlans
    }
    
    /////////////////////////////
    //View Life Cycle
    /////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabBar = tabBarController as! BaseTabBarController
        managedObjectContext = tabBar.coreDataManager.managedObjectContext
        
        let logo = UIImageView()
        logo.image = UIImage(named: "sporkfed_whitelogo")
        logo.contentMode = .scaleAspectFit
        self.navigationItem.titleView = logo
        
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
        setupNotificationHandling()
        
        if (UIAccessibility.isBoldTextEnabled) {
            self.navigationItem.rightBarButtonItem?.image = nil
            self.navigationItem.rightBarButtonItem?.title = "Plan"
            emptyTableLabel.text = "Once you have your Meals Saved, Select Plan to Get Started!"
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    private func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(managedObjectContextObjectsDidChange(_:)),
                                       name: Notification.Name.NSManagedObjectContextObjectsDidChange,
                                       object: self.managedObjectContext)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(savePlans(_:)),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchPlans()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case Segue.CreatePlan:
            guard let destination = segue.destination as? CreatePlanViewController else {
                return
            }

            destination.managedObjectContext = self.managedObjectContext
            
            //Determine Plan Starting Date
            var startDate = Date()
            if (plannedDays!.count > 0) {
                startDate = (plannedDays?.last?.date)!
            }
            
            destination.startingDatePicker.date = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
            
        case Segue.ViewPlannedMeal:
            guard let destination = segue.destination as? RecipeViewController else {
                return
            }
            
            destination.managedObjectContext = self.managedObjectContext
            let _indexpath = tableView.indexPathForSelectedRow
            let _meal = plannedDays![(_indexpath!.section)].meal
            destination.meal = _meal
        
        case Segue.ReplacePlannedMeal:
            guard let destination = segue.destination as? ReplaceMealController else {
                return
            }
            
            destination.managedObjectContext = self.managedObjectContext
            destination.currentPlannedDay = plannedDays![(self.currentIndex!)]
            
        default:
            break
        }
    }
    
    /////////////////////////////
    //Core Data Functions
    /////////////////////////////
    @objc private func managedObjectContextObjectsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        var planDidChange = false
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> {
            print("Context Inserts Exist Plan")
            for insert in inserts {
                if let plannedDay = insert as? PlannedDay {
                    plannedDays?.append(plannedDay)
                    planDidChange = true
                }
                
                if let plannedMeal = insert as? Meal {
                    if (plannedMeal.mealName == nil) {
                        self.managedObjectContext!.delete(plannedMeal)
                    }
                }
            }
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
            print("Context Updates Exist Plan")
            for update in updates {
                if update is PlannedDay {
                    planDidChange = true
                }
                
                if update is Meal {
                    planDidChange = true
                }
            }
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> {
            print("Context Deletes Exist Plan")
            for delete in deletes {
                if let plannedDay = delete as? PlannedDay {
                    if let index = plannedDays?.firstIndex(of: plannedDay) {
                        plannedDays?.remove(at: index)
                        planDidChange = true
                    }
                }
            }
        }
        
        if planDidChange {
            //Sort
            plannedDays = plannedDays?.sorted(by: { $0.date!.compare($1.date!) == .orderedAscending })
            
            //Update Table View
            tableView.reloadData()
            
            //Update View
            planDidChange = false
        }
    }
    
    @objc private func savePlans(_ notification: Notification) {
        do {
            try self.managedObjectContext!.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    private func fetchPlans() {
        // Create Fetch Request
        plannedDays = nil
        let fetchRequest: NSFetchRequest<PlannedDay> = PlannedDay.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.predicate = NSPredicate(format: "isCompleted == nil")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(PlannedDay.date), ascending: true)]
        
        // Perform Fetch Request
        self.managedObjectContext!.performAndWait {
            do {
                // Execute Fetch Request
                plannedDays = try fetchRequest.execute()
                
                //Reload Table View
                if (plannedDays!.count > 0) {
                    tableView.reloadData()
                }
            } catch {
                let fetchError = error as NSError
                print("Unable to Execute Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
        }
    }
}

extension PlanViewController: UITableViewDataSource, UITableViewDelegate {
    /////////////////////////////
    //Table Functions
    /////////////////////////////
    func numberOfSections(in tableView: UITableView) -> Int {
        return (plannedDays?.count)!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 10))

        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "planCell", for: indexPath) as! PlanTableViewCell
        
        // Configure Cell
        if (plannedDays!.count > 0) {
            configure(cell, at: indexPath)
        }
        
        if (cell.mealName.text == "👨‍🍳 Restaurant" || cell.mealName.text == "🍴 Leftovers") {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.isUserInteractionEnabled = false
        } else {
            cell.selectionStyle = UITableViewCell.SelectionStyle.default
            cell.isUserInteractionEnabled = true
        }
        
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
        return cell
    }
    
    private func configure(_ cell: PlanTableViewCell, at indexPath: IndexPath) {
        // Fetch Meal
        guard let _plannedDay = plannedDays?[indexPath.section] else { fatalError("Unexpected Index Path")}
        
        // Configure Cell
        let date = plannedDays![indexPath.section].date
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        cell.planDate.text = formatter.string(from: date!)
    
        formatter.dateFormat = "MMM"
        cell.planMonth.text = formatter.string(from: date!)
    
        formatter.dateFormat = "EEE"
        cell.planDay.text = formatter.string(from: date!)
    
        if (_plannedDay.meal != nil) {
            if (_plannedDay.meal!.mealImage != nil) {
                cell.mealImage?.image = UIImage(data: _plannedDay.meal!.mealImage!)
                cell.mealImage.layer.cornerRadius = 8 //cell.mealImage.frame.height/2
                cell.mealImage.clipsToBounds = true
                cell.mealImage.isHidden = false
            } else {
                cell.mealImage.isHidden = true
            }
            
            cell.mealName?.text =  _plannedDay.meal!.mealName
            
            cell.mealCategories?.text = ""
            for _tag in (_plannedDay.meal!.tags?.allObjects)! {
                let tag = _tag as! Tag
                cell.mealCategories?.text?.append("\(tag.name!) ")
            }
            
            if (_plannedDay.meal!.prepTime != "") {
                cell.prep?.text? = "Prep: \(_plannedDay.meal!.prepTime!)"
            } else {
                cell.prep?.text? = " "
            }
            
            if (_plannedDay.meal!.cookTime != nil && _plannedDay.meal!.cookTime! != "") {
                cell.cook?.text? = "Cook: \(_plannedDay.meal!.cookTime!)"
            } else {
                cell.cook?.text? = " "
            }
        } else {
            cell.mealImage.isHidden = true
            cell.mealName?.text = _plannedDay.category
            cell.mealCategories?.text = ""
            cell.prep?.text = ""
            cell.cook?.text = ""
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cancelAction = UIContextualAction(style: .destructive, title:  "Cancel", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            // Fetch Day
            guard let _plannedDay = self.plannedDays?[indexPath.section] else { fatalError("Unexpected Index Path") }
            
            // Delete Day
            if (_plannedDay.meal != nil) {
                guard let _meal = _plannedDay.meal else { fatalError("Unexpected Index Path")}
                _meal.estimatedNextDate = _meal.previousDate
                _meal.nextDate = nil
                _meal.previousDate = nil
            }
            
            //Need to roll back the planned date for each of the meals coming up after the meal deleted
            self.managedObjectContext!.delete(_plannedDay)
            
            //Update the dates for remaining planned days to be a day earlier
            var i = indexPath.section + 1
        
            while (i < self.plannedDays!.count) {
                self.plannedDays?[i].date = Calendar.current.date(byAdding: .day, value: -1, to: (self.plannedDays?[i].date)!)
                self.plannedDays?[i].planEndDate = Calendar.current.date(byAdding: .day, value: -1, to: (self.plannedDays?[i].planEndDate)!)
                
                if (self.plannedDays?[i].meal != nil) {
                    guard let _nextMeal = self.plannedDays?[i].meal else { fatalError("Unexpected Index Path") }
                    
                    _nextMeal.nextDate = Calendar.current.date(byAdding: .day, value: -1, to: _nextMeal.nextDate!)
                }
                
                i += 1
            }
            
            //Attempt Request for Review
            AppStoreReviewManager.requestReviewIfAppropriate()
            success(true)
        })
        
        cancelAction.image = UIImage(systemName: "trash")
        //completeAction.
        cancelAction.backgroundColor = UIColor(red: 122/255, green: 00/255, blue: 38/255, alpha: 1.0)
        
        return UISwipeActionsConfiguration(actions: [cancelAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
  
//COMPLETE
        let completeAction = UIContextualAction(style: .destructive, title:  "Complete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            // Fetch Day
            guard let _plannedDay = self.plannedDays?[indexPath.section] else { fatalError("Unexpected Index Path")}
            
            if (_plannedDay.meal != nil) {
                guard let _meal = _plannedDay.meal else { fatalError("Unexpected Index Path")}
                _meal.estimatedNextDate = Calendar.current.date(byAdding: .day, value: Int(_meal.frequency), to: _meal.nextDate!)
                _meal.nextDate = nil
                _meal.previousDate = nil
            }
            
            _plannedDay.isCompleted = true
            self.managedObjectContext!.delete(_plannedDay)
            
            //Attempt Request for Review
            AppStoreReviewManager.requestReviewIfAppropriate()
            success(true)
        })
        
        completeAction.image = UIImage(systemName: "checkmark.circle")
        //completeAction.backgroundColor = UIColor(red: 150/255, green: 217/255, blue: 217/255, alpha: 1.0)
        completeAction.backgroundColor = UIColor(named: "_Teal Label")!
//REPLACE
        let replaceAction = UIContextualAction(style: .normal, title:  "Replace", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.currentIndex = indexPath.section
            self.performSegue(withIdentifier: "ReplacePlannedMeal", sender: tableView)
            
            //Attempt Request for Review
            AppStoreReviewManager.requestReviewIfAppropriate()
            success(true)
        })
        
        replaceAction.image = UIImage(systemName: "arrow.right.arrow.left")
        replaceAction.title = "Replace" //24E7
        //replaceAction.title = "\u{2190}\u{2192}\n Replace" //24E7
        //replaceAction.title = UIImage(systemname: "game controller")
        //replaceAction.backgroundColor = UIColor(red: 137/255, green: 186/255, blue: 217/255, alpha: 1.0)
        replaceAction.backgroundColor = UIColor(named: "_Blue Label")!
//SHUFFLE
        let shuffleAction = UIContextualAction(style: .normal, title:  "Shuffle", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            // Fetch Day
            guard let _plannedDay = self.plannedDays?[indexPath.section] else { fatalError("Unexpected Index Path")}
 
            //Get next meal for current planned category
            var next = Meal(context: self.managedObjectContext!)
            next = self.getNextMealforCategory(_category: _plannedDay.category!, _date: _plannedDay.date!, _nextMeal: &next)!
            
            //If No Meal returned, just get the next meal regardless of category
            if (next.mealName == nil) {
                next = self.getNextMeal(_date: _plannedDay.date!, _nextMeal: &next)
            }
            
            //If No Meal still not found, keep the current planned meal in place
            if (next.mealName == nil) {
                
            } else {
                //Fetch Current Meal
                if (_plannedDay.meal != nil) {
                    guard let _meal = _plannedDay.meal else { fatalError("Unexpected Index Path")}
                    
                    if (_meal.mealName != next.mealName) {
                        //delete previous meal
                        _meal.estimatedNextDate = _meal.previousDate
                        _meal.nextDate = nil
                        _meal.previousDate = nil
                        _meal.removeFromPlannedDays(_plannedDay)
                    }
                }
                
                //add next meal
                next.previousDate = next.estimatedNextDate
                next.estimatedNextDate = nil
                next.nextDate = _plannedDay.date
                next.addToPlannedDays(_plannedDay)
            }
            
            //Attempt Request for Review
            AppStoreReviewManager.requestReviewIfAppropriate()
            success(true)
        })
        
        shuffleAction.image = UIImage(systemName: "shuffle")
        shuffleAction.title = "\u{2682}\u{2683}\nShuffle"
        //shuffleAction.backgroundColor = UIColor(red: 137/255, green: 186/255, blue: 217/255, alpha: 1.0)
        shuffleAction.backgroundColor = UIColor(named: "_Blue Label")!
        return UISwipeActionsConfiguration(actions: [completeAction,replaceAction,shuffleAction])
    }
    
    
    func getNextMealforCategory(_category: String, _date: Date, _nextMeal: inout Meal) -> Meal? {
        let fetchRequest: NSFetchRequest<Meal> = Meal.fetchRequest()
        
        //Fetch Meals using Category
        fetchRequest.predicate = NSPredicate(format: "(ANY tags.name == %@) AND estimatedNextDate != nil", _category)
        
        //Sort by estimated next date
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Meal.estimatedNextDate), ascending:true)]
        
        //Perform Fetch Request
        self.managedObjectContext!.performAndWait {
            do {
                //Execute Fetch Request
                let meals = try fetchRequest.execute()
                //Search for Meal
                if (meals.count > 0) {
                    _nextMeal = meals[0]
                }
            } catch {
                let fetchError = error as NSError
                print("Unable to Execute Fetch Request of Get Next Meal for Category")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
        }
        
        return _nextMeal
    }
    
    func getNextMeal(_date: Date, _nextMeal: inout Meal) -> Meal {
        let fetchRequest: NSFetchRequest<Meal> = Meal.fetchRequest()
        
        //Fetch Meals using Category
        fetchRequest.predicate = NSPredicate(format: "estimatedNextDate != nil")
        
        //Sort by estimated next date
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Meal.estimatedNextDate), ascending:true)]
        
        //Perform Fetch Request
        self.managedObjectContext!.performAndWait {
            do {
                //Execute Fetch Request
                let meals = try fetchRequest.execute()
                //Search for Meal
                if (meals.count > 0) {
                    _nextMeal = meals[0]
                }
            } catch {
                let fetchError = error as NSError
                print("Unable to Execute Fetch Request of Get Next Meal")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
        }
        
        return _nextMeal
    }
}
