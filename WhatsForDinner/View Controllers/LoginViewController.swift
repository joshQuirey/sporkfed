//
//  LoginViewController.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 12/11/19.
//  Copyright © 2019 jquirey. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signUpLogin: UIButton!
    
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
        error.text = message
        error.alpha = 1
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        
        //Validate fields
        let _error = validateFields()
        if _error != nil {
            showError(_error!)
        }
        
        //create the user
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            
            //check for errors
            if let err = err {
                //there was an error
                showError("Error Creating User!")
            } else {
                //user created successfully
                //store first and last name
                
            }
            
        }
        
        //transition back to settings
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
