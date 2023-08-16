//
//  iSecretsApp.swift
//  iSecrets
//
//  Created by dby on 2023/6/11.
//

import SwiftUI

@main
struct iSecretsApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var coordinator = HomeCoordinator()
    
    var body: some Scene {
        WindowGroup {
            HomeContentView(coordinator: coordinator)
        }
        .onChange(of: scenePhase) { newScenePhase in
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let windows = windowScene.windows
                windows.forEach { window in
                    // 在应用程序退出后台时添加遮罩效果
                    if newScenePhase == .background || newScenePhase == .inactive {
                        window.initSecurityBlurEffectViewIfNeed()
                        window.securityBlurEffectView?.updateSecurityBlurEffectImage()
                        window.securityBlurEffectView?.alpha = 1
                    } else if newScenePhase == .active {
                        window.securityBlurEffectView?.alpha = 0
                    }
                }
            }
        }
    }
}
