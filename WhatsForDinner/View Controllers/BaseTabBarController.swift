//
//  TabBarController.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 5/28/19.
//  Copyright © 2019 jquirey. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {

    public var coreDataManager = CoreDataManager(modelName: "MealModel")
    public var categoryData = [String](arrayLiteral: "Chef's Choice 🎲", "Asian Cuisine 🥡", "Breakfast for Dinner 🥓", "Barbecue 🐷", "Casserole 🥘", "Comfort Food 🛌", "Chicken 🐓", "Mexican  🌮", "Pasta 🍝", "Pizza 🍕", "Pork 🐖", "On The Grill 🥩", "Other", "Salad 🥗", "Sandwich 🥪", "Seafood 🍤", "Slow Cooker ⏲", "Soups Up 🍜", "Vegetarian 🥕")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        self.view.backgroundColor =
    }
}

extension UINavigationController {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .lightContent
    }
}
