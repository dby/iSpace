//
//  HomeCoordinator.swift
//  iSecrets
//
//  Created by dby on 2023/7/9.
//

import SwiftUI

class HomeCoordinator: ObservableObject {
    
    @Published var filesViewModel: FilesViewModel!
    @Published var toastPara: ToastParas = ToastParas()
    
    private var enterPwdViewModel: EnterPwdViewModel?
    
    init() {
        self.filesViewModel = FilesViewModel()
    }
}

/// Open API
extension HomeCoordinator {
    /// REFRESH DIR
    func refreshDirsIfNeed() {
        self.filesViewModel.refreshSecretDirs()
    }
    
    /// TOAST
    func toast(_ title: String = "") {
        toastPara = ToastParas(showing: true, title: title)
    }
    
    ///
    func makeEnterPwdViewModel() -> EnterPwdViewModel {
        if core.account.0 == .notCreate {
            return EnterPwdViewModel(state: .registerSetpOne)
        } else {
            return EnterPwdViewModel(state: .login)
        }
    }
}
