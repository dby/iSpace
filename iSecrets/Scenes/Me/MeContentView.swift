//
//  MeContentView.swift
//  iSecrets
//
//  Created by dby on 2023/7/7.
//

import SwiftUI

struct MeContentView: View {
    private var titles: [[String]] = [
        ["导入中自动删除原文件", "启用入侵抓拍"],
        ["入侵记录", "伪装空间", "修改密码"],
        ["分享给好友", "关于我们", "五星好评", "意见反馈"]
    ]
    
    @State private var isDeleteOrigFile: Bool = false
    @State private var isIntrusionCapture: Bool = false
    @State private var newPwd: String = ""
    @State private var isPresenting: Bool = false
    
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(titles[0], id: \.self) { item in
                        HStack {
                            Text(item)
                            Spacer()
                            if (item == "导入中自动删除原文件") {
                                Toggle(isOn: $isDeleteOrigFile) {
                                }
                                .frame(width:100, height: 20)
                                .background(Color.clear)
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
                        NavigationLink(value: Route.settings(item)) {
                            HStack {
                                Text(item)
                                Spacer()
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
                            self.isPresenting = true
                        }
                    }
                } header: {
                    Text("其他设置")
                }
            }
            .fullScreenCover(isPresented: $isPresenting, content: {
                EnterPwdView()
                    .environmentObject(homeCoordinator)
                    .ignoresSafeArea()
            })
            .navigationDestination(for: Route.self) { route in
                switch route {
                case let .settings(title):
                    if title == "入侵记录" {
                        IntrusionRecordView()
                    }
                }
            }
        }
    }
}

struct MeContentView_Previews: PreviewProvider {
    static var previews: some View {
        MeContentView()
    }
}
