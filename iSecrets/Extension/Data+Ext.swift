//
//  Data+Ext.swift
//  iSecrets
//
//  Created by dby on 2023/7/3.
//

import Foundation
import CryptoKit

extension Data {
    var md5:String {
        let digest = Insecure.MD5.hash(data: self)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
