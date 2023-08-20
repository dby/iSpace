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
    case mp4 = "mp4"
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
            print("CreateDir \(error.localizedDescription)")
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
        do {
            try FileManager.default.copyItem(atPath: atPath, toPath: toPath)
        } catch {
            print(error.localizedDescription)
        }
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
        if let fileArray = FileManager.default.subpaths(atPath: atDirPath) {
            for fn in fileArray {
                try? FileManager.default.removeItem(atPath: atDirPath + "/\(fn)")
            }
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
    
    /// 获取单个文件的大小
    class func getFileSize(atPath filePath : String) -> CGFloat {
        guard fileExists(atPath: filePath) else {
            return 0
        }
        
        guard let dict = try? FileManager.default.attributesOfItem(atPath: filePath) as NSDictionary else {
            return 0
        }
        
        return CGFloat(dict.fileSize())
    }
    
    /// 遍历文件夹获取目录下的所有的文件 遍历计算大小
    class func folderSizeAtPath(_ folderPath: String) -> CGFloat {
        if folderPath.count == 0 {
            return 0
        }
        
        guard fileExists(atPath: folderPath) else {
            return 0
        }
        
        var fileSize: CGFloat = 0.0
        for path in subPathsAtPath(folderPath) {
            let fullPath = "\(folderPath)/\(path)"
            fileSize = fileSize + getFileSize(atPath: fullPath)
        }
        
        return fileSize
    }
    
    static func writeDataToPath(_ atPath: String, data: Data) -> Bool {
        var flag: Bool = false
        do {
            EnsureCreateParentDir(atPath)
            let fileUrl = URL(filePath: atPath)
            
            try data.write(to: fileUrl)
            print("Data saved to \(atPath)")
            flag = true
        } catch {
            print("Error saving data: \(error)")
        }
        
        return flag
    }
    
    static func getFolderCover(_ dirObj: SecretDirObject) -> String? {
        guard let folderName = dirObj.name else { return nil }
        
        //STEP1，优选选择自定义的Cover
        if
            let customizeCover = dirObj.customizeCover,
            let coverPath = FileUtils.getMediaPath(folderName, iconName: customizeCover, ext: .picThumb),
            FileUtils.fileExists(atPath: coverPath)
        {
            return coverPath
        }
        
        //STEP2，再次选择存储的Thumb
        if
            let thumb = dirObj.thumb,
            let thumbPath = FileUtils.getMediaPath(folderName, iconName: thumb, ext: .picThumb),
            FileUtils.fileExists(atPath: thumbPath)
        {
            return thumbPath
        }
        
        //STEP3，从数据库读取第一个
        if
            let firstObjName = core.secretDB.getOneSecretFile(dirObj.localID)?.name,
            let path = FileUtils.getMediaPath(folderName, iconName: firstObjName, ext: .picThumb)
        {
            return path
        }
        
        return nil
    }
    
    static func getDirPath(_ folderName: String) -> String? {
        if let rootDir = PathUtils.rootDir() {
            return "\(rootDir)/\(folderName.md5)"
        }
        
        return nil
    }
    
    static func getMediaPath(_ folderName: String, iconName: String, ext: FileExtension) -> String? {
        if let rootDir = PathUtils.rootDir() {
            return "\(rootDir)/\(folderName.md5)/\(iconName).\(ext)"
        }
        
        return nil
    }
}
