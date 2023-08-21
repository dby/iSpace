//
//  MeModel.swift
//  iSecrets
//
//  Created by dby on 2023/7/16.
//

import SwiftUI
import Foundation

class MeViewModel: ObservableObject {
    @Published var diskUsage: CGFloat = 0
    @Published var diskUsageText: String = ""
}

extension MeViewModel {
    func calcDiskUsage() {
        if let p = PathUtils.rootDir() {
            self.diskUsage = FileUtils.folderSizeAtPath(p)
            self.diskUsageText = "\(Utils.goodFormatSizeStr(Double(self.diskUsage)))/\(Utils.goodFormatSizeStr(FILESIZE_1G)) 已用"
        }
    }
    
    func shareAppToFriends() {
        let appURL = URL(string: "https://www.example.com/app") // 替换为您的应用程序的App Store链接
        let activityViewController = UIActivityViewController(activityItems: [appURL!],
                                                              applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }
}
