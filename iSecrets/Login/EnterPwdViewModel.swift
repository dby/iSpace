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
//        Task {
//            await camera.start()
//        }
    }

//    private let camera = Camera()
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
                    var accountid = -1
                    if (bModifiedMainSpace) {
                        core.secretDB.registerWithPwd(pwd, level: .mainSpace)
                        core.account = (.mainSpace, core.secretDB.getMainSpaceAccount())
                        accountid = core.account.1?.localID ?? -1
                    } else {
                        core.secretDB.registerWithPwd(pwd, level: .fakeSpace)
                        Settings.isOpenFakeSpace = true
                        accountid = core.secretDB.getFakeSpaceAccountWithPwd(pwd)?.localID ?? -1
                    }
                    self.state = .registerSucceed
                    self.createDefaultDirIfNeed(accountid)
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
                //camera.takePhoto()
                self.prompt = "The password is incorrect, please re-enter".localized()
                self.state = .loginFailed
            }
            break
        default:
            print("Not Handle State[\(state)].")
            break
        }
    }
    
    func createDefaultDirIfNeed(_ accountid: Int) {
        // Create default dirs
        if let path = FileUtils.getDirPath("Videos") {
            _ = FileUtils.createFolder(path)
        }
        if let path = FileUtils.getDirPath("Photos") {
            _ = FileUtils.createFolder(path)
        }
        if let path = FileUtils.getDirPath("Files") {
            _ = FileUtils.createFolder(path)
        }
        
        if accountid == -1 { return }
        
        // Update default dir record.
        if core.secretDB.getAllSecretDirs(accountid).count == 0 {
            //初次登录时，没有文件夹，此时应该添加兜底的目录
            _ = core.secretDB.addOrUpdateSecretDirRecord(accountID: accountid,
                                                         limitionCondition: .video,
                                                         name: FilesConstants.fixDirVideos,
                                                         workingDir: FilesConstants.fixDirVideos.md5,
                                                         cipher: "")
            _ = core.secretDB.addOrUpdateSecretDirRecord(accountID: accountid,
                                                         limitionCondition: .photo,
                                                         name: FilesConstants.fixDirPhotos,
                                                         workingDir: FilesConstants.fixDirPhotos.md5,
                                                         cipher: "")
            _ = core.secretDB.addOrUpdateSecretDirRecord(accountID: accountid,
                                                         limitionCondition: .file,
                                                         name: FilesConstants.fixDirFiles,
                                                         workingDir: FilesConstants.fixDirFiles.md5,
                                                         cipher: "")
        }
    }
}
