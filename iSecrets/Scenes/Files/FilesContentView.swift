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
    let fourGridLayout = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // MARK: Views
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Spacer()
                    LazyVGrid(columns: horizontalSizeClass == .compact ? twoGridLayout : fourGridLayout, spacing: 10) {
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
                                            .background(Color(uiColor: iColor.tertiary))
                                            .cornerRadius(5)
                                            .padding(EdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 5))
                                    }
                                }
                                
                                HStack {
                                    Text(item.name ?? "")
                                        .font(Font.system(size: 12))
                                        .bold()
                                        .foregroundColor(Color(uiColor: iColor.secondary))
                                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
                                        .cornerRadius(5)
                                    Spacer()
                                }
                                HStack {
                                    Text("\(item.fileCnt)")
                                        .foregroundColor(Color(uiColor: iColor.secondary))
                                        .font(Font.system(size: 10))
                                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                                        .cornerRadius(5)
                                    Spacer()
                                }
                                
                                Spacer()
                            }
                            .frame(width: horizontalSizeClass == .compact ? headerWid/2 : headerWid/4,
                                   height: horizontalSizeClass == .compact ? headerWid/2 + 40 : headerWid/4 + 40)
                            .onTapGesture {
                                self.clickedSecretDir = item
                                self.viewModel.detailViewModel = item.viewmodel
                                if item.cipher == "" {
                                    //未额外加密
                                    self.pushKey.toggle()
                                } else {
                                    self.alertParas = AlertParas(showing: true,
                                                                 title: "Please Enter Password".localized(),
                                                                 info: "Please Enter Password".localized())
                                }
                            }.contextMenu {
                                ForEach(viewModel.menuTitles(item), id: \.0.self) { pair in
                                    Button {
                                        if (pair.0 == FilesConstants.menuRenameDir) {
                                            self.clickedSecretDir = item
                                            self.alertParas = AlertParas(showing: true,
                                                                         title: "Please enter a new filename".localized(),
                                                                         info: "Please enter a new filename".localized())
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
            .navigationTitle("Folder".localized())
            
            .foregroundColor(Color.red)
            .navigationBarTitleDisplayMode(.large)
            .toolbar(content: {
                ToolbarItemGroup(placement: .secondaryAction) {
                    Button("New Folder".localized()) {
                        alertParas = AlertParas(showing: true, title: "New Folder".localized(), info: "Please enter a new filename".localized())
                    }.alert(alertParas.title, isPresented: $alertParas.showing) {
                        TextField(alertParas.info, text: $name)
                            .keyboardType(.numberPad)
                            .onReceive(Just(name)) { newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                if filtered.count > 6 {
                                    name = String(filtered.prefix(6))
                                } else {
                                    name = filtered
                                }
                            }
                        Button("Cancel".localized()) {
                            name = ""
                            alertParas = AlertParas()
                        }
                        Button("OK".localized()) {
                            if self.alertParas.title == "New Folder".localized() {
                                viewModel.createNewDirWithName(name)
                                viewModel.refreshSecretDirs()
                            } else if self.alertParas.title == "Please Enter Password".localized() {
                                if (name == core.account.1?.pwd) {
                                    self.pushKey.toggle()
                                } else {
                                    homeCoordinator.toast("Wrong Password".localized())
                                }
                            } else if self.alertParas.title == "Please enter a new filename".localized() {
                                if let dir = self.clickedSecretDir {
                                    core.secretDB.updateDirName(dirID: dir.localID, dirName: name)
                                    viewModel.refreshSecretDirs()
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
                    .navigationTitle(self.clickedSecretDir?.pwd ?? "")
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
