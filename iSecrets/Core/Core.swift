//
//  Core.swift
//  iSecrets
//
//  Created by dby on 2023/6/11.
//

import Foundation

let core = CoreObject()
private let _mainSpacePasswordKey = "main_Space_Password_Key"
private let _fakeSpacePasswordKey = "fake_Space_Password_Key"
private let _secretDirSPKey = "Secret_Dir_SP_Key"

/// 状态机
/// notCreate --> registerStepOne --> registerStepTwo --> mainSpace
///                                      --> fakeSpace
/// notLogin  --> mainSpace
///        --> fakeSpace
enum AccountState: Int {
    /// 账户尚未创建
    case notCreate
    /// 注册流程One
    case registerSetpOne
    /// 注册流程Two
    case registerSetpTwo
    /// 已经创建账户，但是尚未注册
    case notLogin
    /// 伪装空间账号登录
    case fakeSpace
    /// 主空间登录登录
    case mainSpace
}

class CoreObject: NSObject {
    override init() {
        super.init()
    }
    
    //MARK: -
    var secretDB: SecretDB!
    var account: (AccountState, String) = (.notCreate, "")
    private var _mainSpaceAccount: String = ""
    private var _fakeSpaceAccount: String = ""
    
    //MARK: - Getter and Setter -
    /// 获得主空间的账户
    var mainSpaceAccount: String {
        get {
            if _mainSpaceAccount.isEmpty {
                let userDefault = UserDefaults.standard
                _mainSpaceAccount = userDefault.string(forKey: _mainSpacePasswordKey) ?? ""
            }
            
            return _mainSpaceAccount
        }
    }
    
    /// 获得伪装空间的账户
    var fakeSpaceAccount: String {
        get {
            if _fakeSpaceAccount.isEmpty {
                let userDefault = UserDefaults.standard
                _fakeSpaceAccount = userDefault.string(forKey: _fakeSpacePasswordKey) ?? ""
            }
            
            return _fakeSpaceAccount
        }
    }
}

//MARK: - Life Cycle -
extension CoreObject {
    /// 启动
    func startUp() {
        self.secretDB = SecretDB()
        
        if let rootDir = PathUtils.rootDir() {
            print("RootDir[\(rootDir)]")
            print("SubPath: \(FileUtils.subPathsAtPath(rootDir))")
        }
        
        if self.fakeSpaceAccount.isEmpty && self.mainSpaceAccount.isEmpty {
            self.account = (.notCreate, "")
        } else {
            self.account = (.notLogin, "")
        }
        
        if self.secretDB.getAllSecretDirs().count == 0 {
            //初次登录时，没有文件夹，此时应该添加兜底的目录
            _ = self.secretDB.addOrUpdateSecretDirRecord(limitionCondition: .video,
                                                         name: "Videos",
                                                         workingDir: "Videos".md5,
                                                         fileFormat: "video",
                                                         cipher: "")
            _ = self.secretDB.addOrUpdateSecretDirRecord(limitionCondition: .photo,
                                                         name: "Photos",
                                                         workingDir: "Photos".md5,
                                                         fileFormat: "photo",
                                                         cipher: "")
            _ = self.secretDB.addOrUpdateSecretDirRecord(limitionCondition: .file,
                                                         name: "Files",
                                                         workingDir: "Files".md5,
                                                         fileFormat: "file",
                                                         cipher: "")
            
            if let rootPath = PathUtils.rootDir() {
                _ = FileUtils.createFolder("\(rootPath)/Videos")
                _ = FileUtils.createFolder("\(rootPath)/Photos")
                _ = FileUtils.createFolder("\(rootPath)/Files")
            }
        }
    }
    
    func exitMannual() {
        
    }
}

//MARK: - Account -
extension CoreObject {
    func saveMainSpaceAccount(_ pwd: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(pwd, forKey: _mainSpacePasswordKey)
        userDefaults.synchronize()
        
        self.account = (.mainSpace, pwd)
    }
    
    func saveFakeSpaceAccount(_ pwd: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(pwd, forKey: _fakeSpacePasswordKey)
        userDefaults.synchronize()
        
        self.account = (.fakeSpace, pwd)
    }
}

//MARK: - SecretDir
extension CoreObject {
    /// 获得当前所有的文件夹
    func getAllSecretDirs() -> [SecretDirObject] {
        return self.secretDB.getAllSecretDirs()
    }
}

//MARK: - SecretFile
