//
//  FilesContentView.swift
//  iSecrets
//
//  Created by dby on 2023/6/11.
//

import SwiftUI
import PhotosUI
import Kingfisher
import Combine

struct FilesContentView: View {

    // MARK: Stored Properties
    let twoGridLayout = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
    ]
    
    let headerWid = UIScreen.main.bounds.size.width - 40

    @State private var name = ""
    @State private var presetnKey = true
    @State private var pushKey = false
    
    @State private var clickedSecretDir: SecretDirObject? = nil
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedPhotosData: [Data] = []
    
    @State private var alertParas: AlertParas = AlertParas()
    
    @ObservedObject var viewModel: FilesViewModel
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    
    // MARK: Views
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Spacer()
                    LazyVGrid(columns: twoGridLayout, spacing: 10) {
                        ForEach(viewModel.dirs, id: \.name.self) { item in
                            VStack(spacing: 0) {
                                if let fullPicThumbPath = FileUtils.getFolderCover(item),
                                   FileUtils.fileExists(atPath: fullPicThumbPath)
                                {
                                    ZStack {
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
                                                .frame(height: geo.size.width - 10)
                                                .aspectRatio(1, contentMode: .fit)
                                                .padding(EdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 5))
                                                .cornerRadius(5)
                                                .blur(radius: item.cipher == "" ? 0 : 3)
                                        }
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Image(systemName: "lock.shield.fill")
                                                    .foregroundColor(Color(uiColor: UIColor.white))
                                                    .frame(width: 60, height: 60)
                                                Spacer()
                                            }
                                        }.opacity(item.cipher == "" ? 0 : 1)
                                    }
                                } else {
                                    GeometryReader { geo in
                                        Text("")
                                            .frame(width: geo.size.width - 10, height: geo.size.width - 10)
                                            .background(Color(uiColor: UIColor.lightGray))
                                            .cornerRadius(5)
                                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 5))
                                    }
                                }
                                
                                HStack {
                                    Text(item.name ?? "")
                                        .font(Font.system(size: 12))
                                        .bold()
                                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
                                        .cornerRadius(5)
                                    Spacer()
                                }
                                HStack {
                                    Text("\(item.fileCnt)")
                                        .font(Font.system(size: 10))
                                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                                        .cornerRadius(5)
                                    Spacer()
                                }
                                
                                Spacer()
                            }
                            .frame(width: headerWid/2, height: headerWid*0.5 + 40)
                            .onTapGesture {
                                self.clickedSecretDir = item
                                self.viewModel.detailViewModel = item.viewmodel
                                if item.cipher == "" {
                                    //未额外加密
                                    self.pushKey.toggle()
                                } else {
                                    self.alertParas = AlertParas(showing: true, title: "请输入密码", info: "请输入密码")
                                }
                            }.contextMenu {
                                ForEach(viewModel.menuTitles(item), id: \.0.self) { pair in
                                    Button {
                                        if (pair.0 == FilesConstants.menuRenameDir) {
                                            //self.showingAlert = true
                                        } else {
                                            viewModel.contextMenuDidClicked(pair.0, dirObj: item)
                                        }
                                    } label: {
                                        Text(pair.0)
                                        Image(systemName: pair.1)
                                    }
                                }
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                }
            }
            .navigationTitle("文件夹")
            .navigationBarTitleDisplayMode(.large)
            .toolbar(content: {
                ToolbarItemGroup(placement: .secondaryAction) {
                    Button("添加文件夹") {
                        alertParas = AlertParas(showing: true, title: "新建文件夹", info: "请为此文件夹输入名称")
                    }.alert(alertParas.title, isPresented: $alertParas.showing) {
                        TextField(alertParas.info, text: $name)
                            .onReceive(Just(name)) { newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                if filtered.count > 6 {
                                    name = String(filtered.prefix(6))
                                } else {
                                    name = filtered
                                }
                            }
                        Button("Cancel") {
                            name = ""
                            alertParas = AlertParas()
                        }
                        Button("OK") {
                            if self.alertParas.title == "新建文件夹" {
                                viewModel.createNewDirWithName(name)
                                viewModel.refreshSecretDirs()
                            } else if self.alertParas.title == "请输入密码" {
                                if (name == core.account.1) {
                                    self.pushKey.toggle()
                                } else {
                                    homeCoordinator.toast("密码输入错误")
                                }
                            }
                            
                            name = ""
                        }
                    }
                }
            })
            .fullScreenCover(isPresented: $presetnKey, content: {
                EnterPwdView(viewModel: homeCoordinator.enterPwdViewModel!)
                    .navigationBarTitleDisplayMode(.inline)
            })
            .navigationDestination(isPresented: $pushKey, destination: {
                albumView(viewModel.detailViewModel)
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
