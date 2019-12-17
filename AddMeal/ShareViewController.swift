//
//  ShareViewController.swift
//  AddMeal
//
//  Created by Josh Quirey on 9/4/19.
//  Copyright © 2019 jquirey. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import CoreData

class ShareViewController: SLComposeServiceViewController {

    private var titleString: String?
    private var urlString: String?
//    private var selectedImage: UIImage?
    
    var selectedMeal: Meal!
    let manager = CoreDataManager.init()
    var managedObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBar = self.navigationController?.navigationBar
        navBar!.backgroundColor = UIColor(named: "_Purple Label")
        navBar?.tintColor = .white
        navBar?.topItem?.rightBarButtonItem!.title = "Save"
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        imageView.contentMode = .scaleAspectFit

        let image = UIImage(named: "sporkfed_whitelogo")
          imageView.image = image
        navBar?.setBackgroundImage(image, for: .default)
       
        // self.navigationController?.navigationItem.titleView = imageView
        
        let extensionItem = extensionContext?.inputItems[0] as! NSExtensionItem
        let contentTypeURL = kUTTypeURL as String
        
        for attachment in extensionItem.attachments! {
          if attachment.isURL {
            attachment.loadItem(forTypeIdentifier: contentTypeURL, options: nil, completionHandler: { (results, error) in
              let url = results as! URL?
              self.urlString = url!.absoluteString
            })
          }
        }
        
        //image
//        let content = extensionContext!.inputItems[0] as! NSExtensionItem
//        let contentType = kUTTypeImage as String
//
//        for attachment in content.attachments! {
//            if attachment.hasItemConformingToTypeIdentifier(contentType) {
//
//                attachment.loadItem(forTypeIdentifier: contentType, options: nil) { data, error in
//                    if error == nil {
//                        let url = data as! NSURL
//                        if let imageData = NSData(contentsOf: url as URL) {
//                            self.selectedImage = UIImage(data: imageData as Data)
//                        }
//                    }
//                }
//            }
//        }
        
        self.managedObjectContext = CoreDataManager.context // manager.managedObjectContext
        self.selectedMeal = Meal(context: self.managedObjectContext!)
    }
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        if urlString != nil || titleString != nil {
          if !contentText.isEmpty {
            return true
          }
        }
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        
        self.titleString = self.contentText.trimmingCharacters(in: .whitespaces)
        
        if (self.titleString != nil) {
//            print(self.titleString!)
            selectedMeal.mealName = self.titleString
        }
        
        if (self.urlString != nil) {
//            print(self.urlString!)
            selectedMeal.url = self.urlString
        }
        
        if (self.managedObjectContext!.hasChanges) {
            do {
                try self.managedObjectContext!.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        } else {
            print("false")
        }
        
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}

extension NSItemProvider {
    var isURL: Bool {
        return hasItemConformingToTypeIdentifier(kUTTypeURL as String)
    }
    
    var isText: Bool {
        return hasItemConformingToTypeIdentifier(kUTTypeText as String)
    }
}
