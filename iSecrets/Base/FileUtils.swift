//
//  FileUtils.swift
//  iSecrets
//
//  Created by dby on 2023/6/29.
//

import Foundation

enum FileExtension: String {
    /// 照片
    case pic = "pic"
    /// 视频
    case video = "video"
    /// 文件
    case file = "file"
    /// 图片缩略图
    case picThumb = "pic_thumb"
    /// 视频缩略图
    case videoThumb = "video_thumb"
}

class FileUtils: NSObject {
    static func contentsOfDirectory(atPath: String) -> [String] {
        let contentsOfPath = try? FileManager.default.contentsOfDirectory(atPath: atPath)
        return contentsOfPath ?? []
    }
    
    static func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?, options mask: FileManager.DirectoryEnumerationOptions = []) throws -> [URL] {
        let contentsOfURL = try? FileManager.default.contentsOfDirectory(at: url,
                                includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        
        return contentsOfURL ?? []
    }
        
    static func createFolder(_ folderPath: String) -> Bool {
        let manager = FileManager.default
        if (manager.fileExists(atPath:folderPath)) {
            return true
        }
        
        var ret: Bool = true
        do {
            //withIntermediateDirectories为ture表示路径中间如果有不存在的文件夹都会创建
            try manager.createDirectory(atPath:folderPath, withIntermediateDirectories:true, attributes:nil)
        } catch {
            ret = false
        }
        
        return ret
    }
    
    static func EnsureCreateParentDir(_ filePath: String) {
        let fileUrl = URL(filePath: filePath)
        _ = createFolder(fileUrl.deletingLastPathComponent().absoluteString)
    }
    
    /// 赋值文件
    /// - Parameters:
    ///   - atPath: 绝对路径
    ///   - toPath: 绝对路径
    static func copyItem(atPath: String, toPath: String) {
        try? FileManager.default.copyItem(atPath: atPath, toPath: toPath)
    }
    
    /// 移动文件
    /// - Parameters:
    ///   - atPath: 绝对路径
    ///   - toPath: 绝对路径
    static func moveItem(atPath: String, toPath: String) {
        try? FileManager.default.moveItem(atPath: atPath, toPath: toPath)
    }
    
    /// 删除文件
    /// - Parameter atPath: 文件绝对路径
    static func removeItem(atPath: String) {
        try? FileManager.default.removeItem(atPath: atPath)
    }
    
    /// 删除该目录下所有文件
    /// - Parameter atDirPath: 目录绝对路径
    static func removeAllItems(atDirPath: String) {
        let fileManager = FileManager.default
        let fileArray = fileManager.subpaths(atPath: atDirPath)
        for fn in fileArray!{
            try? fileManager.removeItem(atPath: atDirPath + "/\(fn)")
        }
    }
    
    static func fileExists(atPath: String) -> Bool {
        return FileManager.default.fileExists(atPath: atPath)
    }
    
    static func subPathsAtPath(_ atPath: String) -> [String] {
        let fileManager = FileManager.default
        if let subpaths = fileManager.subpaths(atPath: atPath) {
            return subpaths
        }
        
        return []
    }
    
    static func writeDataToPath(_ atPath: String, data: Data) -> Bool {
        var flag: Bool = false
        do {
            let fileUrl = URL(filePath: atPath)
            _ = createFolder(fileUrl.deletingLastPathComponent().absoluteString)
            
            try data.write(to: fileUrl)
            print("Data saved to \(atPath)")
            flag = true
        } catch {
            print("Error saving data: \(error)")
        }
        
        return flag
    }
    
    static func getFilePath(_ folderName: String, iconName: String, ext: FileExtension) -> String? {
        if let rootDir = PathUtils.rootDir() {
            return "\(rootDir)/\(folderName)/\(iconName).\(ext)"
        }
        
        return nil
    }
}
