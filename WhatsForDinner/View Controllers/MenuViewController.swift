//
//  MenuViewController.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 12/19/19.
//  Copyright © 2019 jquirey. All rights reserved.
//

import UIKit
import Firebase

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        print("test")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       if let user = Auth.auth().currentUser {
              let homeViewController = storyboard?.instantiateViewController(identifier: "HomeViewController") as? BaseTabBarController
                   
                   view.window?.rootViewController = homeViewController
                   view.window?.makeKeyAndVisible()
              
        
            //self.performSegue(withIdentifier: "skipMenu", sender: self)
       }
        
        //func transitionToHome() {
            
//
        //}
        
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
