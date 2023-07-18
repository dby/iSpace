//
//  EnterPwdViewModel.swift
//  iSecrets
//
//  Created by dby on 2023/7/18.
//

import Foundation
import SwiftUI

/// 状态机
/// idle --> registerStepOne --> registerStepTwo --> mainSpace
///                                              --> fakeSpace
/// idle  --> mainSpace
///       --> fakeSpace
enum AccountEventState {
    case idle
    case registerSetpOne
    case registerSetpTwo
    case registerSucceed
    case registerFailed
    case login
    case loginSucceed
    case loginFailed
}

class EnterPwdViewModel: ObservableObject {
    @Published var state: AccountEventState = .idle
    
    var inputingPwd: String = ""
    let camera = Camera()
    
    /// 尝试登录
    func tryLoginOrRegister(_ pwd: String) -> Bool {
        switch state {
        case .idle:
            print("should never run here.")
            break
        case .registerSetpOne:
            self.inputingPwd = pwd
            self.state = .registerSetpTwo
        case .registerSetpTwo:
            if (inputingPwd == pwd) {
                core.account = (.mainSpace, pwd)
                self.state = .registerSucceed
            } else {
                self.state = .registerFailed
            }
        case .login:
            if (core.mainSpaceAccount == pwd) {
                core.account = (.mainSpace, pwd)
                self.state = .loginSucceed
            } else if (core.fakeSpaceAccount == pwd) {
                core.account = (.fakeSpace, pwd)
                self.state = .loginSucceed
            } else {
                //登录失败
                camera.takePhoto()
                self.state = .loginFailed
            }
            break
        default:
            print("Not Handle State[\(state)].")
            break
        }
        
        return false
    }
}
