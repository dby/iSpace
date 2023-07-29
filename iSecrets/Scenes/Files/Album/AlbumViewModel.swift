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

extension AlbumViewModel {
    func deleteImage(_ image: UIImage?) {
        guard let image = image else { return }
        
        if let asset = getAsset(for: image) {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets([asset] as NSArray)
            }, completionHandler: { success, error in
                if success {
                    DispatchQueue.main.async {
                        //images.removeAll(where: { $0 == image })
                    }
                } else {
                    print("Error deleting image: \(error?.localizedDescription ?? "Unknown error")")
                }
            })
        }
    }
    
    private func getAsset(for image: UIImage) -> PHAsset? {
        var result: PHAsset?
        let options = PHFetchOptions()
        options.includeAssetSourceTypes = [.typeUserLibrary, .typeCloudShared, .typeiTunesSynced]
        let fetchResult = PHAsset.fetchAssets(with: options)
        fetchResult.enumerateObjects { asset, _, _ in
            let imageManager = PHImageManager.default()
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.resizeMode = .exact
            requestOptions.normalizedCropRect = CGRect(x: 0, y: 0, width: 1, height: 1)
            imageManager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: requestOptions) { resultImage, _ in
                if let resultImage = resultImage, resultImage == image {
                    result = asset
                }
            }
        }
        
        return result
    }
}
