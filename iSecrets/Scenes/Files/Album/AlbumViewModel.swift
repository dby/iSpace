//
//  AlbumViewModel.swift
//  iSecrets
//
//  Created by dby on 2023/7/9.
//

import Foundation
import PhotosUI

struct AlbumConstants {
    static let menuShare: String = "共享"
    static let menuSaveToAlbum: String = "保存到手机相册"
    static let menuCover: String = "设置为封面"
    static let menuDelete: String = "删除"
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
        let fullPicPath = FileUtils.getFilePath(folderName, iconName: iconName, ext: .pic)
        let fullPicThumbPath = FileUtils.getFilePath(folderName, iconName: iconName, ext: .picThumb)
        
        guard let fullPicPath = fullPicPath else { return nil }
        guard let fullPicThumbPath = fullPicThumbPath else { return nil }
        
        /// Write Image Data
        _ = FileUtils.writeDataToPath(fullPicPath, data: data)
        /// Write Image Thumb Data
        if let thumbData = genThumbnailAspectFill(for: data)  {
            _ = FileUtils.writeDataToPath(fullPicThumbPath, data: thumbData)
        }
        /// to DB
        core.secretDB.addSecretFile(dirLocalID: dirObj.localID,
                                    name: iconName,
                                    cipher: "",
                                    asset: asset)
        
        return iconName
    }
    
    func addVideoToDir(_ dirObj: SecretDirObject, asset: PHAsset, videoData: Data) -> String? {
        guard let folderName = dirObj.name else { return nil }
        
        let iconName: String = "\(videoData.md5)_\(Int(Date.now.timeIntervalSince1970 * 1000))"
        let fullPicPath = FileUtils.getFilePath(folderName, iconName: iconName, ext: .mp4)
        let fullPicThumbPath = FileUtils.getFilePath(folderName, iconName: iconName, ext: .picThumb)
        
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
        core.secretDB.addSecretFile(dirLocalID: dirObj.localID,
                                    name: iconName,
                                    cipher: "",
                                    asset: asset)
        
        return iconName
    }
    
    func menuTitles() -> [(String, String)] {        
        var titles: [(String, String)] = [(AlbumConstants.menuShare, "square.and.arrow.up")]
        
        titles.append((AlbumConstants.menuSaveToAlbum, "photo"))
        titles.append((AlbumConstants.menuCover, "bookmark.square"))
        
        return titles
    }
    
    func contextMenuDidClicked(_ title: String, fileObj: SecretFileObject) {
        if title == AlbumConstants.menuShare {
            
        } else if title == AlbumConstants.menuSaveToAlbum {
            
        } else if title == AlbumConstants.menuCover {
            core.secretDB.updateDirCustomizeCover(dirID: dirObj.localID, cover: fileObj.name!)
        } else if title == AlbumConstants.menuDelete {
            
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
    
    func getThumbnailImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .fastFormat
        options.resizeMode = .exact
        options.normalizedCropRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        options.isNetworkAccessAllowed = true
        
        let imageManager = PHImageManager.default()
        let width = CGFloat(asset.pixelWidth)
        let height = CGFloat(asset.pixelHeight)
                
        imageManager.requestImage(for: asset, targetSize: CGSize(width: width, height: height), contentMode: .aspectFill, options: options) { (image, info) in
            completion(image)
        }
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
