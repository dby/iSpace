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
enum AccountEventState: Int {
    case idle
    /// register flow
    case registerSetpOne
    case registerSetpTwo
    case registerSucceed
    case registerFailed
    /// change pwd flow
    case chgPwdStepOne
    case chgPwdStepTwo
    case chgPwdSucceed
    case chgPwdFailed
    /// login flow
    case login
    case loginSucceed
    case loginFailed
}

class EnterPwdViewModel: ObservableObject {
    @Published var state: AccountEventState = .idle
    
    init(state: AccountEventState) {
        self.state = state
        Task {
            await camera.start()
        }
    }
    
    var inputingPwd: String = ""
    let camera = Camera()
    
    /// 尝试登录
    func tryLoginOrRegister(_ pwd: String) {
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
                core.secretDB.registerWithUsrName(pwd, level: .mainSpace)
                
                self.state = .registerSucceed
                self.createDefaultDirIfNeed()
            } else {
                self.state = .registerFailed
            }
        case .chgPwdStepOne:
            self.inputingPwd = pwd
            self.state = .chgPwdStepTwo
        case .chgPwdStepTwo:
            if (inputingPwd == pwd) {
                core.secretDB.chtPwd(pwd, oldPwd: core.account.1)
                core.account = (.mainSpace, pwd)
                
                self.state = .chgPwdSucceed
            } else {
                self.state = .chgPwdFailed
            }
        case .login:
            if (core.mainSpaceAccount == pwd) {
                core.account = (.mainSpace, pwd)
                self.state = .loginSucceed
            } else if (core.fakeSpaceAccount.contains(pwd)) {
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
    }
    
    func createDefaultDirIfNeed() {
        if let rootPath = PathUtils.rootDir() {
            _ = FileUtils.createFolder("\(rootPath)/Videos")
            _ = FileUtils.createFolder("\(rootPath)/Photos")
            _ = FileUtils.createFolder("\(rootPath)/Files")
        }
    }
}
