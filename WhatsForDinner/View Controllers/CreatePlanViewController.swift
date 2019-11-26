//
//  CreatePlanViewController.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 4/19/19.
//  Copyright © 2019 jquirey. All rights reserved.
//

import UIKit
import CoreData

class CreatePlanViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    /////////////////////////////
    //Outlets
    /////////////////////////////
    @IBOutlet weak var bottomStackViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var childView1: UIView!
    @IBOutlet weak var childView2: UIView!
    @IBOutlet weak var childView3: UIView!
    @IBOutlet weak var childView4: UIView!
    @IBOutlet weak var childView5: UIView!
    @IBOutlet weak var childView6: UIView!
    @IBOutlet weak var childView7: UIView!
    
    @IBOutlet weak var startingDate: UITextField!
    let startingDatePicker = UIDatePicker()
    
    var dateDay1: Date?
    @IBOutlet weak var labelDay1: UILabel!
    @IBOutlet weak var category1: UITextField!
    var dateDay2: Date?
    @IBOutlet weak var labelDay2: UILabel!
    @IBOutlet weak var category2: UITextField!
    var dateDay3: Date?
    @IBOutlet weak var labelDay3: UILabel!
    @IBOutlet weak var category3: UITextField!
    var dateDay4: Date?
    @IBOutlet weak var labelDay4: UILabel!
    @IBOutlet weak var category4: UITextField!
    var dateDay5: Date?
    @IBOutlet weak var labelDay5: UILabel!
    @IBOutlet weak var category5: UITextField!
    var dateDay6: Date?
    @IBOutlet weak var labelDay6: UILabel!
    @IBOutlet weak var category6: UITextField!
    var dateDay7: Date?
    @IBOutlet weak var labelDay7: UILabel!
    @IBOutlet weak var category7: UITextField!
    
    /////////////////////////////
    //Properties
    /////////////////////////////
    var managedObjectContext: NSManagedObjectContext?
    var weekPlan = [PlannedDay?]()
    let picker1 = UIPickerView()
    let picker2 = UIPickerView()
    let picker3 = UIPickerView()
    let picker4 = UIPickerView()
    let picker5 = UIPickerView()
    let picker6 = UIPickerView()
    let picker7 = UIPickerView()
    
    var numberDaysToPlan = 7
    
    let categoryData = [String](arrayLiteral: "🎲 Chef's Choice", "👨‍🍳 Restaurant", "🍴 Leftovers", "🥡 Asian Cuisine", " 🥓 Breakfast for Dinner", "🐷 Barbecue", "🐄 Beef", "🥘 Casserole", "🛌 Comfort Food", "🐓 Chicken", "🍛 Curry", "🌾 Grains", "🌮 Hispanic", "🍜 Noodles", "🍝 Pasta", "🍕 Pizza", "🐖 Pork", "🌡 Pressure Cooker", "🥩 On The Grill", "🍯 Other", "🐇 Quick", "🥗 Salad", "🥪 Sandwich", "🍤 Seafood", "⏲ Slow Cooker", "🥣 Soups Up", "🥢 Stir-Fry", "🥕 Vegetarian")

    var helpers = CoreDataHelpers()
    
    /////////////////////////////
    //View Life Cycle
    /////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
    
        showStartingDatePicker()
        startingDate.delegate = self
        
        //determine max days that can be planned
        let numberAvailable = helpers.getNumberAvailableMeals(context: self.managedObjectContext!)

        if (numberAvailable! < numberDaysToPlan) {
            numberDaysToPlan = numberAvailable!
        }
        
        childView1.isHidden = true
        childView2.isHidden = true
        childView3.isHidden = true
        childView4.isHidden = true
        childView5.isHidden = true
        childView6.isHidden = true
        childView7.isHidden = true
        
        var counter = 1
        while (numberDaysToPlan >= counter) {
            switch (counter) {
            case 1:
                showPicker(self.category1, self.picker1)
                childView1.isHidden = false
            case 2:
                showPicker(self.category2, self.picker2)
                childView2.isHidden = false
            case 3:
                showPicker(self.category3, self.picker3)
                childView3.isHidden = false
            case 4:
                showPicker(self.category4, self.picker4)
                childView4.isHidden = false
            case 5:
                showPicker(self.category5, self.picker5)
                childView5.isHidden = false
            case 6:
                showPicker(self.category6, self.picker6)
                childView6.isHidden = false
            case 7:
                showPicker(self.category7, self.picker7)
                childView7.isHidden = false
            default:
                showPicker(self.category7, self.picker7)
                childView7.isHidden = false
            }
            
            counter = counter + 1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.layer.cornerRadius = 25
        self.navigationController?.navigationBar.clipsToBounds = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
       return UIStatusBarStyle.lightContent
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func noMealNeeded() {
        
    }
    
    @IBAction func create(_ sender: Any) {
        //Day1
        if (!childView1.isHidden) {
            var plannedMeal = Meal(context: self.managedObjectContext!)
            let day1Plan = PlannedDay(context: self.managedObjectContext!)
            day1Plan.planStartDate = dateDay1
            day1Plan.date = dateDay1
            day1Plan.planEndDate = dateDay7
            day1Plan.category = category1.text

            if (day1Plan.category != "👨‍🍳 Restaurant" && day1Plan.category != "🍴 Leftovers") {
                //Get Meal by Category
                day1Plan.meal = self.getNextMealforCategory(_plannedCategory: day1Plan.category!, _plannedDate: day1Plan.date!, _plannedMeal: &plannedMeal)
                //Get Next Meal
                if (day1Plan.meal!.mealName == nil) {
                    day1Plan.meal = self.getNextMeal(_plannedDate: day1Plan.date!, _plannedMeal: &plannedMeal)
                }
            }
        
            if (day1Plan.meal == nil) {
                print(day1Plan.category!)
            } else {
                print("Selected Meal 1: \(day1Plan.meal!.mealName!)")
            }
        }
        
        //Day2
        if (!childView2.isHidden) {
            var plannedMeal2 = Meal(context: self.managedObjectContext!)
            let day2Plan = PlannedDay(context: self.managedObjectContext!)
            day2Plan.planStartDate = dateDay1
            day2Plan.date = dateDay2
            day2Plan.planEndDate = dateDay7
            day2Plan.category = category2.text
            
            if (day2Plan.category != "👨‍🍳 Restaurant" && day2Plan.category != "🍴 Leftovers") {
                //Get Meal by Category
                day2Plan.meal = self.getNextMealforCategory(_plannedCategory: day2Plan.category!, _plannedDate: day2Plan.date!, _plannedMeal: &plannedMeal2)
                //Get Next Meal
                if (day2Plan.meal!.mealName == nil) {
                    day2Plan.meal = self.getNextMeal(_plannedDate: day2Plan.date!, _plannedMeal: &plannedMeal2)
                }
            }
            
            if (day2Plan.meal == nil) {
                print(day2Plan.category!)
            } else {
                print("Selected Meal 2: \(day2Plan.meal!.mealName!)")
            }
        }
        
        //Day3
        if (!childView3.isHidden) {
            var plannedMeal3 = Meal(context: self.managedObjectContext!)
            let day3Plan = PlannedDay(context: self.managedObjectContext!)
            day3Plan.planStartDate = dateDay1
            day3Plan.date = dateDay3
            day3Plan.planEndDate = dateDay7
            day3Plan.category = category3.text
            
            if (day3Plan.category != "👨‍🍳 Restaurant" && day3Plan.category != "🍴 Leftovers") {
                //Get Meal by Category
                day3Plan.meal = self.getNextMealforCategory(_plannedCategory: day3Plan.category!, _plannedDate: day3Plan.date!, _plannedMeal: &plannedMeal3)
                //Get Next Meal
                if (day3Plan.meal!.mealName == nil) {
                    day3Plan.meal = self.getNextMeal(_plannedDate: day3Plan.date!, _plannedMeal: &plannedMeal3)
                }
            }
            
            if (day3Plan.meal == nil) {
                print(day3Plan.category!)
            } else {
                print("Selected Meal 3: \(day3Plan.meal!.mealName!)")
            }
        }
        
        //Day4
        if (!childView4.isHidden) {
            var plannedMeal4 = Meal(context: self.managedObjectContext!)
            let day4Plan = PlannedDay(context: self.managedObjectContext!)
            day4Plan.planStartDate = dateDay1
            day4Plan.date = dateDay4
            day4Plan.planEndDate = dateDay7
            day4Plan.category = category4.text
            
            if (day4Plan.category != "👨‍🍳 Restaurant" && day4Plan.category != "🍴 Leftovers") {
                //Get Meal by Category
                day4Plan.meal = self.getNextMealforCategory(_plannedCategory: day4Plan.category!, _plannedDate: day4Plan.date!, _plannedMeal: &plannedMeal4)
                //Get Next Meal
                if (day4Plan.meal!.mealName == nil) {
                    day4Plan.meal = self.getNextMeal(_plannedDate: day4Plan.date!, _plannedMeal: &plannedMeal4)
                }
            }
            
            if (day4Plan.meal == nil) {
                print(day4Plan.category!)
            } else {
                print("Selected Meal 4: \(day4Plan.meal!.mealName!)")
            }
        }

        //Day5
        if (!childView5.isHidden) {
            var plannedMeal5 = Meal(context: self.managedObjectContext!)
            let day5Plan = PlannedDay(context: self.managedObjectContext!)
            day5Plan.planStartDate = dateDay1
            day5Plan.date = dateDay5
            day5Plan.planEndDate = dateDay7
            day5Plan.category = category5.text
            
            if (day5Plan.category != "👨‍🍳 Restaurant" && day5Plan.category != "🍴 Leftovers") {
                //Get Meal by Category
                day5Plan.meal = self.getNextMealforCategory(_plannedCategory: day5Plan.category!, _plannedDate: day5Plan.date!, _plannedMeal: &plannedMeal5)
                //Get Next Meal
                if (day5Plan.meal!.mealName == nil) {
                    day5Plan.meal = self.getNextMeal(_plannedDate: day5Plan.date!, _plannedMeal: &plannedMeal5)
                }
            }
            
            if (day5Plan.meal == nil) {
                print(day5Plan.category!)
            } else {
                print("Selected Meal 5: \(day5Plan.meal!.mealName!)")
            }
        }
        
        //Day6
        if (!childView6.isHidden) {
            var plannedMeal6 = Meal(context: self.managedObjectContext!)
            let day6Plan = PlannedDay(context: self.managedObjectContext!)
            day6Plan.planStartDate = dateDay1
            day6Plan.date = dateDay6
            day6Plan.planEndDate = dateDay7
            day6Plan.category = category6.text
            
            if (day6Plan.category != "👨‍🍳 Restaurant" && day6Plan.category != "🍴 Leftovers") {
                //Get Meal by Category
                day6Plan.meal = self.getNextMealforCategory(_plannedCategory: day6Plan.category!, _plannedDate: day6Plan.date!, _plannedMeal: &plannedMeal6)
                //Get Next Meal
                if (day6Plan.meal!.mealName == nil) {
                    day6Plan.meal = self.getNextMeal(_plannedDate: day6Plan.date!, _plannedMeal: &plannedMeal6)
                }
            }
            
            if (day6Plan.meal == nil) {
                print(day6Plan.category!)
            } else {
                print("Selected Meal 6: \(day6Plan.meal!.mealName!)")
            }
        }
        
        //Day7
        if (!childView7.isHidden) {
            var plannedMeal7 = Meal(context: self.managedObjectContext!)
            let day7Plan = PlannedDay(context: self.managedObjectContext!)
            day7Plan.planStartDate = dateDay1
            day7Plan.date = dateDay7
            day7Plan.planEndDate = dateDay7
            day7Plan.category = category7.text
            
            if (day7Plan.category != "👨‍🍳 Restaurant" && day7Plan.category != "🍴 Leftovers") {
                //Get Meal by Category
                day7Plan.meal = self.getNextMealforCategory(_plannedCategory: day7Plan.category!, _plannedDate: day7Plan.date!, _plannedMeal: &plannedMeal7)
                //Get Next Meal
                if (day7Plan.meal!.mealName == nil) {
                    day7Plan.meal = self.getNextMeal(_plannedDate: day7Plan.date!, _plannedMeal: &plannedMeal7)
                }
            }
            
            if (day7Plan.meal == nil) {
                print(day7Plan.category!)
            } else {
                print("Selected Meal 7: \(day7Plan.meal!.mealName!)")
            }
        }
        
        //Attempt Request for Review
        AppStoreReviewManager.requestReviewIfAppropriate()
        self.dismiss(animated: true, completion: nil)
    }
    
    func getNextMealforCategory(_plannedCategory: String, _plannedDate: Date, _plannedMeal: inout Meal) -> Meal? {
        //Execute Fetch Request
        let meals = helpers.getNextMealforCategory(context: self.managedObjectContext!, _plannedCategory: _plannedCategory)
        
        //Search for Meal
        if (meals.count > 0) {
            _plannedMeal = FindMeal(_meals: meals, _plannedDate: _plannedDate, _plannedMeal: &_plannedMeal)
        }
        
        return _plannedMeal
    }
    
    func getNextMeal(_plannedDate: Date, _plannedMeal: inout Meal) -> Meal {
        let meals = helpers.getNextMeals(context: self.managedObjectContext!)
        
        //Search for Meal
        if (meals.count > 0) {
            _plannedMeal = FindMeal(_meals: meals, _plannedDate: _plannedDate, _plannedMeal: &_plannedMeal)
        }

        return _plannedMeal
    }
    
    func FindMeal(_meals: [Meal], _plannedDate: Date, _plannedMeal: inout Meal) -> Meal {
        var mealExists: Bool = false
        
        //check to see if meal is in current plan
        for _meal in _meals {
            mealExists = false
            
            //check if meal is already in current plan
            for day in weekPlan {
                //if meal exists already
                if (_meal.objectID == day?.meal?.objectID) {
                    //go to next meal in meals
                    mealExists = true
                    break
                }
            }
            
            if (!mealExists) {
                _plannedMeal = _meal
                _plannedMeal.previousDate = _plannedMeal.estimatedNextDate
                _plannedMeal.estimatedNextDate = nil
                _plannedMeal.nextDate = _plannedDate
                
                break
            }
        }
        
        return _plannedMeal
    }
    
    /////////////////////////////
    //Text Field Functions
    ////////////////////////////
    func textFieldDidEndEditing(_ textField: UITextField) {
        //update each of the day labels
        updateDayDates()
    }
    
    func updateDayDates() {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        
        //Day One
        dateDay1 = startingDatePicker.date
        labelDay1.text = formatter.string(from: startingDatePicker.date)
        
        //Day Two
        dateDay2 = Calendar.current.date(byAdding: .day, value: 1, to: startingDatePicker.date)
        labelDay2.text = formatter.string(from: dateDay2!)
        
        //Day Three
        dateDay3 = Calendar.current.date(byAdding: .day, value: 2, to: startingDatePicker.date)
        labelDay3.text = formatter.string(from: dateDay3!)
        
        //Day Four
        dateDay4 = Calendar.current.date(byAdding: .day, value: 3, to: startingDatePicker.date)
        labelDay4.text = formatter.string(from: dateDay4!)
        
        //Day Five
        dateDay5 = Calendar.current.date(byAdding: .day, value: 4, to: startingDatePicker.date)
        labelDay5.text = formatter.string(from: dateDay5!)
        
        //Day Six
        dateDay6 = Calendar.current.date(byAdding: .day, value: 5, to: startingDatePicker.date)
        labelDay6.text = formatter.string(from: dateDay6!)
        
        //Day Seven
        dateDay7 = Calendar.current.date(byAdding: .day, value: 6, to: startingDatePicker.date)
        labelDay7.text = formatter.string(from: dateDay7!)
    }
    
    /////////////////////////////
    //Date Picker Functions
    /////////////////////////////
    func showStartingDatePicker() {
        //Setup
        startingDate.inputView = startingDatePicker
        startingDatePicker.datePickerMode = .date
        
        //Toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Choose", style: .plain, target: self, action: #selector(donePrepDatePicker))
        
        toolbar.setItems([spaceButton,doneButton], animated: false)
        //toolbar.tintColor = UIColor(red: 77/255, green: 72/255, blue: 147/255, alpha: 1.0)
        toolbar.tintColor = UIColor(named: "_Purple Label")!
        startingDate.inputAccessoryView = toolbar
    
        //startingDatePicker.date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        startingDate.text = formatter.string(from: startingDatePicker.date)
        updateDayDates()
    }
    
    @objc func donePrepDatePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        startingDate.text = formatter.string(from: startingDatePicker.date)
        self.view.endEditing(true)
    }
    
    /////////////////////////////
    //Picker Functions
    /////////////////////////////
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
   }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch (pickerView) {
        case picker1:
            category1.text? = categoryData[row]
            break
        case picker2:
            category2.text? = categoryData[row]
            break
        case picker3:
            category3.text? = categoryData[row]
            break
        case picker4:
            category4.text? = categoryData[row]
            break
        case picker5:
            category5.text? = categoryData[row]
            break
        case picker6:
            category6.text? = categoryData[row]
            break
        case picker7:
            category7.text? = categoryData[row]
            break
        default:
            break
        }
    }
    
    func showPicker(_ textField: UITextField, _ pickerView: UIPickerView) {
        textField.inputView = pickerView
        pickerView.delegate = self

        //Toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Choose", style: .plain, target: self, action: #selector(doneTextPicker))
        
        toolbar.setItems([spaceButton,doneButton], animated: false)
        //toolbar.tintColor = UIColor(red: 77/255, green: 72/255, blue: 147/255, alpha: 1.0)
        toolbar.tintColor = UIColor(named: "_Purple Label")!
        textField.inputAccessoryView = toolbar
        textField.text = categoryData[0]
    }
    
    @objc func cancelTextPicker() {
        //category1.text = nil
        self.view.endEditing(true)
    }
    
    @objc func doneTextPicker() {
        self.view.endEditing(true)
    }
}
