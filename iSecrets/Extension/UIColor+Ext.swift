//
//  UIColor+Ext.swift
//  iSecrets
//
//  Created by dby on 2023/8/12.
//

import UIKit

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b: CGFloat
        var a: CGFloat = 1
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            var hexColor = String(hex[start...])
            
            if (hexColor.count != 6 && hexColor.count != 8) {
                return nil
            }
            
            if hexColor.count == 8 {
                let alphaStr = hexColor.suffix(2)
                if let dv = Double(alphaStr){
                    a = CGFloat(dv) / 100.0
                }

                hexColor.removeLast(2)
            }
            
            var hexNumber: UInt64 = 0
            let scanner = Scanner(string: hexColor)
            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff0000) >> 16) / 255.0
                g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255.0
                b = CGFloat((hexNumber & 0x0000ff)) / 255.0

                self.init(red: r, green: g, blue: b, alpha: a)
                return
            }
        }

        return nil
    }
}
