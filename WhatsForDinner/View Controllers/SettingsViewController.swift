//
//  SettingsViewController.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 6/4/19.
//  Copyright © 2019 jquirey. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI
import SafariServices
//import Firebase
//import FirebaseAuth
import Purchases

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    /////////////////////////////
    //Outlets
    /////////////////////////////
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var successLabel: UILabel!
    //@IBOutlet weak var login: UIButton!
    //@IBOutlet weak var signUp: UIButton!
    //@IBOutlet weak var logOut: UIButton!
    private var offeringId : String?
    private var offering: Purchases.Offering?
    var noOfferings: Bool = false
    var purchased: Bool = false
    
    /////////////////////////////
    //Segues
    /////////////////////////////
//    private enum Segue {
//        static let SettingsLogin = "SettingsLogin"
//    }
    
    /////////////////////////////
    //View Life Cycle
    /////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
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
        
        offeringId =  nil
        loadOfferings()
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
       // checkIfUserLoggedIn()
        checkIfUserPurchased()
    }
    
     private func loadOfferings() {
        Purchases.shared.offerings { (offerings, error) in
            if error != nil {
                self.showAlert(title: "Error", message: "Unable to fetch offerings.") { (action) in
                    self.noOfferings = true
                }
            }
            print(offerings?.current)
            self.offering = offerings?.current
            
            if self.offering == nil {
                self.showAlert(title: "Error", message: "No offerings found.") { (action) in
                    self.noOfferings = true
                }
            }
        }
    }
    
    private func showAlert(title: String?, message: String?, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkIfUserPurchased() {
        Purchases.shared.purchaserInfo{ (purchaserInfo, error) in
            if purchaserInfo?.entitlements.active.first != nil {
                self.purchased = true
            }
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let identifier = segue.identifier else { return }
//
//        switch identifier {
//        case Segue.SettingsLogin:
//            guard let destination = segue.destination as? LoginViewController else {
//                return
//            }
//        default:
//            break
//        }
//    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    /////////////////////////////
    //Table Functions
    /////////////////////////////
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
            case 0:
                return 1
            case 1:
                return 1
            case 2:
                return 2
            case 3:
                return 2
            default:
                return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 0:
            return "Upgrades"
        case 1:
            return "Help"
        case 2:
            return "Social"
        case 3:
            return "Feedback"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        switch(indexPath.section) {
        case 0:
            if (purchased) {
                    cell.textLabel!.text = "💯 Remove Ads (Paid)"
                } else {
                    cell.textLabel!.text = "💯 Remove Ads"
                }
            break
        case 1:
            cell.textLabel!.text = "🌐 Visit Our Website"
            break
        case 2:
            if (indexPath.row == 0) {
                cell.textLabel!.text = "🐦 Tweet @SporkFedApp"
            } else {
                cell.textLabel!.text = "📷 Follow on Instagram"
            }
        case 3:
            if (indexPath.row == 0) {
                cell.textLabel!.text = "✉️ Send Email"
            } else {
                cell.textLabel!.text = "👍 Rate Us on the App Store"
            }
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.section) {
        case 0:
            //If not a subscriber, show subcriber page
            if (purchased) {
                //Upgrades purchased
            } else {
                //Purchase upgrade
                guard let package = offering?.availablePackages[0] else {
                    print("No available package")
                    return
                }
                
                Purchases.shared.purchasePackage(package) { (transaction, purchaserInfo, error, userCancelled) in
//                    print("1")
//                    print(transaction)
//                    print("2")
//                    print(purchaserInfo)
//                    print("3")
//                    print(error)
//                    print("4")
//                    print(userCancelled)
                
                    if purchaserInfo?.entitlements.active.first != nil {
                        AppDelegate.hideAds = true
                        
                        let homeViewController = self.storyboard?.instantiateViewController(identifier: "HomeViewController") as? BaseTabBarController
                        
                        self.view.window?.rootViewController = homeViewController
                        self.view.window?.makeKeyAndVisible()
                    }
                }
                      
            }
            break
        case 1:
            showSafariVC(for: "https://sporkfed.app")
            break
        case 2:
            if (indexPath.row == 0) {
                showSafariVC(for: "https://twitter.com/sporkfedapp")
            } else {
               showSafariVC(for: "https://instagram.com/sporkfedapp")
            }
            break
        case 3:
            if (indexPath.row == 0) {
                sendFeedbackEmail()
            } else {
                guard let writeReviewURL = URL(string:"https://apps.apple.com/us/app/spork-fed/id1467002477?action=write-review")
                    else { fatalError("Expected a valid URL") }
                UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
                //SKStoreReviewController.requestReview()
            }
            break
        default:
            break
        }
    }
    
    //////////////////////////////////
    //Email
    //////////////////////////////////
    func sendFeedbackEmail() {
        let mailComposeViewController = configureMail()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
    }
    
    func configureMail() -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        
        mailComposer.setToRecipients(["sporkfed.app@gmail.com"])
        mailComposer.setSubject("Spork Fed User Feedback")
        
        return mailComposer
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    ////////////////////////////////
    //Safari Links
    ////////////////////////////////
    func showSafariVC(for url: String) {
        guard let url = URL(string: url) else {
            //Show invalid URL error
            return
        }
        
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = UIColor(named: "_Purple to Teal")
        present(safariVC, animated: true)
    }
    
    
//    @IBAction func logoutTapped(_ sender: Any) {
//        self.
//    }
    
   // func logout() {
   //     do {
            //try Auth.auth().signOut()
            //checkIfUserLoggedIn()
    //        tableView.reloadData()
   //     } catch {
   //     }
  //  }
    
    
}
