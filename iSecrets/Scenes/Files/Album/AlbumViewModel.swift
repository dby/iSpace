//
//  AlbumViewModel.swift
//  iSecrets
//
//  Created by dby on 2023/7/9.
//

import Foundation
import PhotosUI

struct AlbumConstants {
    static let menuShare: String = "Shared".localized()
    static let menuSaveToAlbum: String = "Save to mobile phone album".localized()
    static let menuCover: String = "Set to cover".localized()
    static let menuDelete: String = "Delete".localized()
}

class AlbumViewModel: ObservableObject {
    @Published var datas: [SecretFileObject] = []
    
    private var dirObj: SecretDirObject
    
    init(dirObj: SecretDirObject) {
        self.dirObj = dirObj
        
        self.fetchFiles()
    }
}

extension AlbumViewModel {
    func deleteWithAssets(assets: [PHAsset]) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets as NSArray)
        }, completionHandler: { success, error in
            if success {
                print("照片已成功删除")
            } else if let error = error {
                print("删除照片时出错：\(error.localizedDescription)")
            }
        })
    }
    
    func addImageToDir(_ dirObj: SecretDirObject, asset: PHAsset, data: Data) -> String? {
        guard let folderName = dirObj.name else { return nil }
        
        let iconName: String = "\(data.md5)_\(Int(Date.now.timeIntervalSince1970 * 1000))"
        let fullPicPath = FileUtils.getMediaPath(folderName, iconName: iconName, ext: .pic)
        let fullPicThumbPath = FileUtils.getMediaPath(folderName, iconName: iconName, ext: .picThumb)
        
        guard let fullPicPath = fullPicPath else { return nil }
        guard let fullPicThumbPath = fullPicThumbPath else { return nil }
        
        /// Write Image Data
        _ = FileUtils.writeDataToPath(fullPicPath, data: data)
        /// Write Image Thumb Data
        getThumbnailImage(for: asset) { img in
            if let imgPngData = img?.pngData() {
                _ = FileUtils.writeDataToPath(fullPicThumbPath, data: imgPngData)
            }
        }
        /// to DB
        core.secretDB.addSecretMedia(dirLocalID: dirObj.localID,
                                     name: iconName,
                                     cipher: "",
                                     asset: asset)
        
        return iconName
    }
    
    func addVideoToDir(_ dirObj: SecretDirObject, asset: PHAsset, videoData: Data) -> String? {
        guard let folderName = dirObj.name else { return nil }
        
        let iconName: String = "\(videoData.md5)_\(Int(Date.now.timeIntervalSince1970 * 1000))"
        let fullPicPath = FileUtils.getMediaPath(folderName, iconName: iconName, ext: .mp4)
        let fullPicThumbPath = FileUtils.getMediaPath(folderName, iconName: iconName, ext: .picThumb)
        
        guard let fullPicPath = fullPicPath else { return nil }
        guard let fullPicThumbPath = fullPicThumbPath else { return nil }
        
        /// Write Video Data
        _ = FileUtils.writeDataToPath(fullPicPath, data: videoData)
        /// Write Video Thumb Data
        getThumbnailImage(for: asset) { img in
            if let imgPngData = img?.pngData() {
                _ = FileUtils.writeDataToPath(fullPicThumbPath, data: imgPngData)
            }
        }
        /// to DB
        core.secretDB.addSecretMedia(dirLocalID: dirObj.localID,
                                     name: iconName,
                                     cipher: "",
                                     asset: asset)
        
        return iconName
    }
    
    func addFileToDir(_ dirObj: SecretDirObject, fileUrl: URL) {
        if
            let dirName = dirObj.name,
            let folerName = FileUtils.getDirPath(dirName)
        {
            let fileName = fileUrl.lastPathComponent
            let dstFilePath = "\(folerName)/\(fileName)"
            let dstFilePathUrl = URL(filePath: dstFilePath)
            // Move Data To DIR
            do {
                try FileManager.default.copyItem(at: fileUrl, to: dstFilePathUrl)
                print("File copied successfully to: \(dstFilePathUrl)")
            } catch {
                print("Failed to copy file: \(error)")
            }
            
            // to DB
            core.secretDB.addSecretFile(dirLocalID: dirObj.localID,
                                        name: fileName,
                                        cipher: "")
            
            fetchFiles()
        }
    }
    
    func menuTitles() -> [(String, String)] {
        if self.dirObj.fileFormat == DirDataFormat.file.rawValue {
            return []
        }
        
        var titles: [(String, String)] = [(AlbumConstants.menuShare, "square.and.arrow.up")]
        
        titles.append((AlbumConstants.menuSaveToAlbum, "photo"))
        titles.append((AlbumConstants.menuCover, "bookmark.square"))
        
        return titles
    }
    
    func contextMenuDidClicked(_ title: String, fileObj: SecretFileObject) {
        if title == AlbumConstants.menuShare {
            
        } else if title == AlbumConstants.menuSaveToAlbum {
            guard let folderName = dirObj.name else { return }
            guard let iconName = fileObj.name else { return }
            
            var fileExt = FileExtension.pic
            if fileObj.mediaType == PHAssetMediaType.video.rawValue {
                fileExt = .mp4
            }
            
            if let path = FileUtils.getMediaPath(folderName, iconName: iconName, ext: fileExt),
               let image = UIImage(contentsOfFile: path) {
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            }
        } else if title == AlbumConstants.menuCover {
            core.secretDB.updateDirCustomizeCover(dirID: dirObj.localID, cover: fileObj.name!)
        } else if title == AlbumConstants.menuDelete {
            guard let folderName = dirObj.name else { return }
            guard let iconName = fileObj.name else { return }
            
            var fileExt = FileExtension.pic
            if fileObj.mediaType == PHAssetMediaType.video.rawValue {
                fileExt = .mp4
            }
            
            if let dataPath = FileUtils.getMediaPath(folderName, iconName: iconName, ext: fileExt) {
                FileUtils.removeItem(atPath: dataPath)
            }
            
            if let thumbPath = FileUtils.getMediaPath(folderName, iconName: iconName, ext: .picThumb) {
                FileUtils.removeItem(atPath: thumbPath)
            }
            
            core.secretDB.deleteSecretFileRecord(localID: fileObj.localID)
            
            self.datas.removeAll { $0.localID == fileObj.localID }
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            
        } else {
            
        }
    }
    
    func appropritePickerFilter() -> [PHPickerFilter] {
        if dirObj.name == FilesConstants.fixDirVideos {
            return [.videos]
        } else if dirObj.name == FilesConstants.fixDirPhotos {
            return [.images]
        } else if dirObj.name == FilesConstants.fixDirFiles {
            return [.images]
        } else {
            
        }
        
        return [.images, .videos]
    }
    
    func appropriteFileImageName(_ fileName: String) -> String {
        if fileName.hasSuffix(".ppt") || fileName.hasPrefix(".pptx") {
            return "icon_ppt"
        } else if fileName.hasSuffix(".doc") {
            return "icon_doc"
        } else if fileName.hasSuffix(".txt") {
            return "icon_txt"
        } else if fileName.hasSuffix(".rar") {
            return "icon_zip"
        } else if fileName.hasSuffix(".xls") || fileName.hasSuffix(".number") {
            return "icon_doc"
        } else if fileName.hasSuffix(".pages") {
            return "icon_pages"
        }
        
        return "icon_file"
    }
    
    func getThumbnailImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .fastFormat
        options.resizeMode = .fast
        options.normalizedCropRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        options.isNetworkAccessAllowed = false
        
        let imageManager = PHImageManager.default()
        let width = CGFloat(asset.pixelWidth)
        let height = CGFloat(asset.pixelHeight)
        
        imageManager.requestImage(for: asset,
                                  targetSize: CGSize(width: width, height: height),
                                  contentMode: .aspectFit,
                                  options: options) { (image, info) in
            completion(image)
        }
    }
    
    func getFileSize(_ fileName: String) -> String {
        if
            let dirName = dirObj.name,
            let filePath = FileUtils.getFilePath(dirName, fileName: fileName)
        {
            return Utils.goodFormatSizeStr(FileUtils.getFileSize(atPath: filePath))
        }
        
        return ""
    }
    
    func fetchFiles() {
        self.fetchFiles { datas in
            self.datas = datas
        }
    }
    
    private func fetchFiles(completion: @escaping ([SecretFileObject]) -> Void) {
        print("xxxx fetch \(dirObj.localID) dirs.")
        completion(
            core.secretDB.getAllSecretFiles(self.dirObj.localID)
        )
    }
}
