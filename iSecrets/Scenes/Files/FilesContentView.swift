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
    @State private var presetnKey = false
    @State private var pushKey = false
    
    @State private var clickedSecretDir: SecretDirObject? = nil
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedPhotosData: [Data] = []
    
    @ObservedObject var coordinator: FilesCoordinator
    
    // MARK: Views
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Spacer()
                    LazyVGrid(columns: twoGridLayout, spacing: 15) {
                        ForEach(coordinator.dirs, id: \.name.self) { item in
                            ZStack {
                                if let rootDir = PathUtils.rootDir(),
                                   let fileUrl = URL(filePath: "\(rootDir)/\(item.name!)/\(item.thumb!)") {
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
                                }
                                
                                Text(item.name ?? "")
                                    .background(.red)
                                    .cornerRadius(5)
                            }
                            .frame(width: headerWid/2, height: headerWid*0.66)
                            .cornerRadius(10)
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
                albumView(coordinator.detailViewModel)
            })
            .navigationDestination(isPresented: $pushKey, destination: {
                albumView(coordinator.detailViewModel)
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
