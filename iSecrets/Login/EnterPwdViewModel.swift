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
    
    init(state: AccountEventState, modifiedMainSpace: Bool = true) {
        self.state = state
        self.bModifiedMainSpace = modifiedMainSpace
        Task {
            await camera.start()
        }
    }

    private let camera = Camera()
    /// 错误提示信息
    var prompt: String = ""
    /// 注册/修改密码时，第一步时输入的密码
    private var inputingPwd: String = ""
    /// 是否设置主空间
    private var bModifiedMainSpace: Bool = false
    
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
                if core.secretDB.isExistPwd(pwd) {
                    //pwd必须要保证唯一，因为需要弹窗提示
                    self.prompt = "The password has already been set".localized()
                    self.state = .registerFailed
                } else {
                    if (bModifiedMainSpace) {
                        core.secretDB.registerWithUsrName(pwd, level: .mainSpace)
                        core.account = (.mainSpace, core.secretDB.getMainSpaceAccount())
                    } else {
                        core.secretDB.registerWithUsrName(pwd, level: .fakeSpace)
                        Settings.isOpenFakeSpace = true
                    }
                    self.state = .registerSucceed
                    self.createDefaultDirIfNeed()
                }
            } else {
                self.prompt = "The two entries are inconsistent, please re-enter".localized()
                self.state = .registerFailed
            }
        case .chgPwdStepOne:
            self.inputingPwd = pwd
            self.state = .chgPwdStepTwo
        case .chgPwdStepTwo:
            if (inputingPwd == pwd) {
                if core.secretDB.isExistPwd(pwd) {
                    //pwd必须要保证唯一，因为需要弹窗提示
                    self.prompt = "The password has already been set".localized()
                    self.state = .chgPwdFailed
                } else {
                    guard let oldPwd = core.account.1?.pwd else { return }
                    core.secretDB.chtPwd(pwd, oldPwd: oldPwd)
                    core.account = (.mainSpace, core.secretDB.getMainSpaceAccount())
                    
                    self.state = .chgPwdSucceed
                }
            } else {
                self.prompt = "The two entries are inconsistent, please re-enter".localized()
                self.state = .chgPwdFailed
            }
        case .login:
            if (core.mainSpaceAccount == pwd) {
                core.account = (.mainSpace, core.secretDB.getMainSpaceAccount())
                self.state = .loginSucceed
            } else if (core.fakeSpaceAccount.contains(pwd)) {
                core.account = (.fakeSpace, core.secretDB.getFakeSpaceAccountWithPwd(pwd))
                self.state = .loginSucceed
            } else {
                //登录失败
                camera.takePhoto()
                self.prompt = "The password is incorrect, please re-enter".localized()
                self.state = .loginFailed
            }
            break
        default:
            print("Not Handle State[\(state)].")
            break
        }
    }
    
    func createDefaultDirIfNeed() {
        // Create default dirs
        if let rootPath = PathUtils.rootDir() {
            _ = FileUtils.createFolder("\(rootPath)/Videos")
            _ = FileUtils.createFolder("\(rootPath)/Photos")
            _ = FileUtils.createFolder("\(rootPath)/Files")
        }
        
        // Update default dir record.
        guard let accountID = core.account.1?.localID else { return }
        if core.secretDB.getAllSecretDirs(accountID).count == 0 {
            //初次登录时，没有文件夹，此时应该添加兜底的目录
            _ = core.secretDB.addOrUpdateSecretDirRecord(accountID: accountID,
                                                         limitionCondition: .video,
                                                         name: "Videos",
                                                         workingDir: "Videos".md5,
                                                         fileFormat: "video",
                                                         cipher: "")
            _ = core.secretDB.addOrUpdateSecretDirRecord(accountID: accountID,
                                                         limitionCondition: .photo,
                                                         name: "Photos",
                                                         workingDir: "Photos".md5,
                                                         fileFormat: "photo",
                                                         cipher: "")
            _ = core.secretDB.addOrUpdateSecretDirRecord(accountID: accountID,
                                                         limitionCondition: .file,
                                                         name: "Files",
                                                         workingDir: "Files".md5,
                                                         fileFormat: "file",
                                                         cipher: "")
        }
    }
}
