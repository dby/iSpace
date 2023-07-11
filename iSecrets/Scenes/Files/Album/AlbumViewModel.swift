//
//  AlbumViewModel.swift
//  iSecrets
//
//  Created by dby on 2023/7/9.
//

import Foundation

class AlbumViewModel: ObservableObject {
    @Published var datas: [SecretFileObject] = []
    
    private var dirObj: SecretDirObject
    
    init(dirObj: SecretDirObject) {
        self.dirObj = dirObj
        
        self.fetchFiles()
    }
    
    func fetchFiles() {
        self.fetchFiles { datas in
            self.datas = datas
        }
    }
    
    private func fetchFiles(completion: @escaping ([SecretFileObject]) -> Void) {
        print("xxxx fetch \(dirObj.localID) dirs.")
        completion(
            core.secretDB.getAllSecretFiles(self.dirObj.localID)
        )
    }
}
