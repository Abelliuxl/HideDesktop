//
//  LocalizationManager.swift
//  HideDesktop
//
//  Created by liuxl on 2025/9/15.
//

import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    @Published var currentLanguage: String = "zh" {
        willSet {
            UserDefaults.standard.set(newValue, forKey: "AppLanguage")
            updateStrings(for: newValue)
        }
    }
    
    private var localizedStrings: [String: String] = [:]
    
    static let shared = LocalizationManager()
    
    private init() {
        // 从 UserDefaults 加载保存的语言设置
        if let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage") {
            currentLanguage = savedLanguage
        } else {
            // 根据系统语言设置默认语言
            let systemLanguage = Locale.current.languageCode ?? "en"
            currentLanguage = (systemLanguage == "zh") ? "zh" : "en"
        }
        updateStrings(for: currentLanguage)
    }
    
    private func updateStrings(for language: String) {
        switch language {
        case "zh":
            localizedStrings = [
                "hide_desktop": "隐藏桌面图标",
                "quit": "退出",
                "language": "语言",
                "chinese": "中文",
                "english": "English",
                "startup": "开机启动"
            ]
        case "en":
            localizedStrings = [
                "hide_desktop": "Hide Desktop Icons",
                "quit": "Quit",
                "language": "Language",
                "chinese": "中文",
                "english": "English",
                "startup": "Start at Login"
            ]
        default:
            localizedStrings = [
                "hide_desktop": "Hide Desktop Icons",
                "quit": "Quit",
                "language": "Language",
                "chinese": "中文",
                "english": "English",
                "startup": "Start at Login"
            ]
        }
    }
    
    func string(forKey key: String) -> String {
        return localizedStrings[key] ?? key
    }
}
