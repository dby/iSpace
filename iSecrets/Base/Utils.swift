//
//  Utils.swift
//  iSecrets
//
//  Created by dby on 2023/7/13.
//

import SwiftUI
import Foundation
import CoreImage

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
}
