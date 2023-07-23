//
//  MeModel.swift
//  iSecrets
//
//  Created by dby on 2023/7/16.
//

import SwiftUI
import Foundation

let FILESIZE_1M: Double = 1 * 1024 * 1024
let FILESIZE_1G: Double = 1 * 1024 * 1024 * 1024
let FILESIZE_10G: Double = 10 * 1024 * 1024 * 1024
let FILESIZE_100G: Double = 100 * 1024 * 1024 * 1024
let FILESIZE_1T: Double = 1 * 1024 * 1024 * 1024 * 1024

class MeViewModel: ObservableObject {
    @Published var diskUsage: CGFloat = 0
    @Published var diskUsageText: String = ""
}

extension MeViewModel {
    func calcDiskUsage() {
        if let p = PathUtils.rootDir() {
            self.diskUsage = FileUtils.folderSizeAtPath(p)
            self.diskUsageText = "\(goodFormatSizeStr(Double(self.diskUsage)))/\(goodFormatSizeStr(FILESIZE_1G)) 已用"
        }
    }
    
    private func goodFormatSizeStr(_ usage: Double) -> String {
        if usage >= FILESIZE_1G {
            // 大于1G
            return String(format: "%.1fGB", usage/FILESIZE_1G)
        } else if usage >= 1 * 1024 * 1024 {
            // 大于1M
            return String(format: "%.1fMB", usage/FILESIZE_1M)
        } else if usage >= 1 * 1024 {
            // 大于1KB
            return String(format: "%.1fKB", usage/1*1024)
        } else {
            return String(format: "%dB", Int(usage))
        }
    }
}
