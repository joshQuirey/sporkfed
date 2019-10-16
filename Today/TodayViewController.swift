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
    
    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet weak var mealName: UILabel!
    
    @IBAction func AddMeal(_ sender: Any) {
    }
    
    
    @IBAction func ViewMenu(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.managedObjectContext = manager.managedObjectContext
        //self.today =
        print("before")
        fetchPlans()
        print("after")
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
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
                    mealImage.image = UIImage(data: today[0].meal!.mealImage!)
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
