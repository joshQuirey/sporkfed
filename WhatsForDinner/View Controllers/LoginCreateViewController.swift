//
//  LoginCreateViewController.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 1/23/20.
//  Copyright © 2020 jquirey. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class LoginCreateViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var error: UILabel!
    
    @IBAction func signUp(_ sender: Any) {
        error.text = nil
        signUp()
    }
    
    private enum Segue {
        static let SignUp = "SignUp"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    func setUpElements() {
        error.alpha = 0
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let identifier = segue.identifier else {
//            return }
//
//        switch identifier {
//        case Segue.SignUp:
//            if error.text == nil {
//
//                guard let destination = segue.destination as? SignUpViewController else {
//                    return
//                }
//            } else {
//                break
//            }
//        default:
//            break
//        }
//    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //Validate fields
        let _error = validateFields()
        if _error != nil {
            showError(_error!)
            return false
        } else {
            return true
        }
    }
    
    
    func showError(_ message:String) {
        error.text = message
        error.alpha = 1
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
    
    func signUp() {
            
//            //Validate fields
//            let _error = validateFields()
            if error.text == nil {
                //showError(error!)
            //} else {
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
                       
    //                    self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
}
