//
//  HomeCoordinator.swift
//  iSecrets
//
//  Created by dby on 2023/7/9.
//

import SwiftUI

class HomeCoordinator: ObservableObject {
    
    @Published var filesViewModel: FilesViewModel!
    @Published var enterPwdViewModel: EnterPwdViewModel?
    @Published var toastPara: ToastParas = ToastParas()
    
    init() {
        self.filesViewModel = FilesViewModel()
        
        if core.account.0 == .notCreate {
            self.enterPwdViewModel = EnterPwdViewModel(state: .registerSetpOne)
        } else {
            self.enterPwdViewModel = EnterPwdViewModel(state: .login)
        }
    }
    
    func toast(showing: Bool, title: String = "") {
        toastPara = ToastParas(showing: showing, title: title)
    }
}

extension HomeCoordinator {
    
    func openLoginView() {
    }
    
    func openRegisterPwdView() {
        
    }
}
