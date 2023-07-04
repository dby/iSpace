//
//  AlbumContentView.swift
//  iSecrets
//
//  Created by dby on 2023/6/11.
//

import SwiftUI
import JFHeroBrowser
import PhotosUI

let keyWindow = UIApplication.shared.connectedScenes
                        .map({ $0 as? UIWindowScene })
                        .compactMap({ $0 })
                        .first?.windows.first

let myAppRootVC : UIViewController? = keyWindow?.rootViewController

let origins: [UIImage] = {
    var temp: [UIImage] = []
    for i in 1...20 {
        temp.append(UIImage(named: "pwd_uninput")!)
    }
    return temp
}()

struct AlbumContentView: View {
    var secretDirObj: SecretDirObject
    
    @State var columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    
    @StateObject var viewModel: AlbumViewModel = AlbumViewModel()
    @State private var selectedImage: [PhotosPickerItem] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.datas.count > 0 {
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach(viewModel.datas, id: \.name.self) { dataitem in
                                if
                                    let dataitem = dataitem,
                                    let imgData = dataitem.data,
                                    let uiImage = UIImage(data: imgData)
                                {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .frame(height: 150)
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(10)
                                        .onTapGesture {
                                            var list: [HeroBrowserViewModule] = []
                                            for item in viewModel.datas {
                                                if let imgData = item.data, let img = UIImage(data: imgData) {
                                                    list.append(HeroBrowserLocalImageViewModule(image: img))
                                                }
                                            }
                                            myAppRootVC?.hero.browserPhoto(viewModules: list, initIndex: 0)
                                        }
                                }
                            }
                        }
                    }
                } else {
                    Spacer()
                    Text("Please select image by tapping on image.")
                }
                Spacer()
            }.onAppear {
                viewModel.loadDatas(secretDirObj)
            }
            .toolbar {
                PhotosPicker(selection: $selectedImage, matching: .images) {
                    Image(systemName: "plus")
                        .tint(.mint)
                }.onChange(of: selectedImage) { newValue in
                    Task {
                        selectedImage = []
                        for item in newValue {
                            if let data = try? await item.loadTransferable(type: Data.self) {
                                if
                                    let rootDir = PathUtils.rootDir(),
                                    let folderName = secretDirObj.name
                                {
                                    let iconName: String = "\(data.md5)_\(Date.now.timeIntervalSince1970)"
                                    let fullPath = "\(rootDir)/\(folderName)/\(iconName)"
                                    
                                    if (FileUtils.writeDataToPath(fullPath, data: data)) {
                                        core.secretDB.addSecretFile(dirLocalID: secretDirObj.localID,
                                                                    name: iconName,
                                                                    cipher: "")
                                    }
                                }
                            }
                        }
                        
                        viewModel.loadDatas(secretDirObj)
                    }
                }
            }
        }
        .padding()
    }
}

struct AlbumContentView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumContentView(secretDirObj: SecretDirObject())
    }
}

struct ImageCell: View {
    var alreadyCached: Bool {
//        ImageCache.default.isCached(forKey: url.absoluteString)
        true
    }

    let index: Int
    var image: UIImage {
        origins[index]
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
