//
//  Constant.swift
//  iSecrets
//
//  Created by dby on 2023/8/12.
//

import UIKit
import Foundation

public struct iColor {
    public static var primary: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .light {
            return UIColor(hex: "#00000090")!
        } else {
            return UIColor(hex: "#FFFFFF80")!
        }
    }
    
    public static var secondary: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .light {
            return UIColor(hex: "#00000070")!
        } else {
            return UIColor(hex: "#FFFFFF60")!
        }
    }
    
    public static var tertiary: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .light {
            return UIColor(hex: "#00000050")!
        } else {
            return UIColor(hex: "#FFFFFF40")!
        }
    }
    
    public static var last: UIColor = UIColor { trait in
        if trait.userInterfaceStyle == .light {
            return UIColor(hex: "#00000010")!
        } else {
            return UIColor(hex: "#FFFFFF10")!
        }
    }
}
