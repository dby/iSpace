//
//  PathUtils.swift
//  iSecrets
//
//  Created by dby on 2023/6/12.
//

import Foundation

class PathUtils: NSObject {
    /// 路径前缀
    /// - Returns: path to Documents/com.secret.Secrets/XXX
    static func rootDir() -> String? {
        guard core.account.0 != .notLogin else { return nil }
        guard core.account.0 != .notCreate else { return nil }
        guard let name = core.account.1?.name else { return nil }
        
        return "\(basePath())/\(name)"
    }
}

/// 基础路径
/// - Returns: path to Documents/com.secret.Secrets/
@inlinable func basePath() -> String {
    let dir = dirPath(of: .applicationSupportDirectory).appending("/com.secret.Secrets")
    print("dir:\(dir)")
    generateDirectory(dir)
    return dir
}

@inlinable func dbPath() -> String {
    return "\(basePath())/iSecrets.db"
}

@inlinable func kingfisherImageCachePath() -> String {
    return "\(basePath())/ImageCache"
}

@inlinable func dirPath(of path: FileManager.SearchPathDirectory) -> String {
    let dirs = NSSearchPathForDirectoriesInDomains(path,
                                                   .userDomainMask,
                                                   true)
    precondition(!dirs.isEmpty)
    return dirs[0]
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
