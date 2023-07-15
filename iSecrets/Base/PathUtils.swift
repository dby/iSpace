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
        
        guard core.account.0 != .notLogin else {
            // 账户不合法
            return nil
        }
        
        if let homeDoc = documents() {
            return "\(homeDoc)/com.secret.Secrets/\(core.account.1.sha256)"
        }
        
        return nil
    }
    
    /// Document目录，此处有问题～～～～～～～～～～～
    private static func documents() -> String? {
        let documentPaths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        return documentPaths.first ?? nil
    }
}

#if DEBUG
public let DIR_NAME = "iSpace_debug"
#else
public let DIR_NAME = "iSpace"
#endif

@inlinable func dirPath(of path: FileManager.SearchPathDirectory) -> String {
    let dirs = NSSearchPathForDirectoriesInDomains(path,
                                                   .userDomainMask,
                                                   true)
    precondition(!dirs.isEmpty)
    return dirs[0]
}

@inlinable func libraryPath() -> String {
    let dir = dirPath(of: .applicationSupportDirectory).appending("/\(DIR_NAME)")
    generateDirectory(dir)
    return dir
}

@inlinable func generateDirectory(_ path: String) {
    let fm = FileManager.default
    var isDir: ObjCBool = false
    if !fm.fileExists(atPath: path, isDirectory: &isDir) || !isDir.boolValue {
        do {
            try fm.createDirectory(atPath: path,
                                   withIntermediateDirectories: true,
                                   attributes: nil)
        } catch {}
    }
}
