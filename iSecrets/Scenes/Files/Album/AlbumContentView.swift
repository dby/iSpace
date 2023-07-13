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
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    
    @ObservedObject var viewModel: AlbumViewModel
    
    @State private var selectedImage: [PhotosPickerItem] = []
    
    // MARK: Views
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.datas.count > 0 {
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach(Array(viewModel.datas.enumerated()), id: \.1.name.self) { index, dataitem in
                                if
                                    let dataitem = dataitem,
                                    let rootDir = PathUtils.rootDir(),
                                    let fileUrl = URL(filePath: "\(rootDir)/\(secretDirObj.name!)/\(dataitem.name!)")
                                {
                                    KFImage.url(fileUrl)
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
                                            HStack {
                                                Image(systemName: "arrow.2.circlepath.circle")
                                                    .resizable()
                                                    .frame(width: 50, height: 50)
                                                    .padding(10)
                                                Text("Loading...").font(.title3)
                                            }
                                            .foregroundColor(.gray)
                                        }
                                        .frame(height: 150)
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(10)
                                        .background(Color.clear)
                                        .onTapGesture {
                                            var list: [HeroBrowserViewModule] = []
                                            for item in viewModel.datas {
                                                if
                                                    let rootDir = PathUtils.rootDir(),
                                                    let img = UIImage(contentsOfFile: "\(rootDir)/\(secretDirObj.name!)/\(item.name!)")
                                                {
                                                    list.append(HeroBrowserLocalImageViewModule(image: img))
                                                }
                                            }
                                            myAppRootVC?.hero.browserPhoto(viewModules: list, initIndex: index)
                                        }
                                }
                            }
                        }
                        Spacer()
                    }
                } else {
                    Spacer()
                    Text("Please select image by tapping on image.")
                }
                Spacer()
            }
            .toolbar {
                PhotosPicker(selection: $selectedImage, matching: .images) {
                    Image(systemName: "plus")
                        .tint(.mint)
                }.onChange(of: selectedImage) { newValue in
                    Task {
                        selectedImage = []
                        var lastIconName = ""
                        for item in newValue {
                            if let data = try? await item.loadTransferable(type: Data.self) {
                                if
                                    let rootDir = PathUtils.rootDir(),
                                    let folderName = secretDirObj.name
                                {
                                    let iconName: String = "\(data.md5)_\(Date.now.timeIntervalSince1970)"
                                    let fullPath = "\(rootDir)/\(folderName)/\(iconName)"
                                    
                                    if (FileUtils.writeDataToPath(fullPath, data: data)) {
                                        lastIconName = iconName
                                        core.secretDB.addSecretFile(dirLocalID: secretDirObj.localID,
                                                                    name: iconName,
                                                                    cipher: "")
                                    }
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
        .padding()
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
//            KFImage.url(url)
//                .resizable()
//                .onSuccess { r in
//                    print("Success: \(self.index) - \(r.cacheType)")
//                }
//                .onFailure { e in
//                    print("Error \(self.index): \(e)")
//                }
//                .onProgress { downloaded, total in
//                    print("\(downloaded) / \(total))")
//                }
//                .placeholder {
//                    HStack {
//                        Image(systemName: "arrow.2.circlepath.circle")
//                            .resizable()
//                            .frame(width: 50, height: 50)
//                            .padding(10)
//                        Text("Loading...").font(.title)
//                    }
//                    .foregroundColor(.gray)
//                }
//
//                .cornerRadius(20)

            Image(uiImage: image)
            
            Spacer()
        }.padding(.vertical, 12)
    }

}
