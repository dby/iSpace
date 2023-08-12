//
//  AppDelegate.swift
//  iSecrets
//
//  Created by dby on 2023/6/14.
//

import UIKit
import Kingfisher
import JFHeroBrowser

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        core.startUp()
        setUpKingfisher()
        
        initNavigationColor()
        
        return true
    }
    
    private func setUpKingfisher() {
        let imageCacheDirectory = kingfisherImageCachePath()
        let url = NSURL(fileURLWithPath: imageCacheDirectory) as URL
        if let imageCache = try? ImageCache(name: "iSpace", cacheDirectoryURL: url) {
            imageCache.diskStorage.config.sizeLimit = 1_073_741_824  // 1GB
            imageCache.diskStorage.config.expiration = .days(30)  // 缓存30天
            KingfisherManager.shared.defaultOptions = [ .targetCache(imageCache) ]
            imageCache.cleanExpiredDiskCache()
        }
        
        JFHeroBrowserGlobalConfig.default.networkImageProvider = HeroLocalImageProvider.shared
    }
    
    private func initNavigationColor() {
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: iColor.primary]
        navBarAppearance.titleTextAttributes = [.foregroundColor: iColor.primary]
    }
}

class HeroLocalImageProvider: NSObject {
    @objc static let shared = HeroLocalImageProvider()
}

extension HeroLocalImageProvider: NetworkImageProvider {
    func downloadImage(with imgUrl: String, complete: Complete<UIImage>?) {
        DispatchQueue.global().async {
            if let img = UIImage(contentsOfFile: imgUrl) {
                complete?(.success(img))
            } else {
                complete?(.failed(nil))
            }
        }
    }
}
