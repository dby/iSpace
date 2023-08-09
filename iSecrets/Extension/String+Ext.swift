//
//  String+Ext.swift
//  iSecrets
//
//  Created by dby on 2023/6/12.
//

import UIKit
import CommonCrypto
import CryptoKit

extension String {
    var sha256: String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(utf8, CC_LONG(utf8!.count - 1), &digest)
        
        return digest.reduce("") { $0 + String(format:"%02x", $1) }
    }
    
    var md5: String {
        let digest = Insecure.MD5.hash(data: data(using: .utf8) ?? Data())

        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
    
    public func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        #if DEBUG
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
        #else
        return NSLocalizedString(self, tableName: tableName, value: "\(self)", comment: "")
        #endif
    }
}
