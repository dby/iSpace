//
//  Model.swift
//  iSecrets
//
//  Created by dby on 2023/6/12.
//

import Foundation

enum DataCategory: String {
    /// 视频
    case video = "video"
    /// 照片
    case photo = "photo"
    /// 音频
    case audio = "audio"
    /// 文件
    case file = "file"
    /// 文件/视频/照片
    case all = "all"
}

///附件后缀名
enum MediaSuffix: String {
    /// 照片
    case pic = "pic"
    /// 视频
    case mp4 = "mp4"
    /// 图片缩略图
    case picThumb = "pic_thumb"
    /// 视频缩略图
    case videoThumb = "video_thumb"
}
