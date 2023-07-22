//
//  Core.swift
//  iSecrets
//
//  Created by dby on 2023/6/11.
//

import Foundation

let core = CoreObject()

enum AccountState: Int {
    case idle
    /// 未登录
    case notLogin
    /// 未创建
    case notCreate
    /// 伪装空间账号登录
    case fakeSpace
    /// 主空间登录登录
    case mainSpace
}

enum AccountLevel: Int {
    case mainSpace = 1
    case fakeSpace = 2
}

class CoreObject: NSObject {
    override init() {
        super.init()
    }
    
    //MARK: -
    var secretDB: SecretDB!
    var account: (AccountState, String) = (.idle, "")
    private var _mainSpaceAccount: String = ""
    private var _fakeSpaceAccount: [String] = []
    
    //MARK: - Getter and Setter -
    /// 获得主空间的账户
    var mainSpaceAccount: String {
        get {
            if _mainSpaceAccount.isEmpty {
                _mainSpaceAccount = core.secretDB.getMainSpaceAccount()?.name ?? ""
            }
            
            return _mainSpaceAccount
        }
    }
    
    /// 获得伪装空间的账户
    var fakeSpaceAccount: [String] {
        get {
            if _fakeSpaceAccount.isEmpty {
                var tmps: [String] = []
                for item in core.secretDB.getFakeSpaceAccount() {
                    tmps.append(item.name)
                }
                
                _fakeSpaceAccount = tmps
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
        }
    }
    
    func exitMannual() {
        
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
