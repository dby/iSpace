//
//  MeContentView.swift
//  iSecrets
//
//  Created by dby on 2023/7/7.
//

import SwiftUI
import AlertToast
import Combine

struct MeConstants {
    /// 抓拍记录
    static let _intrusionCapture: String = "Intrusion Record".localized()
    static let _fakeSpace: String = "Fake Space".localized()
    static let _changePws: String = "Change Password".localized()
    static let _shareToFriends: String = "Share with friends".localized()
    static let _aboutUS: String = "About Us".localized()
    static let _feedback: String = "Feedback".localized()
    static let _fiveStarPraise: String = "Five -star praise".localized()
    static let _enableCapture = "Enable invasion shot".localized()
    static let _deleteOrigFileWhenImport = "Automatically delete the original file during import".localized()

    /// UserDefault Key
    static let _isDeleteOrigFileKey: String = "DeleteOrigFilesKey"
    static let _isOpenFakeSpaceKey: String = "isOpenFakeSpaceKey"
}

struct MeContentView: View {
    private var titles: [[String]] = [
        [MeConstants._deleteOrigFileWhenImport, MeConstants._enableCapture],
        [MeConstants._intrusionCapture, MeConstants._fakeSpace, MeConstants._changePws],
        [MeConstants._shareToFriends, MeConstants._aboutUS, MeConstants._fiveStarPraise, MeConstants._feedback]
    ]
    
    @State private var isDeleteOrigFile: Bool = Settings.isDeleteOrigFile {
        didSet {
            Settings.isDeleteOrigFile = isDeleteOrigFile
        }
    }
    @State private var isIntrusionCapture: Bool = false
    @State private var isShowingAlert: Bool = false
    @State private var oldPwd: String = ""
    
    @StateObject private var meRouter: MeRouter
    @ObservedObject var viewModel: MeViewModel
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    
    init(router: MeRouter, viewModel: MeViewModel) {
        _meRouter = StateObject(wrappedValue: router)
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        RoutingView(router: meRouter, content: {
            List {
                Section {
                    ProgressView(viewModel.diskUsageText, value: viewModel.diskUsage, total: FILESIZE_1G)
                        .font(Font.system(size: 14))
                        .bold()
                        .foregroundColor(Color(uiColor: iColor.primary))
                        .progressViewStyle(.linear)
                } header: {
                    Text("Storage".localized())
                }
                
                Section {
                    ForEach(titles[0], id: \.self) { item in
                        HStack {
                            Text(item)
                                .foregroundColor(Color(uiColor: iColor.primary))
                            Spacer()
                            if (item == MeConstants._deleteOrigFileWhenImport) {
                                Toggle(isOn: $isDeleteOrigFile) { }
                                .frame(width:100, height: 20)
                                .background(Color.clear)
                                .onTapGesture {
                                    print("toggle isDeleteOrigFile to \(!isDeleteOrigFile)")
                                    Settings.isDeleteOrigFile = !isDeleteOrigFile
                                }
                            } else {
                                Toggle(isOn: $isIntrusionCapture) {
                                }
                                .frame(width:100, height: 20)
                                .background(Color.clear)
                            }
                        }
                    }
                } header: {
                    Text("My settings".localized())
                }
                
                Section {
                    ForEach(titles[1], id: \.self) { item in
                        HStack {
                            Text(item)
                                .foregroundColor(Color(uiColor: iColor.primary))
                                .frame(height:30)
                            Spacer()
                        }
                        .background(Color(uiColor: UIColor.clear))
                        .alert("Please enter the original password".localized(), isPresented: $isShowingAlert) {
                            TextField("Please enter the original password".localized(), text: $oldPwd)
                                .keyboardType(.numberPad)
                                .onReceive(Just(oldPwd)) { newValue in
                                    if newValue.count > 6 {
                                        self.oldPwd = String(newValue.prefix(6))
                                        print("OLDPWD: [\(self.oldPwd)]")
                                    }
                                }
                            Button("Cancel".localized()) {
                                
                            }
                            Button("OK".localized()) {
                                if core.account.1?.pwd == oldPwd {
                                    meRouter.presentFullScreen(.detail(MeConstants._changePws))
                                } else {
                                    homeCoordinator.toast("Wrong Password".localized())
                                }
                                
                                oldPwd = ""
                            }
                        }
                        .onTapGesture {
                            if item == "Change Password".localized() {
                                self.isShowingAlert = true
                            } else {
                                meRouter.presentDetail(description: item)
                            }
                        }
                    }
                } header: {
                    Text("Common Functions".localized())
                }.headerProminence(.standard)
                
                Section {
                    ForEach(titles[2], id: \.self) { item in
                        HStack {
                            Text(item)
                                .foregroundColor(Color(uiColor: iColor.primary))
                            Spacer()
                        }
                        .onTapGesture {
                            if item == MeConstants._shareToFriends {
                                viewModel.shareAppToFriends()
                            } else {
                                meRouter.presentDetail(description: item)
                            }
                        }
                    }
                } header: {
                    Text("Other Settings".localized())
                }
            }
        })
        .onAppear(perform: {
            self.viewModel.calcDiskUsage()
        })
    }
}

//struct MeContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        MeContentView(router: MeRouter(isPresented: .constant(.main)), viewModel: MeViewModel())
//    }
//}
