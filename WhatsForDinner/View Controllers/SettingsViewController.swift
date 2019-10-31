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

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    /////////////////////////////
    //Outlets
    /////////////////////////////
    @IBOutlet weak var tableView: UITableView!
    
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
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    /////////////////////////////
    //Table Functions
    /////////////////////////////
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
            case 0:
                return 1
            case 1:
                return 2
            case 2:
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
            return "Help"
        case 1:
            return "Social"
        case 2:
            return "Feedback"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        switch(indexPath.section) {
        case 0:
            cell.textLabel!.text = "🌐 Visit Our Website"
            break
        case 1:
            if (indexPath.row == 0) {
                cell.textLabel!.text = "🐦 Tweet @SporkFedApp"
            } else {
                cell.textLabel!.text = "📷 Follow on Instagram"
            }
        case 2:
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
            showSafariVC(for: "https://sporkfed.app")
            break
        case 1:
            if (indexPath.row == 0) {
                showSafariVC(for: "https://twitter.com/sporkfedapp")
            } else {
               showSafariVC(for: "https://instagram.com/getsporkfed")
            }
            break
        case 2:
            if (indexPath.row == 0) {
                sendFeedbackEmail()
            } else {
                SKStoreReviewController.requestReview()
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
}
