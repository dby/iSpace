//
//  FilesContentView.swift
//  iSecrets
//
//  Created by dby on 2023/6/11.
//

import SwiftUI
import PhotosUI
import Kingfisher

struct FilesContentView: View {

    // MARK: Stored Properties
    let twoGridLayout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    let headerWid = UIScreen.main.bounds.size.width - 60

    @State private var showingAlert = false
    @State private var name = ""
    @State private var presetnKey = true
    @State private var pushKey = false
    
    @State private var clickedSecretDir: SecretDirObject? = nil
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedPhotosData: [Data] = []
    
    @ObservedObject var coordinator: FilesCoordinator
    @EnvironmentObject var homeCoordinator: HomeCoordinator

    // MARK: Views
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Spacer()
                    LazyVGrid(columns: twoGridLayout, spacing: 15) {
                        ForEach(coordinator.dirs, id: \.name.self) { item in
                            VStack(spacing: 0) {
                                if
                                    item.thumb != nil && item.thumb!.count != 0,
                                    item.name != nil && item.name!.count != 0,
                                    let fullPicThumbPath = FileUtils.getFilePath(item.name!, iconName: item.thumb!, ext: .picThumb),
                                    FileUtils.fileExists(atPath: fullPicThumbPath)
                                {
                                    GeometryReader { geo in
                                        KFImage.url(URL(fileURLWithPath: fullPicThumbPath))
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
                                            .frame(height: geo.size.width)
                                            .aspectRatio(1, contentMode: .fit)
                                            .cornerRadius(5)
                                    }
                                } else {
                                    Text("")
                                        .frame(width: headerWid/2, height: headerWid*0.5)
                                        .background(Color(uiColor: UIColor.lightGray))
                                        .cornerRadius(5)
                                }
                                
                                VStack(spacing: 0) {
                                    HStack {
                                        Text(item.name ?? "")
                                            .font(Font.system(size: 12))
                                            .bold()
                                            .frame(height: 20)
                                            .cornerRadius(5)
                                        Spacer()
                                    }
                                    HStack {
                                        Text("\(item.fileCnt)")
                                            .font(Font.system(size: 10))
                                            .cornerRadius(5)
                                        Spacer()
                                    }
                                }
                            }
                            .frame(width: headerWid/2, height: headerWid*0.5 + 40)
                            .onTapGesture {
                                self.pushKey.toggle()
                                self.clickedSecretDir = item
                                self.coordinator.detailViewModel = item.viewmodel
                            }
                        }
                    }.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                }
            }
            .navigationTitle("文件夹")
            .navigationBarTitleDisplayMode(.large)
            .onAppear(perform: {
                coordinator.refreshSecretDirs()
            })
            .toolbar(content: {
                ToolbarItemGroup(placement: .secondaryAction) {
                    Button("添加文件夹") {
                        showingAlert = true
                    }.alert("新建文件夹", isPresented: $showingAlert) {
                        TextField("请为此文件夹输入名称", text: $name)
                        Button("Cancel") {
                            
                        }
                        Button("OK") {
                            if (core.secretDB.addOrUpdateSecretDirRecord(limitionCondition: .all,
                                                                         name: name,
                                                                         workingDir: name.md5,
                                                                         fileFormat: "",
                                                                         cipher: "")) {
                                if let rootDir = PathUtils.rootDir() {
                                    _ = FileUtils.createFolder("\(rootDir)/\(name)")
                                }
                            }
                            
                            name = ""
                        }
                    }
                }
            })
            .fullScreenCover(isPresented: $presetnKey, content: {
                EnterPwdView()
                    .environmentObject(coordinator)
                    .navigationBarTitleDisplayMode(.inline)
            })
            .navigationDestination(isPresented: $pushKey, destination: {
                albumView(coordinator.detailViewModel)
                    .navigationBarTitleDisplayMode(.inline)
            })
        }
    }
    
    @ViewBuilder
    private func albumView(_ viewModel: AlbumViewModel?) -> some View {
        if viewModel != nil {
            AlbumContentView(
                secretDirObj: self.clickedSecretDir!,
                viewModel: viewModel!
            )
        } else {
            EmptyView()
        }
    }
}

//struct FilesContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        FilesContentView()
//    }
//}
