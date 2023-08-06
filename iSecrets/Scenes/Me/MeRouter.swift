//
//  MeRouter.swift
//  iSecrets
//
//  Created by dby on 2023/7/19.
//

import SwiftUI

class MeRouter: Router {
    
    func presentList() {
        presentSheet(.list)
    }
    
    func presentDetail(description: String) {
        navigateTo(.detail(description))
    }
    
    func presentAlert() {
        presentModal(.alert)
    }
    
    override func view(spec: ViewSpec, route: Route) -> AnyView {
        AnyView(buildView(spec: spec, route: route))
    }
}

private extension MeRouter {
    
    @ViewBuilder
    func buildView(spec: ViewSpec, route: Route) -> some View {
        switch spec {
        case .list:
            EmptyView()
            //ListView(router: router(route: route))
        case .detail(let description):
            if description == MeConstants._intrusionCapture {
                IntrusionRecordView()
                    .ignoresSafeArea()
            } else if description == MeConstants._fakeSpace {
                GuiseContentView()
                    //.ignoresSafeArea()
            } else if description == MeConstants._changePws {
                let curViewModel = EnterPwdViewModel(state: .registerSetpOne)
                EnterPwdView(viewModel: curViewModel)
                    .ignoresSafeArea()
            } else if description == MeConstants._shareToFriends {
                
            } else if description == MeConstants._aboutUS {
                AboutUsView()
                    .ignoresSafeArea()
            } else if description == MeConstants._feedback {
                
            }
        case .alert:
            EmptyView()
//            AlertView()
        default:
            EmptyView()
        }
    }
            
    func router(route: Route) -> MeRouter {
        switch route {
        case .navigation:
            return self
        case .sheet:
            return MeRouter(isPresented: presentingSheet)
        case .fullScreenCover:
            return MeRouter(isPresented: presentingFullScreen)
        case .modal:
            return self
        }
    }
}
