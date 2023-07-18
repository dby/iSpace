//
//  ViewSpec.swift
//  iSecrets
//
//  Created by dby on 2023/7/19.
//

import Foundation

enum ViewSpec: Equatable, Hashable {
    case main
    case list
    case detail(String)
    case alert
}

extension ViewSpec: Identifiable {
    var id: Self { self }
}
