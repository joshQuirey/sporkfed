//
//  RecipeViewController.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 8/7/18.
//  Copyright © 2018 jquirey. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import Photos
import SafariServices
//import Firebase

class RecipeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate {
    
//    var db: Firestore!
    
    /////////////////////////////
    //Outlets
    /////////////////////////////
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var categories: UITextView!
    @IBOutlet weak var mealDescription: UITextField!
    @IBOutlet weak var frequency: UITextField!
    @IBOutlet weak var serves: UITextField!
    @IBOutlet weak var prepTime: UITextField!
    @IBOutlet weak var cookTime: UITextField!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var mealURL: UITextView!
    
    @IBAction func favorite(_ sender: UIButton) {
        print(isFavorite)
        
        if (isFavorite) {
            let fav = UIImage(named: "favorite")?.withRenderingMode(.alwaysTemplate)
            sender.setImage(fav, for: .normal)
        } else {
            let fav = UIImage(named: "favoritefilled")?.withRenderingMode(.alwaysTemplate)
            sender.setImage(fav, for: .normal)
        }
        
        sender.tintColor = UIColor(named: "_Purple Label")!
        isFavorite = !isFavorite
    }
    
    /////////////////////////////
    //Properties
    /////////////////////////////
    let frequencyData = [String](arrayLiteral: "", "Weekly", "Every Other Week", "Monthly", "Every Other Month", "Every Few Months")
    
    enum Frequency: Int {
        case weekly = 7
        case everyOtherWeek = 14
        case monthly = 30
        case everyOtherMonth = 60
        case everyFewMonths = 90
        case nopreference = 180
    }
    
    let pickImage = UIImagePickerController()
    let pickFrequency = UIPickerView()
    let pickTime = UIDatePicker()
    let pickServing = UIPickerView()
    //var managedObjectContext: NSManagedObjectContext?
    var meal: Meal?
    var imageChanged: Bool = false
    var isFavorite: Bool = false
    
    /////////////////////////////
    //Segues
    ////////////////////////////
    private enum Segue {
        static let SelectCategories = "SelectCategories"
        static let ShowIngredients = "ShowIngredients"
        static let ShowDirections = "ShowDirections"
    }
    
    /////////////////////////////s
    //View Life Cycle
    /////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
       
        pickImage.delegate = self
        showPicker(self.frequency, self.pickFrequency)
        showPrepDatePicker()
        showCookDatePicker()
        
        self.name.attributedPlaceholder = NSAttributedString(string: "Enter Meal Name",attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        categories.delegate = self
        categories.text = "Categories"
        categories.textColor = .lightGray
        categories.textContainer.lineBreakMode = .byWordWrapping
        
        mealURL.delegate = self
        
//        let settings = FirestoreSettings()
//        Firestore.firestore().settings = settings
//
//        db = Firestore.firestore()
//
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (meal?.mealImage != nil) {
            imageButton.setTitle(nil, for: .normal)
        }
        
        if (meal == nil) {
            //if (managedObjectContext == nil) {
            //    managedObjectContext = CoreDataManager.context // (UIApplication.shared.delegate as! AppDelegate).coreDataManager.managedObjectContext
            //}
            
            meal = Meal(context: CoreDataManager.context) // managedObjectContext!)
            meal?.mealName = ""
        }

        viewMeal()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        if (meal == nil) {
            meal = Meal(context: CoreDataManager.context) // managedObjectContext!)
        }
        populateMeal(meal!)

        switch identifier {
        case Segue.SelectCategories:
            guard let destination = segue.destination as? CategoriesViewController else {
                return
            }
            
            destination.modalPresentationStyle = .fullScreen
            destination.meal = meal
            if (meal!.tags != nil) {
                destination.selectedTags = (meal?.tags)!
            }
        case Segue.ShowDirections:
            guard let destination = segue.destination as? RecipeDirectionsViewController else {
                return
            }
            
            destination.meal = meal
            
        case Segue.ShowIngredients:
            guard let destination = segue.destination as? RecipeIngredientViewController else {
                return
            }

            destination.meal = meal
            
        default:
            break
        }
    }
 
    func viewMeal() {
        name.text = meal!.mealName
        
        isFavorite = meal!.favorite
        //set image for favorite
        if (isFavorite) {
            let fav = UIImage(named: "favoritefilled")?.withRenderingMode(.alwaysTemplate)
            favButton.setImage(fav, for: .normal)
        } else {
            let fav = UIImage(named: "favorite")?.withRenderingMode(.alwaysTemplate)
            favButton.setImage(fav, for: .normal)
        }
        //favButton.tintColor = UIColor(red: 77/255, green: 72/255, blue: 147/255, alpha: 1.0)
        favButton.tintColor = UIColor(named: "_Purple Label")!
        //photo
        if (meal!.mealImage != nil && !imageChanged) {
            imageButton.setBackgroundImage(UIImage(data: meal!.mealImage!), for: .normal)
        }
        
        //categories.text = nil
        if (meal!.tags != nil) {
            if (meal!.tags!.count > 0) {
                categories.text = nil
                categories.textColor = UIColor(named: "_Default to White Label")
                for _tag in (meal!.tags?.allObjects)! {
                    let tag = _tag as! Tag
                    categories.text?.append("\(tag.name!) ")
                }
            } else {
                categories.text = "Categories"
                categories.textColor = .lightGray
            }
        }
        
        mealDescription.text = meal!.mealDesc
        
        switch meal?.frequency {
        case 7:
            frequency.text = "Weekly"
        case 14:
            frequency.text = "Every Other Week"
        case 30:
            frequency.text = "Monthly"
        case 60:
            frequency.text = "Every Other Month"
        case 90:
            frequency.text = "Every Few Months"
        default:
            frequency.text = "No Preference"
        }
        
        prepTime.text = meal!.prepTime
        cookTime.text = meal!.cookTime
        serves.text = meal!.serves
        
        if (meal?.url == nil) {
            mealURL.text = ""
        } else {
            let urlString = meal?.url
            let url = URL(string: urlString!)
            let domain = url?.host
            let myAttribute = [ NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 18.0)! ]
            let attributedString = NSMutableAttributedString(string: domain!, attributes: myAttribute)
            attributedString.addAttribute(.link, value: meal?.url! ?? "", range: NSRange(location: 0, length: domain!.count))
            mealURL.attributedText = attributedString
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let safariVC = SFSafariViewController(url: URL)
        safariVC.preferredControlTintColor = UIColor(named: "_Purple to Teal")
        present(safariVC, animated: true, completion: nil)
        return false
    }
    
    func populateMeal(_ meal: Meal) {
        meal.mealName = name.text
    
        //set favorite
        meal.favorite = isFavorite
        
        //photo
        if (imageButton.currentBackgroundImage != nil) {
            guard let imageData = imageButton.backgroundImage(for: .normal)!.jpegData(compressionQuality: 1) else {
                print("image error")
                return
            }
        
            meal.mealImage = imageData
        }
        
//        print(meal)
        //categories.text = nil
//        if (meal!.tags != nil) {
//            if (meal!.tags!.count > 0) {
//                categories.text = nil
//                categories.textColor = UIColor(named: "_Default to White Label")
//                for _tag in (meal!.tags?.allObjects)! {
//                    let tag = _tag as! Tag
//                    categories.text?.append("\(tag.name!) ")
//                }
//            } else {
//                categories.text = "Categories"
//                categories.textColor = .lightGray
//            }
//        }
        
        
        meal.mealDesc = mealDescription.text
        var _frequency = 0
        
        switch frequency.text {
        case "Weekly":
            _frequency = 7
        case "Every Other Week":
            _frequency = 14
        case "Monthly":
            _frequency = 30
        case "Every Other Month":
            _frequency = 60
        case "Every Few Months":
            _frequency = 90
        default:
            _frequency = 180
        }
        meal.frequency = Int16(_frequency)

        meal.prepTime = prepTime.text
        meal.cookTime = cookTime.text
        meal.serves = serves.text
        
        if (meal.nextDate == nil) {
            meal.estimatedNextDate =  Calendar.current.date(byAdding: .day, value: Int(meal.frequency), to: Date())
        }
    }

    /////////////////////////////
    //Actions
    /////////////////////////////
    @IBAction func save(_ sender: UIBarButtonItem) {
        if (meal == nil) {
            meal = Meal(context: CoreDataManager.context) // managedObjectContext!)
        }
        
        populateMeal(meal!)
        
        // Add a new document with a generated ID
//        var ref: DocumentReference? = nil
//        ref = db.collection("users").addDocument(data: [
//            "first": "Ada",
//            "last": "Lovelace",
//            "born": 1815
//        ]) { err in
//            if let err = err {
//                print("Error adding document: \(err)")
//            } else {
//                print("Document added with ID: \(ref!.documentID)")
//            }
//        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        if (meal != nil) {
            if (meal!.frequency == 0) { //this is a meal that has not been changed
                CoreDataManager.context.delete(meal!)
//                managedObjectContext?.delete(meal!)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /////////////////////////////
    //Image Functions
    /////////////////////////////
    @IBAction func addImage(_ sender: Any) {
        populateMeal(meal!)
        self.showActionSheet(vc: self)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated:true, completion: nil)
        imageChanged = true
        let newImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        imageButton.setTitle("", for: .normal)
        imageButton.setBackgroundImage(newImage, for: .normal)
    }
    
    func showActionSheet(vc: UIViewController) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Use Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.DisplayPicker(type: .camera)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Use Photo Library", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.DisplayPicker(type: .photoLibrary)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        //actionSheet.view.tintColor = UIColor(red: 77/255, green: 72/255, blue: 147/255, alpha: 1.0)
        actionSheet.view.tintColor = UIColor(named: "_Purple Label")!
        vc.present(actionSheet, animated: true, completion: nil)
    }
    
    func photoFromLibrary() {
        pickImage.allowsEditing = true
        pickImage.delegate = self
        self.present(pickImage, animated: true, completion: nil)
    }

    func DisplayPicker(type: UIImagePickerController.SourceType){
        pickImage.mediaTypes = UIImagePickerController.availableMediaTypes(for: type)!
        pickImage.sourceType = type
        pickImage.allowsEditing = false
        
        //DispatchQueue.main.async {
        self.present(pickImage, animated: true, completion: nil)
        //}
    }
    
    /////////////////////////////
    //Picker Functions
    /////////////////////////////
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return frequencyData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return frequencyData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            frequency.text? = frequencyData[row]
    }
    
    func showPicker(_ textField: UITextField, _ pickerView: UIPickerView) {
        textField.inputView = pickerView
        pickerView.delegate = self
        
        //Toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTextPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Choose", style: .plain, target: self, action: #selector(doneTextPicker))
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        //toolbar.tintColor = UIColor(red: 77/255, green: 72/255, blue: 147/255, alpha: 1.0)
        toolbar.tintColor = UIColor(named: "_Purple Label")!
        textField.inputAccessoryView = toolbar
    }
    
    @objc func cancelTextPicker() {
        self.view.endEditing(true)
    }
    
    @objc func doneTextPicker() {
        self.view.endEditing(true)
    }
    
    func showPrepDatePicker() {
        prepTime.inputView = pickTime
        pickTime.datePickerMode = .countDownTimer
       
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPrepPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Choose", style: .plain, target: self, action: #selector(donePrepPicker))
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        //toolbar.tintColor = UIColor(red: 77/255, green: 72/255, blue: 147/255, alpha: 1.0)
        toolbar.tintColor = UIColor(named: "_Purple Label")!
        prepTime.inputAccessoryView = toolbar
    }

    @objc func donePrepPicker() {
        prepTime.text = calculateTime()
        self.view.endEditing(true)
    }
    
    @objc func cancelPrepPicker() {
        self.view.endEditing(true)
    }
    
    func showCookDatePicker() {
        cookTime.inputView = pickTime
        pickTime.datePickerMode = .countDownTimer
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelCookPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Choose", style: .plain, target: self, action: #selector(doneCookPicker))
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        //toolbar.tintColor = UIColor(red: 77/255, green: 72/255, blue: 147/255, alpha: 1.0)
        toolbar.tintColor = UIColor(named: "_Purple Label")!
        cookTime.inputAccessoryView = toolbar
    }

    @objc func doneCookPicker() {
        cookTime.text = calculateTime()
        self.view.endEditing(true)
    }
    
    @objc func cancelCookPicker() {
        self.view.endEditing(true)
    }
    
    func calculateTime() -> String {
        //Gets total number of minutes
        let minutesTotal = self.pickTime.countDownDuration / 60
        //Get Hours
        let hours = Int(minutesTotal / 60)
        //Get Remainder of Minutes
        let minutes = Int(minutesTotal) - Int(hours * 60)
        
        if (hours > 0) {
            return "\(hours)hrs \(minutes)min"
        } else {
            return "\(minutes)min"
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
