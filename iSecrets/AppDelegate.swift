//
//  AppDelegate.swift
//  iSecrets
//
//  Created by dby on 2023/6/14.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        core.startUp()
        
        return true
    }
}
