//
//  ContentView.swift
//  iSecrets
//
//  Created by dby on 2023/6/11.
//

import SwiftUI
import AlertToast

struct HomeContentView: View {
    @ObservedObject var coordinator: HomeCoordinator
    @StateObject private var meRouter = MeRouter(isPresented: .constant(.main))
    @StateObject private var meViewModel = MeViewModel()
    
    var body: some View {
        TabView {
            FilesContentView(viewModel: coordinator.filesViewModel)
                .environmentObject(coordinator)
                .tabItem({
                    Image(systemName: "folder.circle.fill")
                    Text("文件夹")
                })
                .background(.red)
            
//            TabView {
//                Text("aaa")
//                Text("bbb")
//                Text("ccc")
//            }
//            .tabItem({
//                Image(systemName: "2.square.fill")
//                Text("我的")
//            })
//            .background(.orange)
//            .tabViewStyle(.page)
//            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            MeContentView(router: meRouter, viewModel: meViewModel)
                .environmentObject(coordinator)
                .tabItem({
                    Image(systemName: "person.circle.fill")
                    Text("我的")
                })
                .tabViewStyle(.page)
        }
        .toast(isPresenting: $coordinator.toastPara.showing) {
            AlertToast(displayMode: .banner(.slide), type: .regular, title: coordinator.toastPara.title)
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeContentView()
//    }
//}
