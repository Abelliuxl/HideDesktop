//
//  HideDesktopApp.swift
//  HideDesktop
//
//  Created by liuxl on 2025/9/15.
//

import SwiftUI
import AppKit
import Combine
import ServiceManagement

@main
struct HideDesktopApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var maskWindowManager: MaskWindowManager?
    var toggleMenuItem: NSMenuItem?
    var languageMenuItem: NSMenuItem?
    var startupMenuItem: NSMenuItem?
    private var cancellables = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 设置应用为代理应用，不显示在 Dock 中
        NSApp.setActivationPolicy(.accessory)
        
        // 创建状态栏项目
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "desktopcomputer", accessibilityDescription: "Hide Desktop")
            button.action = #selector(toggleDesktop)
            button.target = self
        }
        
        // 初始化遮罩窗口管理器
        maskWindowManager = MaskWindowManager()
        
        // 创建菜单
        createMenu()
    }
    
    func createMenu() {
        let menu = NSMenu()
        
        // 隐藏桌面图标菜单项
        toggleMenuItem = NSMenuItem(title: LocalizationManager.shared.string(forKey: "hide_desktop"), action: #selector(toggleDesktop), keyEquivalent: "")
        toggleMenuItem?.target = self
        
        // 为菜单项设置固定宽度，确保勾选标记出现时文本不会偏移
        // 在文本前面添加空格来为勾选标记预留空间
        updateToggleMenuItemTitle()
        
        menu.addItem(toggleMenuItem!)
        
        menu.addItem(NSMenuItem.separator())
        
        // 语言切换菜单项
        languageMenuItem = NSMenuItem(title: LocalizationManager.shared.string(forKey: "language"), action: nil, keyEquivalent: "")
        languageMenuItem?.target = self
        
        let languageAttributedTitle = NSAttributedString(string: "    " + LocalizationManager.shared.string(forKey: "language"), attributes: [
            .font: NSFont.systemFont(ofSize: 13)
        ])
        languageMenuItem?.attributedTitle = languageAttributedTitle
        
        // 创建语言子菜单
        let languageSubMenu = NSMenu()
        
        // 中文选项
        let chineseItem = NSMenuItem(title: LocalizationManager.shared.string(forKey: "chinese"), action: #selector(switchToChinese), keyEquivalent: "")
        chineseItem.target = self
        chineseItem.state = LocalizationManager.shared.currentLanguage == "zh" ? .on : .off
        languageSubMenu.addItem(chineseItem)
        
        // 英文选项
        let englishItem = NSMenuItem(title: LocalizationManager.shared.string(forKey: "english"), action: #selector(switchToEnglish), keyEquivalent: "")
        englishItem.target = self
        englishItem.state = LocalizationManager.shared.currentLanguage == "en" ? .on : .off
        languageSubMenu.addItem(englishItem)
        
        languageMenuItem?.submenu = languageSubMenu
        menu.addItem(languageMenuItem!)
        
        menu.addItem(NSMenuItem.separator())
        
        // 开机启动菜单项
        startupMenuItem = NSMenuItem(title: LocalizationManager.shared.string(forKey: "startup"), action: #selector(toggleStartup), keyEquivalent: "")
        startupMenuItem?.target = self
        startupMenuItem?.state = isLoginItemEnabled() ? .on : .off
        
        let startupAttributedTitle = NSAttributedString(string: "    " + LocalizationManager.shared.string(forKey: "startup"), attributes: [
            .font: NSFont.systemFont(ofSize: 13)
        ])
        startupMenuItem?.attributedTitle = startupAttributedTitle
        
        menu.addItem(startupMenuItem!)
        
        menu.addItem(NSMenuItem.separator())
        
        // 退出菜单项
        let quitItem = NSMenuItem(title: LocalizationManager.shared.string(forKey: "quit"), action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        
        let quitAttributedTitle = NSAttributedString(string: "    " + LocalizationManager.shared.string(forKey: "quit"), attributes: [
            .font: NSFont.systemFont(ofSize: 13)
        ])
        quitItem.attributedTitle = quitAttributedTitle
        
        menu.addItem(quitItem)
        
        // 设置菜单最小宽度，确保勾选状态变化时宽度不变
        menu.minimumWidth = 200
        
        statusItem?.menu = menu
        
        // 监听语言变化
        LocalizationManager.shared.$currentLanguage
            .sink { [weak self] _ in
                self?.updateMenuLanguage()
            }
            .store(in: &cancellables)
    }
    
    private func updateToggleMenuItemTitle() {
        let title = "    " + LocalizationManager.shared.string(forKey: "hide_desktop")
        let attributedTitle = NSAttributedString(string: title, attributes: [
            .font: NSFont.systemFont(ofSize: 13)
        ])
        toggleMenuItem?.attributedTitle = attributedTitle
    }
    
    private func updateMenuLanguage() {
        // 更新隐藏桌面图标菜单项
        updateToggleMenuItemTitle()
        
        // 更新语言菜单项
        let languageTitle = "    " + LocalizationManager.shared.string(forKey: "language")
        let languageAttributedTitle = NSAttributedString(string: languageTitle, attributes: [
            .font: NSFont.systemFont(ofSize: 13)
        ])
        languageMenuItem?.attributedTitle = languageAttributedTitle
        
        // 更新语言子菜单
        if let languageSubMenu = languageMenuItem?.submenu {
            let chineseItem = languageSubMenu.item(at: 0)
            let englishItem = languageSubMenu.item(at: 1)
            
            // 更新中文选项
            chineseItem?.title = LocalizationManager.shared.string(forKey: "chinese")
            chineseItem?.state = LocalizationManager.shared.currentLanguage == "zh" ? .on : .off
            
            // 更新英文选项
            englishItem?.title = LocalizationManager.shared.string(forKey: "english")
            englishItem?.state = LocalizationManager.shared.currentLanguage == "en" ? .on : .off
        }
        
        // 更新开机启动菜单项
        let startupTitle = "    " + LocalizationManager.shared.string(forKey: "startup")
        let startupAttributedTitle = NSAttributedString(string: startupTitle, attributes: [
            .font: NSFont.systemFont(ofSize: 13)
        ])
        startupMenuItem?.attributedTitle = startupAttributedTitle
        
        // 更新退出菜单项
        if let quitItem = statusItem?.menu?.items.last {
            let quitTitle = "    " + LocalizationManager.shared.string(forKey: "quit")
            let quitAttributedTitle = NSAttributedString(string: quitTitle, attributes: [
                .font: NSFont.systemFont(ofSize: 13)
            ])
            quitItem.attributedTitle = quitAttributedTitle
        }
        
        // 强制重新创建菜单以确保状态更新
        DispatchQueue.main.async {
            let currentMenu = self.statusItem?.menu
            self.statusItem?.menu = nil
            DispatchQueue.main.async {
                self.statusItem?.menu = currentMenu
            }
        }
    }
    
    @objc private func switchToChinese() {
        LocalizationManager.shared.currentLanguage = "zh"
    }
    
    @objc private func switchToEnglish() {
        LocalizationManager.shared.currentLanguage = "en"
    }
    
    @objc func toggleDesktop() {
        maskWindowManager?.toggleMask()
        updateMenuState()
    }
    
    func updateMenuState() {
        // 根据 maskWindow 是否存在来更新菜单项状态
        let isHidden = maskWindowManager?.maskWindow != nil
        toggleMenuItem?.state = isHidden ? .on : .off
    }
    
    @objc func quitApp() {
        NSApp.terminate(nil)
    }
    
    // MARK: - 开机启动功能
    
    @objc private func toggleStartup() {
        let currentState = isLoginItemEnabled()
        setLoginItem(enabled: !currentState)
        startupMenuItem?.state = !currentState ? .on : .off
    }
    
    private func isLoginItemEnabled() -> Bool {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return false }
        
        // 使用现代的 SMAppService API
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        } else {
            // 对于旧版本的 macOS，使用 UserDefaults 检查
            return UserDefaults.standard.bool(forKey: "LoginItemEnabled_\(bundleIdentifier)")
        }
    }
    
    private func setLoginItem(enabled: Bool) {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return }
        
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to \(enabled ? "enable" : "disable") login item: \(error)")
            }
        } else {
            // 对于旧版本的 macOS，使用 UserDefaults 保存状态
            UserDefaults.standard.set(enabled, forKey: "LoginItemEnabled_\(bundleIdentifier)")
            
            // 这里可以添加旧版本的实现，比如使用 AppleScript 或者启动项文件
            // 但为了简化，我们只保存状态
        }
    }
}
