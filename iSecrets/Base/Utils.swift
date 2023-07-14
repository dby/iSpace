//
//  Utils.swift
//  iSecrets
//
//  Created by dby on 2023/7/13.
//

import UIKit
import Foundation

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
        let pngData = CIContext().pngRepresentation(of: croppedCIImage, format: .RGBA8, colorSpace: croppedCIImage.colorSpace ?? CGColorSpaceCreateDeviceRGB(), options: [:])
    {
        return pngData
    }
    
    return nil
}
