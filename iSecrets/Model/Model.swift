//
//  Model.swift
//  iSecrets
//
//  Created by dby on 2023/6/12.
//

import Foundation

// 照片、视频、语音、文件
enum LimitCondition: String {
    case video = "video" //视频
    case audio = "audio" //音频
    case photo = "photo" //相册
    case file = "file" //文件
    case album = "album" //相册、视频、音频
    case all = "all" //不限制文件格式
    case ignore = "-" //此时，忽略该字段
}
//
//class SecretDirMapObject: NSObject {
//    /// 目录
//    var dirMap:[String: SecretDirObject] = [:]
//}
//
///// 工作路径/文件名 为唯一标识
//class SecretDirObject: NSObject {
//    /// 是否限制存储文件类型
//    var limitCondition: String!
//    /// 文件夹名
//    var name: String!
//    /// 工作路径
//    var workingDir: String!
//    /// 文件格式，pdf、word、or文件夹
//    var fileFormat: String!
//    /// 文件加密密码，文件可单独加密，只能输入正确，才能查看/
//    var cipher: String!
//    /// 创建时间
//    var createTime: Double = 0
//    /// 更新时间
//    var updateTime: Double = 0
//
//    init(limitCondition: String!, name: String!, workingDir: String!, fileFormat: String!, cipher: String!, createTime: Double, updateTime: Double) {
//        self.limitCondition = limitCondition
//        self.name = name
//        self.workingDir = workingDir
//        self.fileFormat = fileFormat
//        self.cipher = cipher
//        self.createTime = createTime
//        self.updateTime = updateTime
//    }
//}
