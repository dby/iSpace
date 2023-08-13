//
//  FilesCoordinator.swift
//  iSecrets
//
//  Created by dby on 2023/7/9.
//

import Foundation

struct FilesConstants {
    static let fixDirVideos: String = "Videos"
    static let fixDirPhotos: String = "Photos"
    static let fixDirFiles: String = "Files"
    
    static let menuAdd: String = "Add".localized()
    static let menuLock: String = "Lock folder".localized()
    static let menuUnLock: String = "Cancel the lock".localized()
    static let menuRenameDir: String = "Re -name folder".localized()
    static let menuDeleteDir: String = "Delete the folder".localized()
}

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


class FilesViewModel: ObservableObject {
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
    
    private func isFixedDir(_ dirName: String?) -> Bool {
        guard let dirName = dirName else { return false }
        return (dirName == FilesConstants.fixDirFiles || dirName == FilesConstants.fixDirPhotos || dirName == FilesConstants.fixDirVideos)
    }
    
    func menuTitles(_ dirObj: SecretDirObject) -> [(String, String)] {
        var titles: [(String, String)] = []
        if (core.secretDB.getSecretFileCnt(dirObj.localID) != 0) {
            titles.append((FilesConstants.menuAdd, "plus"))
            titles.append(dirObj.cipher == "" ? (FilesConstants.menuLock, "lock") : (FilesConstants.menuUnLock, "lock.open"))
        }
        
        if (!isFixedDir(dirObj.name)) {
            titles.append((FilesConstants.menuRenameDir, "pencil"))
            titles.append((FilesConstants.menuDeleteDir, "trash"))
        }
        
        return titles
    }
    
    func contextMenuDidClicked(_ title: String, dirObj: SecretDirObject) {
        switch title {
        case FilesConstants.menuAdd:
            break
        case FilesConstants.menuLock:
            core.secretDB.updateDirCipher(dirID: dirObj.localID,
                                          cipher: core.account.1?.pwd ?? "")
            refreshSecretDirs()
        case FilesConstants.menuUnLock:
            core.secretDB.updateDirCipher(dirID: dirObj.localID,
                                          cipher: "")
            refreshSecretDirs()
        case FilesConstants.menuDeleteDir:
            let dirPath = "\(basePath())/\(dirObj.name!)"
            FileUtils.removeAllItems(atDirPath: dirPath)
            core.secretDB.deleteSecretDirRecord(localID: dirObj.localID)
            refreshSecretDirs()
        case FilesConstants.menuRenameDir:
            break
        default:
            break
        }
    }
    
    func createNewDirWithName(_ name: String) {
        guard let accoutid = core.account.1?.localID else { return }
        if (core.secretDB.addOrUpdateSecretDirRecord(accountID: accoutid,
                                                     limitionCondition: .all,
                                                     name: name,
                                                     workingDir: name.md5,
                                                     fileFormat: "",
                                                     cipher: "")) {
            if let folderFullPath = FileUtils.getDirPath(name) {
                _ = FileUtils.createFolder(folderFullPath)
            }
        }
    }
}
