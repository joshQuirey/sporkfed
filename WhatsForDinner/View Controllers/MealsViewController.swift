//
//  MealsViewController.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 8/6/18.
//  Copyright © 2018 jquirey. All rights reserved.
//

//App ID Test ca-app-pub-3940256099942544/2934735716
//App ID ca-app-pub-2588193466211052~2675729023
//App Unit ID ca-app-pub-2588193466211052/5624012915

import UIKit
import CoreData
import GoogleMobileAds

class MealsViewController: UIViewController, UISearchDisplayDelegate, UISearchBarDelegate {
    ////////////////////////////
    //Outlets
    ///////////////////////////
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyTableLabel: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var bannerViewHeightConstraint: NSLayoutConstraint!
    
    
    /////////////////////////////
    //Properties
    /////////////////////////////
    //var managedObjectContext: NSManagedObjectContext?
    private var selectedObjectID = NSManagedObjectID()
    var meals: [Meal]?
    
    private var allMeals: [Meal]? {
        didSet {
            updateView()
        }
    }

    private var hasMeals: Bool {
        guard let allMeals = meals else { return false }
        return allMeals.count > 0
    }

    var meal: Meal?
    var helpers = CoreDataHelpers()
    
    /////////////////////////////
    //Segues
    /////////////////////////////
    private enum Segue {
        static let AddMeal = "AddMeal"
        static let ViewMeal = "ViewMeal"
//        static let ViewMealURL = "ViewMealURL"
    }
    

    /////////////////////////////
    //View Life Cycle
    /////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
                
        title = "Meals"
        let tabBar = tabBarController as! BaseTabBarController
        //managedObjectContext = CoreDataManager.context // tabBar.coreDataManager.managedObjectContext

        fetchMeals()
        updateView()
        setupNotificationHandling()

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
        
        if (UIAccessibility.isBoldTextEnabled) {
            self.navigationItem.rightBarButtonItem?.image = nil
            self.navigationItem.rightBarButtonItem?.title = "Add"
        }
        
        tableView.keyboardDismissMode = .onDrag
        
        //AdMob
        if (AppDelegate.hideAds == false) {
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //LIVE AD ca-app-pub-2588193466211052/5624012915
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
            bannerViewHeightConstraint.constant = 50
        } else {
            bannerViewHeightConstraint.constant = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchBar.delegate = self
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.systemBackground.cgColor // UIColor(named: "_Teal Background")!.cgColor
        searchBar.text = ""
        fetchMeals()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(managedObjectContextObjectsDidChange(_:)),
                                       name: Notification.Name.NSManagedObjectContextObjectsDidChange,
                                       object: CoreDataManager.context) // self.managedObjectContext)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(saveMeals(_:)),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)
    }

    private func updateView() {
        tableView.isHidden = !hasMeals
        emptyTableLabel.isHidden = hasMeals
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return }
        
        switch identifier {
        case Segue.AddMeal:
            guard let destination = segue.destination as? RecipeViewController else {
                return
            }
            
//            destination.managedObjectContext =  self.managedObjectContext

        case Segue.ViewMeal:
            guard let destination = segue.destination as? RecipeViewController else {
                return
            }
            
//            destination.managedObjectContext = self.managedObjectContext
            if (meal != nil) {
                destination.meal = meal
                meal = nil
            } else {
                let _indexpath = tableView.indexPathForSelectedRow
                let _meal = meals![(_indexpath?.row)!]
                destination.meal = _meal
            }
//
//        case Segue.ViewMealURL:
//            guard let destination = segue.destination as? RecipeViewController else {
//                    return
//                }
//
//                destination.managedObjectContext = self.managedObjectContext
//                destination.meal = meal
//
        default:
            break
        }
    }
    
    func viewMealURL(_mealName: String) {
        fetchMeal(name: _mealName)
        self.performSegue(withIdentifier: "ViewMeal", sender: self)
    }
    
    /////////////////////////////
    //Core Data Functions
    /////////////////////////////
    @objc private func managedObjectContextObjectsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        var mealsDidChange = false
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> {
            print("Context Inserts Exist Meals")
            for insert in inserts {
                if let meal = insert as? Meal {
                    meals?.append(meal)
                    self.allMeals = meals
                    mealsDidChange = true
                }
            }
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
            print("Context Updates Exist Meals")
            for update in updates {
                if update is Meal {
                    mealsDidChange = true
                }
            }
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> {
            print("Context Deletes Exist Meals")
            for delete in deletes {
                if let meal = delete as? Meal {
                    if let index = meals?.firstIndex(of: meal) {
                        meals?.remove(at: index)
                        self.allMeals = meals
                        mealsDidChange = true
                    }
                }
            }
        }
        
        if mealsDidChange {
            //meals!.sorted(by: { $0.mealName > $1.mealName })
            tableView.reloadData()
            updateView()
            mealsDidChange = false
        }
    }

    @objc private func saveMeals(_ notification: Notification) {
        do {
            try CoreDataManager.context.save() // self.managedObjectContext!.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }

    private func fetchMeals() {
        self.meals = helpers.fetchMeals(context: CoreDataManager.context) // self.managedObjectContext!)
        self.allMeals = self.meals
        tableView.reloadData()
    }
    
    private func fetchMealsUpNext() {
        self.meals = helpers.fetchMealsUpNext(context: CoreDataManager.context) // self.managedObjectContext!)
        self.allMeals = self.meals
        tableView.reloadData()
    }
    
    private func fetchMealsFavorites() {
        self.meals = helpers.fetchMealsFavorites(context: CoreDataManager.context) // self.managedObjectContext!)
        self.allMeals = self.meals
        tableView.reloadData()
    }
    
    private func fetchMeal(name: String) {
        meal = helpers.fetchMeal(name: name, context: CoreDataManager.context) // self.managedObjectContext!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            meals = allMeals
            tableView.reloadData()
            return
        }
        
        meals = allMeals!.filter({ Meal -> Bool in
            return (Meal.mealName?.lowercased().contains(searchText.lowercased()))!
        })
        
        tableView.reloadData()
    }
    
    @IBAction func filterButton(_ sender: Any) {
        
        let alert = UIAlertController(title: "Sort/Filter Options", message:nil, preferredStyle: .actionSheet)
        
        let abcImage = UIImage(named: "sortbyabc")
        let abcAction = UIAlertAction(title: "Alphabetical", style: .default , handler:{ (UIAlertAction)in
            DispatchQueue.main.async {
                self.fetchMeals()
            }
        })
        abcAction.setValue(abcImage, forKey: "image")
        alert.addAction(abcAction)
        
        let nextImage = UIImage(named: "sortbynext")
        let nextAction = UIAlertAction(title: "Up Next", style: .default , handler:{ (UIAlertAction)in
            DispatchQueue.main.async {
                self.fetchMealsUpNext()
            }
        })
        nextAction.setValue(nextImage, forKey: "image")
        alert.addAction(nextAction)
        
        let favImage = UIImage(named: "favorite")
        let favAction = UIAlertAction(title: "Favorites", style: .default , handler:{ (UIAlertAction)in
            DispatchQueue.main.async {
                self.fetchMealsFavorites()
            }
        })
        favAction.setValue(favImage, forKey: "image")
        alert.addAction(favAction)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler:{ (UIAlertAction)in
        }))
        
        //alert.view.tintColor = UIColor(red: 77/255, green: 72/255, blue: 147/255, alpha: 1.0)
        alert.view.tintColor = UIColor(named: "_Purple to Teal")!
        self.present(alert, animated: true, completion: nil)
    }
}

extension MealsViewController: UITableViewDataSource, UITableViewDelegate {
    /////////////////////////////
    //Table Functions
    /////////////////////////////
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath) as! MealTableViewCell
        
        configure(cell, at: indexPath)
        
        cell.layer.borderWidth = 0
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        return cell
    }
    
    private func configure(_ cell: MealTableViewCell, at indexPath: IndexPath) {
        // Fetch Meal
        guard let _meal = meals?[indexPath.row] else { fatalError("Unexpected Index Path")}
        
        // Configure Cell
        cell.mealName?.text = _meal.mealName
        
        var frequency = ""
        switch _meal.frequency {
        case 7:
            frequency = "Weekly"
        case 14:
            frequency = "Every Other Week"
        case 30:
            frequency = "Monthly"
        case 60:
            frequency = "Every Other Month"
        case 90:
            frequency = "Every Few Months"
        default:
            frequency = "No Preference"
        }
        
        cell.mealFrequency?.text = frequency
        cell.mealCategories?.text = ""
        for _tag in (_meal.tags?.allObjects)! {
            let tag = _tag as! Tag
            cell.mealCategories?.text?.append("\(tag.name!) ")
        }
        
        if (_meal.mealImage != nil) {
            let image: UIImage = UIImage(data: _meal.mealImage!)!
            cell.mealImage?.image = image
            cell.mealImage.layer.cornerRadius = 8
            cell.mealImage.clipsToBounds = true
            cell.mealImage.isHidden = false
        } else {
            cell.mealImage.isHidden = true
        }
        
        if (_meal.favorite) {
            cell.favorite.isHidden = false
            let fav = UIImage(named: "favoritefilled")?.withRenderingMode(.alwaysTemplate)
            cell.favorite.setImage(fav, for: .normal)
        } else {
            cell.favorite.isHidden = true
//            let fav = UIImage(named: "favorite")?.withRenderingMode(.alwaysTemplate)
//            cell.favorite.setImage(fav, for: .normal)
        }
        
        cell.favorite.tintColor = UIColor(named: "_Purple to Teal")!
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            DispatchQueue.main.async {
                self.showDeleteWarning(for: indexPath)
            }
            
            success(true)
        })
        
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = UIColor(red: 122/255, green: 00/255, blue: 38/255, alpha: 1.0)
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func showDeleteWarning(for indexPath: IndexPath) {
        guard let _meal = self.meals?[indexPath.row] else { fatalError("Unexpected Index Path")}
        
        let alert = UIAlertController(title: "Delete \(_meal.mealName!)?", message:nil, preferredStyle: .alert)
        
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive , handler:{ (UIAlertAction)in
            DispatchQueue.main.async {
                guard let _meal = self.meals?[indexPath.row] else { fatalError("Unexpected Index Path")}
                _meal.managedObjectContext?.delete(_meal)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default , handler:{ (UIAlertAction)in
            self.tableView.reloadData()
        }))
    
        //alert.view.tintColor = UIColor(red: 77/255, green: 72/255, blue: 147/255, alpha: 1.0)
        alert.view.tintColor = UIColor(named: "_Purple to Teal")!
        self.present(alert, animated: true, completion: {})
    }
    
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let _meal = meals?[(indexPath.row)] else { fatalError("Unexpected Index Path")}
        selectedObjectID = _meal.objectID
        
        return indexPath
    }
}

extension MealsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        updateView()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [ indexPath ], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [ indexPath ], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                configure(cell as! MealTableViewCell, at: indexPath)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [ indexPath ], with: .fade)
            }

            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        @unknown default:
            break
        }
    }
}

extension MealsViewController: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("received ad")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error)
    }
}
