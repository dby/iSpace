//
//  FilesContentView.swift
//  iSecrets
//
//  Created by dby on 2023/6/11.
//

import SwiftUI

struct FilesContentView: View {
    
    let twoGridLayout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    let datas = ["图片", "视频", "文件", "文件1", "文件2", "文件3"]
    let headerWid = UIScreen.main.bounds.size.width - 60

    @State private var showingAlert = false
    @State private var name = ""
    @State private var presetnKey = false
    @State private var pushKey = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Spacer()
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(datas, id: \.self) { item in
                            Text(item)
                                .frame(width: headerWid/2, height: headerWid/2)
                                .background(.cyan)
                                .cornerRadius(5)
                                .onTapGesture {
                                    print("1111 \(item)")
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
                            
                        }
                    }
                }
            })
            .fullScreenCover(isPresented: $presetnKey, content: {
                AlbumContentView()
            })
            .navigationDestination(isPresented: $pushKey, destination: {
                AlbumContentView()
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
