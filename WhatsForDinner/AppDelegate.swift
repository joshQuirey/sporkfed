//
//  AppDelegate.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 8/6/18.
//  Copyright © 2018 jquirey. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleMobileAds

//App ID Test ca-app-pub-3940256099942544/2934735716
//App ID ca-app-pub-2588193466211052~2675729023
//App Unit ID ca-app-pub-2588193466211052/5624012915

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    public let coreDataManager = CoreDataManager(modelName:"MealModel")
    
    enum QuickAction: String {
        case ViewMenu = "viewmenu"
        case ViewMeals = "viewmeals"
        case AddMeal = "addmeal"
        //Add ViewList
        
        init?(fullIdentifier: String) {
            guard let shortcutIdentifier = fullIdentifier.components(separatedBy: ".").last else { return nil }
            
            self.init(rawValue: shortcutIdentifier)
        }
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleQuickAction(shortcutItem: shortcutItem))
    }
    
    private func handleQuickAction(shortcutItem: UIApplicationShortcutItem) -> Bool {
        let shortcutType = shortcutItem.type
        
        guard let shortcutIdentifier = QuickAction(fullIdentifier: shortcutType) else { return false }
        guard let tabBarController = window?.rootViewController as? UITabBarController else { return false }
        
        switch shortcutIdentifier {
        case .ViewMenu:
             tabBarController.selectedIndex = 0
        case .ViewMeals:
            tabBarController.selectedIndex = 1
        case .AddMeal:
            if let navController = tabBarController.viewControllers?[1] {
                let mealsViewController = navController.children[0]
                mealsViewController.performSegue(withIdentifier: "AddMeal", sender: mealsViewController)
            } else {
                return false
            }
        }
        return true
    }
    
    private func viewMeal(_meal: String) {
        let tabBarController = window?.rootViewController as? UITabBarController

        if let navController = tabBarController!.viewControllers?[1] {
            let mealsViewController = navController.children[0] as! MealsViewController
            mealsViewController.managedObjectContext = self.coreDataManager.managedObjectContext
            mealsViewController.viewMealURL(_mealName: _meal)
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        createQuickActions()
        
        
        FirebaseApp.configure()
        //let authUI = FUIAuth.defaultAuthUI()
        //authUI.delegate = self
        //let authViewController = authUI.authViewController()
        
        
        //let db = Firestore.firestore()

        //AdMob
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        
        //GADMobileAds.configure(withApplicationID: "ca-app-pub-2588193466211052~2675729023") // "test ca-app-pub-3940256099942544/2934735716") //ca-app-pub-2588193466211052~2675729023")
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var message = url.host?.removingPercentEncoding

        if (message != "viewmenu" && message != "addmeal") {
            message = message?.replacingOccurrences(of: "_", with: " ")
            viewMeal(_meal: message!)
        } else if let bundleIdentifier = Bundle.main.bundleIdentifier {
            let shortcut1 = UIApplicationShortcutItem(type: "\(bundleIdentifier).\(message!)", localizedTitle: "", localizedSubtitle: nil, icon: nil, userInfo: nil)

            if handleQuickAction(shortcutItem: shortcut1) {
                return true
            }
        }
        
        return true
    }
    
    func createQuickActions() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
           
            let shortcut1 = UIApplicationShortcutItem(type: "\(bundleIdentifier).viewmenu", localizedTitle: "View Menu", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "menu"), userInfo: nil)
            
            let shortcut2 = UIApplicationShortcutItem(type: "\(bundleIdentifier).viewmeals", localizedTitle: "View Meals", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "meals"), userInfo: nil)
           
            let shortcut3 = UIApplicationShortcutItem(type: "\(bundleIdentifier).addmeal", localizedTitle: "Add Meal", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .add), userInfo: nil)
            
            UIApplication.shared.shortcutItems = [shortcut1, shortcut2, shortcut3]
        }
    }
}
