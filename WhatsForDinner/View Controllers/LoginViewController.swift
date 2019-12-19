//
//  LoginViewController.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 12/12/19.
//  Copyright © 2019 jquirey. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {


    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var Login: UIButton!
    @IBOutlet weak var error: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    
    func setUpElements() {
        error.alpha = 0
    }
    
    func validateFields() -> String? {
        
        //check that all fields filled in
        if email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || password.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please Fill in All Fields"
        }
        
        return nil
    }
    
    func showError(_ message:String) {
        error.text = message
        error.alpha = 1
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        //Validate fields
        let _error = validateFields()
        if _error != nil {
            showError(_error!)
        } else {
            //clean up data
            let _email = email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let _password = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        //signing in the user
            Auth.auth().signIn(withEmail: _email, password: _password) { (result,err) in
                
                if err != nil {
                    //couldn't sign in
                    self.showError(err!.localizedDescription)

                } else {
//                    self.dismiss(animated: true, completion: nil)
                    let homeViewController = self.storyboard?.instantiateViewController(identifier: "HomeViewController") as? BaseTabBarController
                    
                    self.view.window?.rootViewController = homeViewController
                    self.view.window?.makeKeyAndVisible()
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

}
