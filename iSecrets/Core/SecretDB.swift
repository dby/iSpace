//
//  SecretDB.swift
//  iSecrets
//
//  Created by dby on 2023/7/1.
//

import Foundation
import WCDBSwift
import Photos

private let SecretDirTableName = "SecretDirTable"
private let SecretFileTableName = "SecretFileTable"
private let SecretAccountTableName = "SecretAccountTable"

final class SecretAccountObject: TableCodable {
    var localID: Int = 0
    /// 账户名称
    var name: String = ""
    /// 账户级别
    var level: Int = 0
    /// 创建时间
    var createTime: TimeInterval = 0
    /// 更新时间
    var updateTime: TimeInterval = 0
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = SecretAccountObject
        case localID
        case name
        case level
        case createTime
        case updateTime
        
        static let objectRelationalMapping = TableBinding(CodingKeys.self) {
            BindColumnConstraint(localID, isPrimary: true, isAutoIncrement: true)
        }
    }
    
    var isAutoIncrement: Bool = false // 用于定义是否使用自增的方式插入
}

final class SecretDirObject: TableCodable {
    var localID: Int = 0
    /// 是否限制存储文件类型
    var limitCondition: String? = nil
    /// 文件夹名
    var name: String? = nil
    /// 工作路径（相对路径）
    var workingDir: String? = nil
    /// 文件格式，pdf、word、or文件夹
    var fileFormat: String? = nil
    /// 文件加密密码，文件可单独加密，只能输入正确，才能查看/
    var cipher: String? = nil
    /// 封面
    var thumb: String? = nil
    /// 用户自定义的封面
    var customizeCover: String? = nil
    /// 创建时间
    var createTime: TimeInterval = 0
    /// 更新时间
    var updateTime: TimeInterval = 0
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = SecretDirObject
        case localID
        case limitCondition
        case name
        case workingDir
        case fileFormat
        case cipher
        case thumb
        case customizeCover
        case createTime
        case updateTime
        
        static let objectRelationalMapping = TableBinding(CodingKeys.self) {
            BindColumnConstraint(localID, isPrimary: true, isAutoIncrement: true)
        }
    }
    
    var isAutoIncrement: Bool = false // 用于定义是否使用自增的方式插入
}

final class SecretFileObject: TableCodable {
    var localID: Int = 0
    /// 文件夹ID
    var dirID: Int = 0
    /// 文件名
    var name: String? = nil
    /// 文件格式，pdf、word、or文件夹
    var fileFormat: String? = nil
    /// 文件加密密码，文件可单独加密，只能输入正确，才能查看/
    var cipher: String? = nil
    /// 创建时间
    var createTime: TimeInterval = 0
    /// 更新时间
    var updateTime: TimeInterval = 0
    /// 同PHAsset.mediaType
    var mediaType: Int = 0
    /// 同PHAsset.pixelWidth
    var pixelWidth: Int = 0
    /// 同PHAsset.pixelHeight
    var pixelHeight: Int = 0
    /// 同PHAsset.duration
    var duration: TimeInterval = 0
    /// 同PHAsset.itemIdentifier
    var itemIdentifier: String = ""
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = SecretFileObject
        case localID
        case dirID
        case name
        case fileFormat
        case cipher
        case createTime
        case updateTime
        case mediaType
        case pixelWidth
        case pixelHeight
        case duration
        case itemIdentifier

        static let objectRelationalMapping = TableBinding(CodingKeys.self) {
            BindColumnConstraint(localID, isPrimary: true, isAutoIncrement: true)
        }
    }
    
    var isAutoIncrement: Bool = false // 用于定义是否使用自增的方式插入
}

class SecretDB: NSObject {
    override init() {
        super.init()
        
        database = Database(at: dbPath())
        database?.tag = Tag("iSecret")
        
        do {
            try database?.create(table: SecretDirTableName, of: SecretDirObject.self)
            try database?.create(table: SecretFileTableName, of: SecretFileObject.self)
            try database?.create(table: SecretAccountTableName, of: SecretAccountObject.self)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //
    private var database: Database?
}

/// SecretAccountObject
extension SecretDB {
    func getMainSpaceAccount() -> SecretAccountObject? {
        var accounts: [SecretAccountObject] = []
        do {
            if let db = self.database {
                accounts = try db.getObjects(on: SecretAccountObject.Properties.all,
                                             fromTable: SecretAccountTableName,
                                             where: SecretAccountObject.Properties.level == AccountLevel.mainSpace.rawValue)
            }
        } catch {
            
        }
        
        return accounts.count == 0 ? nil : accounts.first
    }
    
    func getFakeSpaceAccount() -> [SecretAccountObject] {
        var accounts: [SecretAccountObject] = []
        do {
            if let db = self.database {
                accounts = try db.getObjects(on: SecretAccountObject.Properties.all,
                                             fromTable: SecretAccountTableName,
                                             where: SecretAccountObject.Properties.level == AccountLevel.fakeSpace.rawValue)
            }
        } catch {
            
        }
        
        return accounts
    }

    func registerWithUsrName(_ usrName: String, level: AccountLevel) {
        guard !usrName.isEmpty else { return }
        do {
            try self.database?.run(transaction: { handle in
                let existObjs: [SecretAccountObject] = try handle.getObjects(on: SecretAccountObject.Properties.all,
                                                                             fromTable: SecretAccountTableName,
                                                                             where: SecretAccountObject.Properties.name == usrName)
                if (existObjs.count > 0) {
                    assert(true)
                    // name必须是唯一的
                    return
                }
                
                if level == .mainSpace {
                    let mainSpaceAccounts: [SecretAccountObject] = try handle.getObjects(on: SecretAccountObject.Properties.all,
                                                                                         fromTable: SecretAccountTableName,
                                                                                         where: SecretAccountObject.Properties.level == AccountLevel.mainSpace.rawValue)
                    if (mainSpaceAccounts.count > 0) {
                        assert(true)
                        // MainSpace 账户只能有一个
                        return
                    }
                }
                
                let obj = SecretAccountObject()
                obj.name = usrName
                obj.level = level.rawValue
                obj.createTime = Date.now.timeIntervalSince1970
                obj.updateTime = Date.now.timeIntervalSince1970
                obj.isAutoIncrement = true
                
                try handle.insertOrIgnore([obj], intoTable: SecretAccountTableName)
            })
        } catch {
            print("Transaction failed with error: \(error)")
        }
    }
}

/// SecretDirObject
extension SecretDB {
    func runTransaction(_ transaction: @escaping Database.TransactionClosure) {
        do {
            try self.database?.run(transaction: transaction)
        } catch {
            print("Transaction failed with error: \(error)")
        }
    }
    
    /// 添加文件夹📂记录
    /// - Parameters:
    ///   - limitionCondition: 文件夹时，可设置上传文件的格式
    ///   - name: 文件名称
    ///   - workingDir: 工作目录
    ///   - fileFormat: 文件格式
    ///   - cipher: 可设置文件密码
    /// - Returns: True/False
    func addOrUpdateSecretDirRecord(limitionCondition: LimitCondition, name: String, workingDir: String, fileFormat: String, cipher: String) -> Bool {
        var flag = false
        do {
            try self.database?.run(transaction: { handle in
                let existObjs: [SecretDirObject] = try handle.getObjects(on: [SecretDirObject.Properties.workingDir],
                                                                         fromTable: SecretDirTableName,
                                                                         where: SecretDirObject.Properties.workingDir == workingDir && SecretDirObject.Properties.name == name)
                if existObjs.isEmpty {
                    let obj = SecretDirObject()
                    obj.limitCondition = limitionCondition.rawValue
                    obj.name = name
                    obj.workingDir = workingDir
                    obj.fileFormat = fileFormat
                    obj.cipher = cipher
                    obj.thumb = "" //封面暂时填空
                    obj.customizeCover = "" //自定义封面暂时填空
                    obj.createTime = Date.now.timeIntervalSince1970
                    obj.updateTime = Date.now.timeIntervalSince1970
                    obj.isAutoIncrement = true
                    
                    try handle.insertOrIgnore([obj], intoTable: SecretDirTableName)
                    
                    flag = true
                }
            })
        } catch {
            print("Transaction failed with error: \(error)")
        }
        
        return flag
    }
    
    func deleteSecretDirRecord(localID: Int) {
        if let db = self.database {
            do {
                try db.delete(fromTable: SecretDirTableName, where: SecretDirObject.Properties.localID == localID)
            } catch {
                print("delete failed. \(error.localizedDescription)")
            }
        }
    }
    
    /// 更新 DIR 名称
    func updateDirName(dirID: Int, dirName: String) {
        do {
            let obj = SecretDirObject()
            obj.name = dirName
            
            try database?.update(table: SecretDirTableName,
                                 on: [SecretDirObject.Properties.name],
                                 with: obj,
                                 where: SecretDirObject.Properties.localID == dirID)
        } catch {
            
        }
    }
    
    /// 更新 DIR 缩略图
    func updateDirThumb(dirID: Int, thumb: String) {
        do {
            let obj = SecretDirObject()
            obj.thumb = thumb
            
            try database?.update(table: SecretDirTableName,
                                 on: [SecretDirObject.Properties.thumb],
                                 with: obj,
                                 where: SecretDirObject.Properties.localID == dirID)
        } catch {
            
        }
    }
    
    /// 更新自定义封面
    func updateDirCustomizeCover(dirID: Int, cover: String) {
        do {
            let obj = SecretDirObject()
            obj.customizeCover = cover
            
            try database?.update(table: SecretDirTableName,
                                 on: [SecretDirObject.Properties.customizeCover],
                                 with: obj,
                                 where: SecretDirObject.Properties.localID == dirID)
        } catch {
            
        }
    }
    
    func updateDirCipher(dirID: Int, cipher: String) {
        do {
            let obj = SecretDirObject()
            obj.cipher = cipher
            
            try database?.update(table: SecretDirTableName,
                                 on: [SecretDirObject.Properties.cipher],
                                 with: obj,
                                 where: SecretDirObject.Properties.localID == dirID)
        } catch {
            
        }

    }
    
    func getAllSecretDirs() -> [SecretDirObject] {
        do {
            if let db = self.database {
                let allObjects: [SecretDirObject] = try db.getObjects(on: SecretDirObject.Properties.all,
                                                                      fromTable: SecretDirTableName)
                return allObjects
            }
        } catch {
            
        }
        
        return []
    }
    
    func getSecretFileCnt(_ atDirID: Int) -> Int {
        do {
            if let db = self.database {
                let files: [SecretFileObject] = try db.getObjects(on: SecretFileObject.Properties.all,
                                                                  fromTable: SecretFileTableName,
                                                                  where: SecretFileObject.Properties.dirID == atDirID)
                return files.count
            }
        } catch {
            
        }
        
        return 0
    }
}

/// SecretFileObject
extension SecretDB {
    func addSecretFile(dirLocalID: Int, name: String, cipher: String, asset: PHAsset) {
        do {
            let obj = SecretFileObject()
            obj.dirID = dirLocalID
            obj.name = name
            obj.cipher = cipher
            obj.createTime = Date.now.timeIntervalSince1970
            obj.updateTime = Date.now.timeIntervalSince1970
            obj.mediaType = asset.mediaType.rawValue
            obj.pixelWidth = asset.pixelWidth
            obj.pixelHeight = asset.pixelHeight
            obj.duration = asset.duration
            obj.itemIdentifier = asset.localIdentifier
            
            obj.isAutoIncrement = true
            
            try self.database?.insert([obj], intoTable: SecretFileTableName)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getAllSecretFiles(_ atDirID: Int) -> [SecretFileObject] {
        do {
            if let db = self.database {
                let allObjs: [SecretFileObject] = try db.getObjects(on: SecretFileObject.Properties.all,
                                                                    fromTable: SecretFileTableName,
                                                                    where: SecretFileObject.Properties.dirID == atDirID)
                return allObjs
            }
        } catch {
            
        }
        
        return []
    }
    
    func deleteSecretFileRecord(localID: Int) {
        if let db = self.database {
            do {
                try db.delete(fromTable: SecretFileTableName, where: SecretFileObject.Properties.localID == localID)
            } catch {
                print("delete file failed. \(error.localizedDescription)")
            }
        }
    }
}
