//
//  View+Ext.swift
//  iSecrets
//
//  Created by dby on 2023/8/12.
//

import SwiftUI

extension View {
    public func overlayMask<T: View>(_ overlay: T) -> some View {
        self.hidden()
            .overlay(overlay)
            .mask(self)
    }
}
