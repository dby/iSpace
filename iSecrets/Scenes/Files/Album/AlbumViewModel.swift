//
//  AlbumViewModel.swift
//  iSecrets
//
//  Created by dby on 2023/7/9.
//

import Foundation
import PhotosUI

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
    
    func addImageToDir(_ dirObj: SecretDirObject, data: Data) -> String? {
        if let folderName = dirObj.name {
            let iconName: String = "\(data.md5)_\(Int(Date.now.timeIntervalSince1970 * 1000))"
            let fullPicPath = FileUtils.getFilePath(folderName, iconName: iconName, ext: .pic)
            let fullPicThumbPath = FileUtils.getFilePath(folderName, iconName: iconName, ext: .picThumb)
            
            guard let fullPicPath = fullPicPath else { return nil }
            guard let fullPicThumbPath = fullPicThumbPath else { return nil }
            
            if (FileUtils.writeDataToPath(fullPicPath, data: data)) {
                if let thumbData = genThumbnailAspectFill(for: data)  {
                    _ = FileUtils.writeDataToPath(fullPicThumbPath, data: thumbData)
                }
                
                core.secretDB.addSecretFile(dirLocalID: dirObj.localID,
                                            name: iconName,
                                            cipher: "")
                
                return iconName
            }
        }
        
        return nil
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
