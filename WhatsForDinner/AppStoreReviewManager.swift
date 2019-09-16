//
//  AppStoreReviewManager.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 7/22/19.
//  Copyright © 2019 jquirey. All rights reserved.
//

import StoreKit

enum AppStoreReviewManager {
    static let minimumReviewWorthyActionCount = 5
    
    static func requestReviewIfAppropriate() {
        //check to see if they have been asked to review this app in it's current version
        
        let defaults = UserDefaults.standard
        let bundle = Bundle.main
        
        var actionCount = defaults.integer(forKey: .reviewWorthyActionCount)
        
        actionCount += 1
        
        defaults.set(actionCount, forKey: .reviewWorthyActionCount)
    
        guard actionCount >= minimumReviewWorthyActionCount else {
            return
        }
        
        let bundleVersionKey = "CFBundleShortVersionString" // kCFBundleVersionKey as String
        let currentVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String
        let lastVersion = defaults.string(forKey: .lastReviewRequestAppVersion)
        
        guard lastVersion == nil || lastVersion != currentVersion else {
            return
        }
        
        let twoSecondsFromNow = DispatchTime.now() + 2.0
        DispatchQueue.main.asyncAfter(deadline: twoSecondsFromNow) {
            SKStoreReviewController.requestReview()
            defaults.set(0, forKey: .reviewWorthyActionCount)
            defaults.set(currentVersion, forKey: .lastReviewRequestAppVersion)
        }
    }
}
