//
//  Settings.swift
//  iSecrets
//
//  Created by dby on 2023/7/30.
//

import SwiftUI

class Settings: NSObject {
    static var isDeleteOrigFile: Bool {
        get {
            return UserDefaults.standard.bool(forKey: MeConstants._isDeleteOrigFileKey)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: MeConstants._isDeleteOrigFileKey)
        }
    }
}

