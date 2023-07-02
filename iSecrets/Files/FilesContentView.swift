//
//  FilesContentView.swift
//  iSecrets
//
//  Created by dby on 2023/6/11.
//

import SwiftUI
import PhotosUI

struct FilesContentView: View {
    
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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Spacer()
                    LazyVGrid(columns: twoGridLayout, spacing: 15) {
                        ForEach(core.getAllSecretDirs(), id: \.name.self) { item in
                            Text(item.name ?? "")
                                .frame(width: headerWid/2, height: headerWid/2)
                                .background(.cyan)
                                .cornerRadius(5)
                                .onTapGesture {
                                    print("1111 \(item)")
                                    self.clickedSecretDir = item
                                    self.pushKey.toggle()
                                }
                        }
                    }.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                }
            }
            .navigationTitle("文件夹")
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
                if clickedSecretDir != nil {
                    AlbumContentView(secretDirObj: clickedSecretDir!)
                }
            })
            .navigationDestination(isPresented: $pushKey, destination: {
                if clickedSecretDir != nil {
                    AlbumContentView(secretDirObj: clickedSecretDir!)
                }
            })
            .navigationBarTitleDisplayMode(.large)
        }
        
                
//        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
//                  pinnedViews: [.sectionHeaders, .sectionFooters]) {
//            ForEach(0 ..< 5){ index in
//                Section(header: Text("Header \(index)")
//                    .bold()
//                    .font(.title)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background(Color.white),
//                        footer: Text("Footer \(index)")
//                    .bold()
//                    .font(.title)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background(Color.white)
//                ) {
//
//                    ForEach(datas, id: \.self) { item in
//                        Text(item)
//                            .background(.red)
//                    }
//                }
//            }
//        }
//        .padding()
    }
}

struct FilesContentView_Previews: PreviewProvider {
    static var previews: some View {
        FilesContentView()
    }
}
