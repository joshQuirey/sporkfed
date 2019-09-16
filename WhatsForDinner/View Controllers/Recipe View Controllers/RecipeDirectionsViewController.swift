//
//  RecipeDirectionsViewController.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 8/25/18.
//  Copyright © 2018 jquirey. All rights reserved.
//

import UIKit

class RecipeDirectionsViewController: UIViewController, UITextViewDelegate {
    /////////////////////////////
    //Outlets
    /////////////////////////////
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var recipeDirections: UITextView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    /////////////////////////////
    //Properties
    /////////////////////////////
    var meal: Meal?
    
    /////////////////////////////
    //View Life Cycle
    /////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotificationHandling()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        navBar.shadowImage = UIImage()
    }

    @IBAction func done(_ sender: Any) {
        meal?.directions = recipeDirections.text
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recipeDirections.text = meal?.directions
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
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
        
        var pureHeightOffset:CGFloat = -heightOffset
        
        if isShowing {
            pureHeightOffset = pureHeightOffset + bottomConstraint.constant //+ view.safeAreaInsets.bottom
        } else {
            pureHeightOffset = -10
        }
        
        bottomConstraint.constant = pureHeightOffset
        
        UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: { bool in })
    }
}
