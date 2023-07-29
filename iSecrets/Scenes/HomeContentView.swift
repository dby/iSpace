//
//  ContentView.swift
//  iSecrets
//
//  Created by dby on 2023/6/11.
//

import SwiftUI

struct HomeContentView: View {
    @ObservedObject var coordinator: HomeCoordinator
    @StateObject private var meRouter = MeRouter(isPresented: .constant(.main))
    
    var body: some View {
        TabView {
            FilesContentView(viewModel: coordinator.filesViewModel)
                .environmentObject(coordinator)
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
            
            MeContentView(router: meRouter, viewModel: MeViewModel())
                .environmentObject(coordinator)
                .tabItem({
                    Image(systemName: "3.square.fill")
                    Text("我的")
                })
                .tabViewStyle(.page)
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeContentView()
//    }
//}
