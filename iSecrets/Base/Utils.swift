//
//  Utils.swift
//  iSecrets
//
//  Created by dby on 2023/7/13.
//

import SwiftUI
import Foundation
import CoreImage

let FILESIZE_1M: Double = 1 * 1024 * 1024
let FILESIZE_1G: Double = 1 * 1024 * 1024 * 1024
let FILESIZE_10G: Double = 10 * 1024 * 1024 * 1024
let FILESIZE_100G: Double = 100 * 1024 * 1024 * 1024
let FILESIZE_1T: Double = 1 * 1024 * 1024 * 1024 * 1024

/// 生成缩略图
@inlinable func genThumbnail(for imgData: Data, thumbnailSize: CGSize) -> Data? {
    guard let image = UIImage(data: imgData) else { return nil }
    
    let imageSize = image.size
    let cropRect = CGRect(x: (imageSize.width - thumbnailSize.width) / 2,
                          y: (imageSize.height - thumbnailSize.height) / 2,
                          width: thumbnailSize.width,
                          height: thumbnailSize.height)
    
    if
        let croppedCIImage = CIImage(image: image)?.cropped(to: cropRect),
        let scaleFilter = CIFilter(name: "CILanczosScaleTransform")
    {
        scaleFilter.setValue(croppedCIImage, forKey: kCIInputImageKey)
        scaleFilter.setValue(0.1, forKey: kCIInputScaleKey)
        
        if let scaledImage = scaleFilter.outputImage,
           let pngData = CIContext().pngRepresentation(of: scaledImage,
                                                       format: .RGBA8,
                                                       colorSpace: croppedCIImage.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
                                                       options: [:]) {
            return pngData
        }
    }
    
    return nil
}

@inlinable func genThumbnailAspectFill(for imgData: Data) -> Data? {
    guard let image = UIImage(data: imgData) else { return nil }
    
    let imageSize = image.size
    let targetW = min(imageSize.width, imageSize.height)
    
    return genThumbnail(for: imgData, thumbnailSize: CGSizeMake(targetW, targetW))
}

@inlinable func formatSeconds(for sec: TimeInterval) -> String {
    let formatter = DateFormatter()
    
    if (sec > 3600) {
        formatter.dateFormat = "HH:mm:ss"
    } else {
        formatter.dateFormat = "mm:ss"
    }
    
    return formatter.string(from: Date(timeIntervalSince1970: sec))
}

class Utils: NSObject {
    /**
     生成随机字符串,
     - parameter length: 生成的字符串的长度
     - returns: 随机生成的字符串
     */
    class func randomStrOfLen(_ length: Int) -> String {
        var ranStr = ""
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(characters.count)))
            ranStr.append(characters[index])
        }
        
        return ranStr
    }
    
    class func goodFormatSizeStr(_ usage: Double) -> String {
        if usage >= FILESIZE_1G {
            // 大于1G
            return String(format: "%.1fGB", usage/FILESIZE_1G)
        } else if usage >= 1 * 1024 * 1024 {
            // 大于1M
            return String(format: "%.1fMB", usage/FILESIZE_1M)
        } else if usage >= 1 * 1024 {
            // 大于1KB
            return String(format: "%.1fKB", usage/1*1024)
        } else {
            return String(format: "%dB", Int(usage))
        }
    }
}
