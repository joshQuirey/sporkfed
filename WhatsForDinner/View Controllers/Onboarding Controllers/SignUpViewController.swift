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
    @IBOutlet weak var signUpLogin: UIButton!
    private var offeringId : String?
    private var offering: Purchases.Offering?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      //  setUpElements()
        offeringId = nil
        loadOfferings()
        
//        Purchases.shared.purchaserInfo{ (purchaserInfo, error) in
//        if purchaserInfo?.entitlements.active.first != nil {
//            //self.showSafariVC(for: "https://sporkfed.app")
//        }
        
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
                
            //Transition back to Settings view successfully
               let homeViewController = self.storyboard?.instantiateViewController(identifier: "HomeViewController") as? BaseTabBarController
               
               self.view.window?.rootViewController = homeViewController
               self.view.window?.makeKeyAndVisible()
                //self.present("LoginViewController", animated: true, completion: nil)
                //Transition back to Settings view successfully
                //let homeViewController = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as? BaseTabBarController
                
                //self.view.window?.rootViewController = homeViewController
                //self.view.window?.makeKeyAndVisible()
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
        //signUp()
        //Transition back to Settings view successfully
       let homeViewController = self.storyboard?.instantiateViewController(identifier: "HomeViewController") as? BaseTabBarController
       
       self.view.window?.rootViewController = homeViewController
       self.view.window?.makeKeyAndVisible()
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
