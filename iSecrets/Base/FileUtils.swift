//
//  FileUtils.swift
//  iSecrets
//
//  Created by dby on 2023/6/29.
//

import Foundation

class FileUtils: NSObject {
    
    static func fileExists(_ filePath: String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: filePath)
    }
    
    static func createFolder(_ folderPath: String) -> Bool {
        let manager = FileManager.default
        if (manager.fileExists(atPath:folderPath)) {
            return true
        }
        
        var ret: Bool = true
        do {
            try manager.createDirectory(atPath:folderPath, withIntermediateDirectories:true, attributes:nil)
        } catch {
            ret = false
        }
        
        return ret
    }
}
