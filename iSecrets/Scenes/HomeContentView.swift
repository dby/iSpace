//
//  ContentView.swift
//  iSecrets
//
//  Created by dby on 2023/6/11.
//

import SwiftUI

struct HomeContentView: View {
    var body: some View {
        TabView {
            FilesContentView()
            .tabItem({
                Image(systemName: "1.square.fill")
                Text("文件")
            })
            .background(.red)
            .tabViewStyle(.page)
            
            TabView {
                Text("aaa")
                Text("bbb")
                Text("ccc")
            }
            .tabItem({
                Image(systemName: "2.square.fill")
                Text("我的")
            })
            .background(.orange)
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            MeContentView()
            .tabItem({
                Image(systemName: "3.square.fill")
                Text("我的")
            })
            .tabViewStyle(.page)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeContentView()
    }
}