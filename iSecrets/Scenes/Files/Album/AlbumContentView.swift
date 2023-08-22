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
import UniformTypeIdentifiers
import QuickLook

let keyWindow = UIApplication.shared.connectedScenes
                        .map({ $0 as? UIWindowScene })
                        .compactMap({ $0 })
                        .first?.windows.first

let myAppRootVC : UIViewController? = keyWindow?.rootViewController

struct AlbumContentView: View {
    // MARK: Stored Properties
    var secretDirObj: SecretDirObject
    var columns = [
        GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2)
    ]
    var sixColumns = [
        GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2)
    ]
    
    @State private var selectedImage: [PhotosPickerItem] = []
    @State private var importing = false
    @State private var previewFilePath: URL? = nil
    
    @ObservedObject var viewModel: AlbumViewModel
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // MARK: Views
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.datas.count > 0 {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: (horizontalSizeClass == .compact ? columns : sixColumns), spacing: 2) {
                            ForEach(Array(viewModel.datas.enumerated()), id: \.1.name.self) { index, dataitem in
                                if dataitem.fileFormat == DataCategory.file.rawValue {
                                    //预览文件
                                    GeometryReader { geo in
                                        VStack {
                                            ZStack {
                                                Image(viewModel.appropriteFileImageName(dataitem.name!))
                                            }
                                            .frame(width: geo.size.width, height: geo.size.width)
                                            .background(Color(uiColor: iColor.last))
                                            .cornerRadius(2)
                                            
                                            Text(dataitem.name!)
                                                .font(Font.system(size: 12))
                                                .foregroundColor(Color(uiColor: iColor.secondary))
                                            
                                            Text("\(viewModel.getFileSize(dataitem.name!))")
                                                .font(Font.system(size: 12))
                                                .foregroundColor(Color(uiColor: iColor.primary))
                                        }
                                        .onTapGesture {
                                            if
                                                let dirName = self.secretDirObj.name,
                                                let filePath = FileUtils.getFilePath(dirName, fileName: dataitem.name!)
                                            {
                                                self.previewFilePath = URL(fileURLWithPath: filePath)
                                            }
                                        }
                                        .contextMenu {
                                            Button {
                                                viewModel.contextMenuDidClicked(AlbumConstants.menuDelete, fileObj: dataitem)
                                            } label: {
                                                Text(AlbumConstants.menuDelete)
                                                Image(systemName: "minus.circle")
                                            }
                                        }
                                    }
                                } else if let fullPicThumbPath = FileUtils.getMediaPath(secretDirObj.name!, iconName: dataitem.name!, ext: .picThumb) {
                                    ZStack {
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
                                                    var list: [HeroBrowserViewModuleBaseProtocol] = []
                                                    for item in viewModel.datas {
                                                        if item.mediaType == PHAssetMediaType.video.rawValue {
                                                            if let fullVideoPath = FileUtils.getMediaPath(secretDirObj.name!, iconName: item.name!, ext: .mp4),
                                                               let fullThumbPath = FileUtils.getMediaPath(secretDirObj.name!, iconName: item.name!, ext: .picThumb) {
                                                                list.append(HeroBrowserVideoViewModule(thumbailImgUrl: fullThumbPath, fileUrlPath: fullVideoPath))
                                                            }
                                                        } else if item.mediaType == PHAssetMediaType.image.rawValue {
                                                            if let fullPicPath = FileUtils.getMediaPath(secretDirObj.name!, iconName: item.name!, ext: .pic),
                                                               let fullThumbPath = FileUtils.getMediaPath(secretDirObj.name!, iconName: item.name!, ext: .picThumb) {
                                                                list.append(HeroBrowserNetworkImageViewModule(thumbailImgUrl: fullThumbPath, originImgUrl: fullPicPath))
                                                            }
                                                        }
                                                    }
                                                    myAppRootVC?.hero.browserMultiSoures(viewModules: list, initIndex: index)
                                                }
                                                .contextMenu {
                                                    ForEach(viewModel.menuTitles(), id: \.0.self) { pair in
                                                        Button {
                                                            viewModel.contextMenuDidClicked(pair.0, fileObj: dataitem)
                                                            if (pair.0 == AlbumConstants.menuCover || pair.0 == AlbumConstants.menuSaveToAlbum) {
                                                                homeCoordinator.refreshDirsIfNeed()
                                                                homeCoordinator.toast("successfully set".localized())
                                                            }
                                                        } label: {
                                                            Text(pair.0)
                                                            Image(systemName: pair.1)
                                                        }
                                                    }
                                                    
                                                    Divider()
                                                    
                                                    Button {
                                                        viewModel.contextMenuDidClicked(AlbumConstants.menuDelete, fileObj: dataitem)
                                                    } label: {
                                                        Text(AlbumConstants.menuDelete)
                                                        Image(systemName: "minus.circle")
                                                    }
                                                }
                                        }
                                        
                                        if dataitem.mediaType == PHAssetMediaType.video.rawValue {
                                            VStack {
                                                Spacer()
                                                HStack {
                                                    Spacer()
                                                    Text(formatSeconds(for: dataitem.duration))
                                                        .font(Font.system(size: 12))
                                                        .foregroundColor(Color.white)
                                                        .background(Color.black.opacity(0.1))
                                                        .bold()
                                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 10))
                                                }
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
                        .foregroundColor(Color(uiColor: iColor.primary))
                    Spacer()
                }
            }
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                if secretDirObj.limitCondition == DataCategory.file.rawValue {
                    Image(systemName: "plus")
                        .foregroundColor(Color(uiColor: UIColor.systemBlue))
                        .fileImporter(isPresented: $importing, allowedContentTypes: [UTType.item]) { result in
                            if case .success(let url) = result {
                                print("File exported successfully: \(url)")
                                viewModel.addFileToDir(secretDirObj, fileUrl: url)
                            } else {
                                print("Export failed: \(result)")
                            }
                        }
                        .onTapGesture {
                            self.importing = true
                        }
                } else {
                    PhotosPicker(selection: $selectedImage, matching: .any(of: viewModel.appropritePickerFilter()), photoLibrary: .shared()) {
                        Image(systemName: "plus")
                    }.onChange(of: selectedImage) { newValue in
                        Task {
                            selectedImage = []
                            var pairsData: [(PhotosPickerItem, PHAsset)] = []
                            var pendingDeleteAssets: [PHAsset] = []
                            
                            for item in newValue {
                                if let localIdentifier = item.itemIdentifier {
                                    let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
                                    if let asset = fetchResult.firstObject {
                                        pendingDeleteAssets.append(asset)
                                        pairsData.append((item, asset))
                                    }
                                }
                            }
                            
                            if Settings.isDeleteOrigFile {
                                viewModel.deleteWithAssets(assets: pendingDeleteAssets)
                            }
                            
                            var lastIconName = ""
                            for item in pairsData {
                                if let data = try? await item.0.loadTransferable(type: Data.self) {
                                    var iconname: String? = nil
                                    if item.1.mediaType == .video {
                                        iconname = viewModel.addVideoToDir(secretDirObj, asset: item.1, videoData: data)
                                    } else if item.1.mediaType == .image {
                                        iconname = viewModel.addImageToDir(secretDirObj, asset: item.1, data: data)
                                    }
                                    
                                    lastIconName = (iconname == nil || iconname!.isEmpty) ? lastIconName : iconname!
                                }
                            }
                            
                            if !lastIconName.isEmpty {
                                core.secretDB.updateDirThumb(dirID: secretDirObj.localID,
                                                             thumb: lastIconName)
                            }
                            
                            //延时刷新UI
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                viewModel.fetchFiles()
                                homeCoordinator.refreshDirsIfNeed()
                            }
                        }
                    }
                }
            }
            .quickLookPreview($previewFilePath)
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
