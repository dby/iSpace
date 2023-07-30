//
//  AlbumContentView.swift
//  iSecrets
//
//  Created by dby on 2023/6/11.
//

import SwiftUI
import JFHeroBrowser
import PhotosUI
import Kingfisher

let keyWindow = UIApplication.shared.connectedScenes
                        .map({ $0 as? UIWindowScene })
                        .compactMap({ $0 })
                        .first?.windows.first

let myAppRootVC : UIViewController? = keyWindow?.rootViewController

struct AlbumContentView: View {
    // MARK: Stored Properties
    var secretDirObj: SecretDirObject
    var columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
//        GridItem(.flexible(), spacing: 2),
//        GridItem(.flexible(), spacing: 2),
//        GridItem(.flexible(), spacing: 2)
    ]
    
    @ObservedObject var viewModel: AlbumViewModel
    @State private var selectedImage: [PhotosPickerItem] = []
    
    // MARK: Views
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.datas.count > 0 {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(Array(viewModel.datas.enumerated()), id: \.1.name.self) { index, dataitem in
                                if let fullPicThumbPath = FileUtils.getFilePath(secretDirObj.name!, iconName: dataitem.name!, ext: .picThumb) {
                                    VStack {
                                        GeometryReader { geo in
                                            KFImage.url(URL(filePath: fullPicThumbPath))
                                                .resizable()
                                                .onSuccess { r in
                                                    print("Success: \(r.cacheType)")
                                                }
                                                .onFailure { e in
                                                    print("Error: \(e)")
                                                }
                                                .onProgress { downloaded, total in
                                                    print("\(downloaded) / \(total))")
                                                }
                                                .placeholder {
                                                    GeometryReader { geo in
                                                        HStack {
                                                            ProgressView()
                                                        }
                                                        .frame(width: geo.size.width, height: geo.size.height)
                                                        .background(.gray)
                                                    }
                                                }
                                                .aspectRatio(1, contentMode: .fit)
                                                .frame(height: geo.size.width)
                                                .background(Color.clear)
                                                .onTapGesture {
                                                    var list: [HeroBrowserViewModule] = []
                                                    for item in viewModel.datas {
                                                        if
                                                            let fullPicPath = FileUtils.getFilePath(secretDirObj.name!, iconName: item.name!, ext: .pic),
                                                            let img = UIImage(contentsOfFile: fullPicPath)
                                                        {
                                                            list.append(HeroBrowserLocalImageViewModule(image: img))
                                                        }
                                                    }
                                                    myAppRootVC?.hero.browserPhoto(viewModules: list, initIndex: index)
                                                }
                                        }
                                    }
                                    .aspectRatio(1, contentMode: .fit) //设置宽高比例为 1:1
                                }
                            }
                        }
                    }
                } else {
                    Spacer()
                    Text("Please select image by tapping on image.")
                    Spacer()
                }
            }
            .toolbar {
                PhotosPicker(selection: $selectedImage, matching: .images, photoLibrary: .shared()) {
                    Image(systemName: "plus")
                        .tint(.mint)
                }.onChange(of: selectedImage) { newValue in
                    Task {
                        selectedImage = []
                        
                        if Settings.isDeleteOrigFile {
                            var pendingDeleteAssets: [PHAsset] = []
                            for item in newValue {
                                if let localIdentifier = item.itemIdentifier {
                                    let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
                                    if let asset = fetchResult.firstObject {
                                        pendingDeleteAssets.append(asset)
                                    }
                                }
                            }
                            
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.deleteAssets(pendingDeleteAssets as NSArray)
                            }, completionHandler: { success, error in
                                if success {
                                    print("照片已成功删除")
                                } else if let error = error {
                                    print("删除照片时出错：\(error.localizedDescription)")
                                }
                            })
                        }
                        
                        var lastIconName = ""
                        for item in newValue {
                            if let data = try? await item.loadTransferable(type: Data.self) {
                                if let folderName = secretDirObj.name {
                                    let iconName: String = "\(data.md5)_\(Int(Date.now.timeIntervalSince1970 * 1000))"
                                    let fullPicPath = FileUtils.getFilePath(folderName, iconName: iconName, ext: .pic)
                                    let fullPicThumbPath = FileUtils.getFilePath(folderName, iconName: iconName, ext: .picThumb)
                                    
                                    guard let fullPicPath = fullPicPath else { continue }
                                    guard let fullPicThumbPath = fullPicThumbPath else { continue }
                                    
                                    if (FileUtils.writeDataToPath(fullPicPath, data: data)) {
                                        if let thumbData = genThumbnailAspectFill(for: data)  {
                                            _ = FileUtils.writeDataToPath(fullPicThumbPath, data: thumbData)
                                        }
                                        
                                        lastIconName = iconName
                                        core.secretDB.addSecretFile(dirLocalID: secretDirObj.localID,
                                                                    name: iconName,
                                                                    cipher: "")
                                    }
                                    
                                    viewModel.deleteImage(UIImage(data: data))
                                }
                            }
                        }
                        
                        core.secretDB.updateDirThumb(dirID: secretDirObj.localID,
                                                     thumb: lastIconName)
                        
                        viewModel.fetchFiles()
                    }
                }
            }
        }
    }
}

//struct AlbumContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        AlbumContentView(secretDirObj: SecretDirObject())
//    }
//}

struct ImageCell: View {
    var alreadyCached: Bool {
//        ImageCache.default.isCached(forKey: url.absoluteString)
        true
    }

    let index: Int
    var image: UIImage {
        return UIImage(systemName: "arrow.2.circlepath.circle")!
    }

    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            Image(uiImage: image)
            Spacer()
        }.padding(.vertical, 12)
    }
}
