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
        
    var length: Int {
        return count
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
