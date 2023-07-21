//
//  HomeCoordinator.swift
//  iSecrets
//
//  Created by dby on 2023/7/9.
//

import SwiftUI

class HomeCoordinator: ObservableObject {
    
    @Published var filesCoordinator: FilesCoordinator!
    @Published var enterPwdViewModel: EnterPwdViewModel?
    
    init() {
        self.filesCoordinator = FilesCoordinator()
        
        if core.account.0 == .notCreate {
            self.enterPwdViewModel = EnterPwdViewModel(state: .registerSetpOne)
        } else {
            self.enterPwdViewModel = EnterPwdViewModel(state: .login)
        }
    }
}

extension HomeCoordinator {
    
    func openLoginView() {
    }
    
    func openRegisterPwdView() {
        
    }
}
