//
//  iSecretsApp.swift
//  iSecrets
//
//  Created by dby on 2023/6/11.
//

import SwiftUI

@main
struct iSecretsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var coordinator = HomeCoordinator()
    
    var body: some Scene {
        WindowGroup {
            HomeContentView(coordinator: coordinator)
        }
    }
}
