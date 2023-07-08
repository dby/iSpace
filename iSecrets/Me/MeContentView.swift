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
    
    @State private var showNotification: Bool = false
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible())],
                      spacing: 0,
                      pinnedViews: [.sectionHeaders]) {
                ForEach(0..<titles.count, id: \.self) { index in
                    Section(header: Text(" ")
                        .bold()
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ) {
                        ForEach(titles[index], id: \.self) { item in
                            VStack(spacing: 0) {
                                HStack() {
                                    Text(item)
                                        .font(.title3)
                                        .lineLimit(1)
                                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                                    Spacer()
                                    if index == 0 {
                                        Toggle(isOn: $showNotification) {
                                        }
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                                        .frame(width:100)
                                    } else {
                                        NavigationLink(destination: AlbumContentView(secretDirObj: SecretDirObject())) {
                                            EmptyView()
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .frame(height: 55)
                                .background(Color(uiColor: UIColor.tertiarySystemGroupedBackground))
                                
                                Divider().foregroundColor(Color.blue)
                            }.onTapGesture {
                                
                            }
                        }
                    }
                }
                
                Spacer(minLength: 10)
            }
            .padding()
        }
        .background(Color(uiColor: UIColor.systemBackground))
    }
}

struct MeContentView_Previews: PreviewProvider {
    static var previews: some View {
        MeContentView()
    }
}
