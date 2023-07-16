//
//  HomeCoordinator.swift
//  iSecrets
//
//  Created by dby on 2023/7/9.
//

import SwiftUI

class HomeCoordinator: ObservableObject {
    
    @Published var filesCoordinator: FilesCoordinator!
    
    let camera = Camera()
    
    init() {
        self.filesCoordinator = FilesCoordinator()
    }
}

extension HomeCoordinator {
    /// 尝试登录
    func tryLoginOrRegister(_ pwd: String) -> Bool {
        switch core.account.0 {
        case .notCreate:
            core.account = (.registerSetpOne, pwd)
        case .registerSetpOne:
            core.account = (.registerSetpTwo, pwd)
        case .registerSetpTwo:
            guard core.account.0 == .registerSetpOne else {
                core.account = (.notCreate, "")
                return false
            }
            
            if (core.account.1 == pwd) {
                //注册成功
                core.account = (.mainSpace, pwd)
            }
        case .notLogin:
            if (core.mainSpaceAccount == pwd) {
                core.account = (.mainSpace, pwd)
            } else if (core.fakeSpaceAccount == pwd) {
                core.account = (.fakeSpace, pwd)
            } else {
                //登录失败
                camera.takePhoto()
            }
            break
        default:
            break
        }
        
        return false
    }
}
