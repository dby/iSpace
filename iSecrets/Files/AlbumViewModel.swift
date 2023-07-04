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
        DispatchQueue.global().async {
            let objs: [SecretFileObject] = core.secretDB.getAllSecretFiles(atDirObj.localID)
            
            for obj in objs {
                if let rootDir = PathUtils.rootDir() {
                    let fileUrl = URL(filePath: "\(rootDir)/\(atDirObj.name!)/\(obj.name!)")
                    
                    do {
                        let d = try Data(contentsOf: fileUrl)
                        obj.data = d
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.datas = objs
            }
        }
    }
}
