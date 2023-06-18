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

enum AccountState: Int {
    /// 账户尚未创建
    case notCreate
    /// 已经创建账户，但是尚未注册
    case notLogin
    /// 伪装空间账号登录
    case fakeSpace
    /// 主空间登录登录
    case mainSpace
}

class CoreObject: NSObject {
    var curAccount: String? = ""
    
    private var data: SecretDirMapObject = SecretDirMapObject()
    //MARK: -
}

//MARK: - Life Cycle -
extension CoreObject {
    /// 启动
    func startUp() {
        self.loadSecretDirObjectsFromSP()
    }
    
//    func dealloc() {
//
//    }
}

//MARK: - Account -
extension CoreObject {
    
    /// 获得账户的状态
    func getAccountState() -> AccountState {
        if getMainSpaceAccount().count == 0 && getFakeSpaceAccount().count == 0 {
            return .notCreate
        }
        
        if getMainSpaceAccount() == curAccount {
            return .mainSpace
        }
        
        if getFakeSpaceAccount() == curAccount {
            return .fakeSpace
        }
        
        return .notLogin
    }
    
    func saveMainSpaceAccount(_ pwd: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(pwd, forKey: _mainSpacePasswordKey)
        userDefaults.synchronize()
        
        curAccount = pwd
    }
    
    func saveFakeSpaceAccount(_ pwd: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(pwd, forKey: _fakeSpacePasswordKey)
        userDefaults.synchronize()
        
        curAccount = pwd
    }
    
    /// 获得主空间的账户
    private func getMainSpaceAccount() -> String {
        let userDefault = UserDefaults.standard
        return userDefault.string(forKey: _mainSpacePasswordKey) ?? ""
    }
    
    /// 获得伪装空间的账户
    private func getFakeSpaceAccount() -> String {
        let userDefault = UserDefaults.standard
        return userDefault.string(forKey: _fakeSpacePasswordKey) ?? ""
    }
    
    /// 获得某路径下所有文件
    /// - Parameter inDir: 工作路径
    /// - Returns: [WCDBSecretFileObject]
//    func getAllFiles(inDir: String) -> [WCDBSecretFileObject]? {
//        return core.db.getAllObjects(fromWCDBSecretFileTable: inDir) as? [WCDBSecretFileObject]
//    }
}

//MARK: - SecretDir
extension CoreObject {
    func loadSecretDirObjectsFromSP() {
        let userDefaults = UserDefaults.standard
        
        if let data = userDefaults.object(forKey: _secretDirSPKey) as? SecretDirMapObject {
            self.data = data
        } else {
            self.data = SecretDirMapObject()
        }
    }
    
    /// 添加文件记录
    /// - Parameters:å
    ///   - limitionCondition: 文件夹时，可设置上传文件的格式
    ///   - name: 文件名称
    ///   - workingDir: 工作目录
    ///   - fileFormat: 文件格式
    ///   - cipher: 可设置文件密码
    /// - Returns: True/False
    func addOrUpdateSecretFileRecord(limitionCondition: LimitCondition, name: String, workingDir: String, fileFormat: String, cipher: String) -> Bool {
        let key = "\(workingDir)\(name)"
        
        if let item = self.data.dirMap[key] {
            item.fileFormat = fileFormat
            item.cipher = cipher
            item.limitCondition = limitionCondition.rawValue
            item.updateTime = Date.now.timeIntervalSince1970
            syncDirs2SP()
        } else {
            let obj = SecretDirObject(limitCondition: limitionCondition.rawValue,
                                      name: name,
                                      workingDir: workingDir,
                                      fileFormat: fileFormat,
                                      cipher: cipher,
                                      createTime: Date.now.timeIntervalSince1970,
                                      updateTime: Date.now.timeIntervalSince1970)
            self.data.dirMap[key] = obj
            syncDirs2SP()
        }
        
        return false
    }
    
    private func syncDirs2SP() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(self.data, forKey: _secretDirSPKey)
        userDefaults.synchronize()
    }
}
