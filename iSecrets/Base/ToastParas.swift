//
//  File.swift
//  iSecrets
//
//  Created by dby on 2023/7/29.
//

import SwiftUI

class ToastParas: NSObject {
    var showing: Bool = false
    var title: String = ""
    
    override init() {
        super.init()
        
        self.showing = false
        self.title = ""
    }
    
    init(showing: Bool, title: String) {
        self.showing = showing
        self.title = title
    }
}
