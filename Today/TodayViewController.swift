//
//  TodayViewController.swift
//  Today
//
//  Created by Josh Quirey on 10/11/19.
//  Copyright © 2019 jquirey. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData

class TodayViewController: UIViewController, NCWidgetProviding {
        
    var today: [PlannedDay] = []
    let manager = CoreDataManager.init(modelName: "MealModel")
    var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var buttonToolbar: UIToolbar!
    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet weak var mealName: UILabel!

    @IBOutlet weak var addMealButton: UIButton!
    @IBAction func AddMeal(_ sender: Any) {
    
    }
    
    @IBOutlet weak var viewMenuButton: UIButton!
    @IBAction func ViewMenu(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.managedObjectContext = manager.managedObjectContext
        //self.today =
        
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        print("before")
                fetchPlans()
        
        viewMenuButton.layer.cornerRadius = 8
        viewMenuButton.clipsToBounds = true
        
        addMealButton.layer.cornerRadius = 8
        addMealButton.clipsToBounds = true
                print("after")
        completionHandler(NCUpdateResult.newData)
    }
    
    private func fetchPlans() {
        //dateFrom and dateTo
        //var date = Date()
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        let dateFrom = calendar.startOfDay(for: Date())
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
        print(dateFrom)
        print(dateTo)
        let fromPredicate = NSPredicate(format: "date >= %@", dateFrom as NSDate)
        let toPredicate = NSPredicate(format: "date < %@", dateTo! as NSDate)
        let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate,toPredicate])
        
        
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<PlannedDay> = PlannedDay.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.predicate = datePredicate //NSPredicate(format: "isCompleted == nil")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(PlannedDay.date), ascending: true)]
        
        // Perform Fetch Request
        self.managedObjectContext!.performAndWait {
            do {
                // Execute Fetch Request
                today = try fetchRequest.execute()
                print(today)

                //Reload Table View
                if (today.count > 0) {
                    mealName.text = today[0].meal?.mealName
                    if today[0].meal!.mealImage != nil {
                        mealImage.image = UIImage(data: today[0].meal!.mealImage!)
                        mealImage.layer.cornerRadius = 8
                        mealImage.clipsToBounds = true
                        mealImage.isHidden = false
                    } else {
                       mealImage.isHidden = true
                    }
                    
//                imageButton.setBackgroundImage(UIImage(data: meal!.mealImage!), for: .normal)
                }
            } catch {
                let fetchError = error as NSError
                print("Unable to Execute Fetch Request")
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
        }
    }
    
}
