//
//  PathUtils.swift
//  iSecrets
//
//  Created by dby on 2023/6/12.
//

import Foundation

class PathUtils: NSObject {
    
    @objc static func dbPath() -> String? {
        if let prefix = rootDir() {
            return "\(prefix)/secrets.db"
        }
                
        return nil
    }
    
    /// 路径前缀
    /// - Returns: path to Documents/com.secret.Secrets/XXX
    static func rootDir() -> String? {
        
        guard core.getAccountState() != .notLogin else {
            // 账户不合法
            return nil
        }
        
        if let homeDoc = documents() {
            return "\(homeDoc)/com.secret.Secrets/\(core.curAccount!.sha256)"
        }
        
        return nil
    }
    
    /// Document目录，此处有问题～～～～～～～～～～～
    private static func documents() -> String? {
        let documentPaths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        return documentPaths.first ?? nil
    }
    
//    Library目录
//    private static func library() -> String? {
//        let documentPaths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
//        return documentPaths.first ?? nil
//    }
}
