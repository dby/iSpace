//
//  HomeCoordinator.swift
//  iSecrets
//
//  Created by dby on 2023/7/9.
//

import SwiftUI

class HomeCoordinator: ObservableObject {
    
    @Published var filesCoordinator: FilesCoordinator!
    
    let camera = Camera()
    
    init() {
        self.filesCoordinator = FilesCoordinator()
    }
}
