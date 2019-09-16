//
//  AppDelegate.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 8/6/18.
//  Copyright © 2018 jquirey. All rights reserved.
//

import UIKit
import CoreData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    public let coreDataManager = CoreDataManager(modelName:"MealModel")
    
    enum QuickAction: String {
        case ViewMenu = "viewmenu"
        case ViewMeals = "viewmeals"
        case AddMeal = "addmeal"
        
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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        createQuickActions()
        
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
    
    func createQuickActions() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
           
            let shortcut1 = UIApplicationShortcutItem(type: "\(bundleIdentifier).viewmenu", localizedTitle: "View Menu", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "menu"), userInfo: nil)
            
            let shortcut2 = UIApplicationShortcutItem(type: "\(bundleIdentifier).viewmeals", localizedTitle: "View Meals", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "meals"), userInfo: nil)
           
            let shortcut3 = UIApplicationShortcutItem(type: "\(bundleIdentifier).addmeal", localizedTitle: "Add Meal", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .add), userInfo: nil)
            
            UIApplication.shared.shortcutItems = [shortcut1, shortcut2, shortcut3]
        }
    }
}
