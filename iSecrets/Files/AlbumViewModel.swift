//
//  AlbumViewModel.swift
//  iSecrets
//
//  Created by dby on 2023/7/3.
//

import SwiftUI

class AlbumViewModel: NSObject, ObservableObject {
    override init() {
        super.init()
        
    }
    
    @Published var datas: [SecretFileObject] = []
}

extension AlbumViewModel {
    func loadDatas(_ atDirObj: SecretDirObject) {
        let objs: [SecretFileObject] = core.secretDB.getAllSecretFiles(atDirObj.localID)
        self.datas = objs
    }
}
