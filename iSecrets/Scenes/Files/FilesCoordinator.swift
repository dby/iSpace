//
//  FilesCoordinator.swift
//  iSecrets
//
//  Created by dby on 2023/7/9.
//

import Foundation

extension SecretDirObject {
    public var viewmodel: AlbumViewModel? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.secretDirDataKey) as? AlbumViewModel
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.secretDirDataKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var fileCnt: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.secretDirFilesCntKey) as? Int ?? 0
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.secretDirFilesCntKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


class FilesCoordinator: ObservableObject {
    @Published var dirs: [SecretDirObject]!
    @Published var detailViewModel: AlbumViewModel?
    
    init() {
        refreshSecretDirs()
    }
    
    func refreshSecretDirs() {
        dirs = []
        for item in core.getAllSecretDirs() {
            item.viewmodel = AlbumViewModel(dirObj: item)
            item.fileCnt = core.secretDB.getSecretFileCnt(item.localID)
            dirs.append(item)
        }
    }
}
