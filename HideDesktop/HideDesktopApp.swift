//
//  HideDesktopApp.swift
//  HideDesktop
//
//  Created by liuxl on 2025/9/15.
//

import SwiftUI
import AppKit

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
        
        toggleMenuItem = NSMenuItem(title: "隐藏桌面图标", action: #selector(toggleDesktop), keyEquivalent: "")
        toggleMenuItem?.target = self
        
        // 为菜单项设置固定宽度，确保勾选标记出现时文本不会偏移
        // 在文本前面添加空格来为勾选标记预留空间
        let attributedTitle = NSAttributedString(string: "    隐藏桌面图标", attributes: [
            .font: NSFont.systemFont(ofSize: 13)
        ])
        toggleMenuItem?.attributedTitle = attributedTitle
        
        menu.addItem(toggleMenuItem!)
        
        menu.addItem(NSMenuItem.separator())
        
        // 为退出菜单项也添加相同的空格，保持文本对齐
        let quitItem = NSMenuItem(title: "退出", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        
        let quitAttributedTitle = NSAttributedString(string: "    退出", attributes: [
            .font: NSFont.systemFont(ofSize: 13)
        ])
        quitItem.attributedTitle = quitAttributedTitle
        
        menu.addItem(quitItem)
        
        // 设置菜单最小宽度，确保勾选状态变化时宽度不变
        menu.minimumWidth = 180
        
        statusItem?.menu = menu
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
}
