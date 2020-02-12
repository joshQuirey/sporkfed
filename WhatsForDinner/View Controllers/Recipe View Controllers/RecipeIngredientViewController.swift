//
//  RecipeIngredientViewController.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 8/25/18.
//  Copyright © 2018 jquirey. All rights reserved.
//

import UIKit

class RecipeIngredientViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    /////////////////////////////
    //Outlets
    /////////////////////////////
    @IBOutlet weak var ingredientTableView: UITableView!
    @IBOutlet weak var _ingredient: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    /////////////////////////////
    //Properties
    /////////////////////////////
    var meal: Meal?
    var ingredient: Ingredient?
    private var ingredients: [Ingredient]? {
        didSet {
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /////////////////////////////
    //View Life Cycle
    /////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredientTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        ingredientTableView.delegate = self
        ingredientTableView.dataSource = self
        
        setupNotificationHandling()
        ingredientTableView.keyboardDismissMode = .onDrag
        
        ingredientToolBar()
        navBar.shadowImage = UIImage()
    }
    
    func ingredientToolBar() {
        let bar = UIToolbar()
        var buttons: [UIBarButtonItem] = []
        let measurements: [String] = ["1/8","1/4","1/3","1/2","2/3","3/4"]
//        let units: [String] = ["cup","tsp"] //,"tbsp"]
        var barButtonItem: UIBarButtonItem
        
        var flx = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        flx.width = 50
        buttons.append(flx)
        
        for m in measurements {
            barButtonItem = UIBarButtonItem(title: m, style: .plain, target: self, action: #selector(keyboardBtnTapped(_ :)))

            barButtonItem.tintColor = UIColor(named: "_Purple Label")
            buttons.append(barButtonItem)
        }

        flx = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        flx.width = 50
        buttons.append(flx)
        
//        for u in units {
//            barButtonItem = UIBarButtonItem(title: u, style: .plain, target: self, action: #selector(keyboardBtnTapped(_ :)))
//            barButtonItem.width = 10
//            barButtonItem.tintColor = UIColor(named: "_Purple Label")
//            buttons.append(barButtonItem)
//        }
        
        bar.setItems(buttons, animated: true)
        bar.sizeToFit()
        _ingredient.inputAccessoryView = bar
    }
    //cup tsp, Tbsp, oz, lb
    //small, med, lg

    
    @objc func keyboardBtnTapped(_ sender: UIBarButtonItem) {
        _ingredient.text?.append(sender.title!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateView()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    
    func updateView() {
        if meal?.ingredients == nil {
            ingredientTableView.isHidden = true
        } else if meal!.ingredients!.count > 0 {
            ingredientTableView.isHidden = false
            ingredients = meal?.ingredients?.allObjects as? [Ingredient]
            ingredientTableView.reloadData()
        } else {
            ingredientTableView.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ingredientTableView.reloadData()
    }
    
    private func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillShow(_:)),
                                       name: UIResponder.keyboardWillShowNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillHide(_:)),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        updateBottomConstraint(notification, isShowing: true)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        updateBottomConstraint(notification, isShowing: false)
    }
    
    func updateBottomConstraint(_ notification: Notification, isShowing: Bool) {
        let userInfo = notification.userInfo!
        let keyboardRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let curve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey]! as AnyObject).uint32Value

        let convertedFrame = view.convert(keyboardRect, from: nil)
        let heightOffset = view.bounds.size.height - convertedFrame.origin.y
        let options = UIView.AnimationOptions(rawValue: UInt(curve!) << 16 | UIView.AnimationOptions.beginFromCurrentState.rawValue)
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue

        var pureHeightOffset:CGFloat = heightOffset

        if isShowing {
            pureHeightOffset = pureHeightOffset + bottomConstraint.constant //+ view.safeAreaInsets.bottom
        } else {
            pureHeightOffset = 0
        }

        bottomConstraint.constant = pureHeightOffset
        print(pureHeightOffset)

        UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: { bool in })
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.text != nil && textField.text != "") {
            addNewIngredient()
            ingredientTableView.isHidden = false
            ingredients = meal?.ingredients?.allObjects as? [Ingredient]
            ingredientTableView.reloadData()
            textField.text = nil
        }

        return true
    }
    
    func addNewIngredient() {
        //guard let managedObjectContext =  meal?.managedObjectContext else { return }
        
        ingredient = Ingredient(context: CoreDataManager.context) // managedObjectContext)
        ingredient!.item = _ingredient.text
        meal?.addToIngredients(ingredient!)
    }
    
    /////////////////////////////
    //Table Functions
    /////////////////////////////
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ingredients != nil {
            return ingredients!.count;
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ingredientTableView.dequeueReusableCell(withIdentifier: "ingredientCell", for: indexPath)
        
        let selectedIngredient = ingredients![indexPath.row]
        cell.textLabel?.text = selectedIngredient.item

        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let deletedIngredient = self.ingredients![indexPath.row]
            self.meal?.removeFromIngredients(deletedIngredient)
            self.ingredients?.remove(at: indexPath.row)
            self.ingredientTableView.reloadData()
            self.updateView()
            success(true)
        })
        
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = UIColor(red: 122/255, green: 00/255, blue: 38/255, alpha: 1.0)
        if #available(iOS 13.0, *) {
            deleteAction.image?.withTintColor(.white)
        } else {
            // Fallback on earlier versions
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
