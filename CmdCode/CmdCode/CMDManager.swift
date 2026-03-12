//
//  CMDManager.swift
//  CmdCode
//
//  Created on 2026/2/22.
//

import Foundation

/// 指令管理类单例
final class CMDManager {

    static let shared = CMDManager()

    /// WSAD 字母为 key，文件名为 value 的映射
    private(set) var gifMapping: [String: String] = [:]

    /// WSAD 字母为 key，key 前面文字为 value 的映射（如 "补给背包SASWWS" → key "SASWWS" 对应 value "补给背包"）
    private(set) var namePrefixMapping: [String: String] = [:]

    private init() {
        loadGifMapping()
    }

    private func loadGifMapping() {
        guard let urls = Bundle.main.urls(forResourcesWithExtension: "gif", subdirectory: nil), !urls.isEmpty else {
            return
        }

        let pattern = #"([WSAD]+)(?:-[^-]*)?\.gif$"#
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)

        for url in urls {
            let filename = url.lastPathComponent
            let range = NSRange(filename.startIndex..., in: filename)
            guard let match = regex?.firstMatch(in: filename, options: [], range: range),
                  let keyRange = Range(match.range(at: 1), in: filename) else {
                continue
            }
            let key = String(filename[keyRange])
            gifMapping[key] = filename
            let prefix = String(filename[..<keyRange.lowerBound])
            namePrefixMapping[key] = prefix
        }
    }

    /// 随机返回一个 WSAD key
    func randomKey() -> String? {
        let keys = Array(gifMapping.keys)
        return keys.isEmpty ? nil : keys.randomElement()
    }
}
