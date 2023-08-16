//
//  Window+Ext.swift
//  iSecrets
//
//  Created by dby on 2023/8/16.
//

import UIKit

extension UIWindow {
    public var securityBlurEffectView: SecurityBlurEffectView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.windowBlurEffectViewKey) as? SecurityBlurEffectView
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.windowBlurEffectViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func initSecurityBlurEffectViewIfNeed() {
        if (self.securityBlurEffectView == nil) {
            self.securityBlurEffectView = SecurityBlurEffectView()
            self.addSubview(self.securityBlurEffectView!)
            
            self.securityBlurEffectView?.snp.makeConstraints({ make in
                make.edges.equalToSuperview()
            })
        }
    }
}
