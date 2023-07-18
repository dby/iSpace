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
            if description == Constants._intrusionCapture {
                IntrusionRecordView()
                    .ignoresSafeArea()
            } else if description == Constants._fakeSpace {
                
            } else if description == Constants._changePws {
                let curViewModel = EnterPwdViewModel()
                EnterPwdView(viewModel: curViewModel)
            } else if description == Constants._shareToFriends {
                
            } else if description == Constants._aboutUS {
                
            } else if description == Constants._feedback {
                
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
