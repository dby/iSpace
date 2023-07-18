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
    }
}

extension HomeCoordinator {
    
    func openLoginView() {
        self.enterPwdViewModel = EnterPwdViewModel()
        self.enterPwdViewModel?.state = .login
    }
    
    func openRegisterPwdView() {
        
    }
}
