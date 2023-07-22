//
//  SecretDB.swift
//  iSecrets
//
//  Created by dby on 2023/7/1.
//

import Foundation
import WCDBSwift

private let SecretDirTableName = "SecretDirTable"
private let SecretFileTableName = "SecretFileTable"

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
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = SecretFileObject
        case localID
        case dirID
        case name
        case fileFormat
        case cipher
        case createTime
        case updateTime
        
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
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //
    private var database: Database?
}

/// SecretDB 增删改查
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
    
    func addSecretFile(dirLocalID: Int, name: String, cipher: String) {
        do {
            let obj = SecretFileObject()
            obj.dirID = dirLocalID
            obj.name = name
            obj.cipher = cipher
            obj.createTime = Date.now.timeIntervalSince1970
            obj.updateTime = Date.now.timeIntervalSince1970
            obj.isAutoIncrement = true
            
            try self.database?.insert([obj], intoTable: SecretFileTableName)
        } catch {
            print(error.localizedDescription)
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
}
