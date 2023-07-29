//
//  MeContentView.swift
//  iSecrets
//
//  Created by dby on 2023/7/7.
//

import SwiftUI
import AlertToast

struct MeConstants {
    /// 抓拍记录
    static let _intrusionCapture: String = "入侵记录"
    static let _fakeSpace: String = "伪装空间"
    static let _changePws: String = "修改密码"
    static let _shareToFriends: String = "分享给好友"
    static let _aboutUS: String = "关于我们"
    static let _feedback: String = "意见反馈"
    static let _isDeleteOrigFileKey: String = "DeleteOrigFiles"
}

struct MeContentView: View {
    private var titles: [[String]] = [
        ["导入中自动删除原文件", "启用入侵抓拍"],
        ["入侵记录", "伪装空间", "修改密码"],
        ["分享给好友", "关于我们", "五星好评", "意见反馈"]
    ]
    
    @State private var isDeleteOrigFile: Bool = Settings.isDeleteOrigFile {
        didSet {
            Settings.isDeleteOrigFile = isDeleteOrigFile
        }
    }
    @State private var isIntrusionCapture: Bool = false
    @State private var isShowingAlert: Bool = false
    @State private var oldPwd: String = ""
    @State private var toastPara: ToastParas = ToastParas()
    
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
                VStack {
                    ProgressView(viewModel.diskUsageText, value: viewModel.diskUsage, total: FILESIZE_1G)
                        .font(Font.system(size: 15))
                        .foregroundColor(Color.gray)
                        .progressViewStyle(.linear)
                }
                .padding()
                
                Section {
                    ForEach(titles[0], id: \.self) { item in
                        HStack {
                            Text(item)
                            Spacer()
                            if (item == "导入中自动删除原文件") {
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
                    Text("我的设置")
                }
                
                Section {
                    ForEach(titles[1], id: \.self) { item in
                        HStack {
                            Text(item)
                                .frame(height:30)
                            Spacer()
                        }
                        .background(Color(uiColor: UIColor.systemBackground))
                        .alert("请输入原密码", isPresented: $isShowingAlert) {
                            TextField("请输入原密码", text: $oldPwd)
                            Button("Cancel") {
                                
                            }
                            Button("OK") {
                                if core.account.1 == oldPwd {
                                    meRouter.presentFullScreen(.detail(MeConstants._changePws))
                                } else {
                                    self.toastPara.title = "密码错误"
                                    self.toastPara.showing = true
                                }
                                
                                oldPwd = ""
                            }
                        }
                        .onTapGesture {
                            if item == "修改密码" {
                                self.isShowingAlert = true
                            } else {
                                meRouter.presentDetail(description: item)
                            }
                        }
                    }
                } header: {
                    Text("常用功能")
                }.headerProminence(.standard)
                
                Section {
                    ForEach(titles[2], id: \.self) { item in
                        HStack {
                            Text(item)
                            Spacer()
                        }
                        .onTapGesture {
                            meRouter.presentDetail(description: item)
                        }
                    }
                } header: {
                    Text("其他设置")
                }
            }
        })
        .toast(isPresenting: $toastPara.showing) {
            AlertToast(displayMode: .banner(.slide), type: .regular, title: toastPara.title)
        }
        .onAppear(perform: {
            self.viewModel.calcDiskUsage()
        })
    }
}

struct MeContentView_Previews: PreviewProvider {
    static var previews: some View {
        MeContentView(router: MeRouter(isPresented: .constant(.main)), viewModel: MeViewModel())
    }
}
