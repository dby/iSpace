//
//  AlertParas.swift
//  iSecrets
//
//  Created by dby on 2023/8/6.
//

import Foundation

class AlertParas: ObservableObject {
    @Published var showing: Bool = false
    @Published var title: String = ""
    @Published var info: String = ""
        
    init() {
        self.showing = false
        self.title = ""
        self.info = ""
    }
    
    init(showing: Bool, title: String, info: String) {
        self.showing = showing
        self.title = title
        self.info = info
    }
}
