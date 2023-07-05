//
//  AppDelegate.swift
//  iSecrets
//
//  Created by dby on 2023/6/14.
//

import UIKit
import Kingfisher

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        core.startUp()
        setUpKingfisher()
        
        return true
    }
    
    private func setUpKingfisher() {
        let imageCacheDirectory = libraryPath()
        let url = NSURL(fileURLWithPath: imageCacheDirectory) as URL
        if let imageCache = try? ImageCache(name: "iSpace", cacheDirectoryURL: url) {
            imageCache.diskStorage.config.sizeLimit = 1_073_741_824  // 1GB
            imageCache.diskStorage.config.expiration = .days(30)  // 缓存30天
            KingfisherManager.shared.defaultOptions = [ .targetCache(imageCache) ]
            imageCache.cleanExpiredDiskCache()
        }
    }
}
