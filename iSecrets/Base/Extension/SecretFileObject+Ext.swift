//
//  SecretFileObject+Ext.swift
//  iSecrets
//
//  Created by dby on 2023/7/4.
//

import Foundation

struct AssociatedKeys {
    static var secretFileDataKey: String = "secretFileDataKeyName"
}

extension SecretFileObject {
    public var data: Data? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.secretFileDataKey) as? Data
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.secretFileDataKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
