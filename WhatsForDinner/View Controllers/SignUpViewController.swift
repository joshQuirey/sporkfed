//
//  LoginViewController.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 12/11/19.
//  Copyright © 2019 jquirey. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import Purchases
import GoogleMobileAds

class SignUpViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signUpLogin: UIButton!
    private var offeringId : String?
    private var offering: Purchases.Offering?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      //  setUpElements()
        offeringId = nil
        loadOfferings()
        
    }
    
    //func setUpElements() {
        //error.alpha = 0
    //}
    
    private func loadOfferings() {
                
        Purchases.shared.offerings { (offerings, error) in
            
            if error != nil {
                self.showAlert(title: "Error", message: "Unable to fetch offerings.") { (action) in
                    self.close()
                }
            }
            print(offerings?.current)
            
            //if let offeringId = self.offeringId {
               // self.offering = offerings?.offering(identifier: offeringId)
            //} else {
                self.offering = offerings?.current
            //}
            
            if self.offering == nil {
                self.showAlert(title: "Error", message: "No offerings found.") { (action) in
                    self.close()
                }
            }
            
//            self.offeringLoadingIndicator.stopAnimating()
//            self.offeringCollectionView.reloadData()
//            self.buyButton.isEnabled = true
        }
    }
    
    private func showAlert(title: String?, message: String?, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    func validateFields() -> String? {
        
        //check that all fields filled in
        if email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || password.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please Fill in All Fields"
        }
        
        //check that email is valid
        
        
        //check that password meets requirements
        //Must have 8 characters, special character, and number
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        if !passwordTest.evaluate(with: password.text) {
            return "Password is invalid"
        }
        
        return nil
    }
    
    func showError(_ message:String) {
        //error.text = message
        //error.alpha = 1
    }
    
    @IBAction func signUpPro(_ sender: Any) {
        guard let package = offering?.availablePackages[0] else {
            print("No available package")
            return
        }
        
        Purchases.shared.purchasePackage(package) { (transaction, purchaserInfo, error, userCancelled) in
            print("1")
            print(transaction)
            print("2")
            print(purchaserInfo)
            print("3")
            print(error)
            print("4")
            print(userCancelled)
            
            
            
            
            if purchaserInfo?.entitlements.active.first != nil {
                AppDelegate.hideAds = true
            }
        }
        
//        Purchases.shared.offerings { (offerings, error)  in
//
//            if (offerings != nil) {
//                //Make Purchase
//                print(offerings)
//                print(AppDelegate.hideAds)
//                AppDelegate.hideAds = true
//                //Create User
//                self.signUp()
//            }
//        }
        
        
        
    }
    
    @IBAction func signUpFree(_ sender: Any) {
        //Create User
        signUp()
    }
    
    func signUp() {
        
        //Validate fields
        let _error = validateFields()
        if _error != nil {
            showError(_error!)
        } else {
            //clean up data
            //let _firstName = firstName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            //let _lastName = lastName.text!.trimmingCharacters(in: .whitespacesAndNewlines)

            let _email = email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let _password = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //create the user
            Auth.auth().createUser(withEmail: _email, password: _password) { (result, err) in
                
                //check for errors
                if let err = err {
                    //there was an error
                    self.showError("Error Creating User!")
                } else {
                    //user created successfully
                    //store first and last name
//                    let db = Firestore.firestore()
//                    db.collection("users").addDocument(data: ["firstName":_firstName,"lastName":_lastName,"uid":result!.user.uid]) { (error) in
//
//                        if error != nil {
//                            self.showError(error!.localizedDescription)
//                        }
//                    }
//
                    //Transition back to Settings view successfully
                    let homeViewController = self.storyboard?.instantiateViewController(identifier: "HomeViewController") as? BaseTabBarController
                    
                    self.view.window?.rootViewController = homeViewController
                    self.view.window?.makeKeyAndVisible()
//                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func cancelTapped(_ sender: Any) {
//         let menuViewController = self.storyboard?.instantiateViewController(identifier: "MenuViewController") as? MenuViewController
//        self.present(menuViewController!, animated: true, completion: nil)
    }
    

}
