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
        
        let toggleItem = NSMenuItem(title: "切换桌面显示", action: #selector(toggleDesktop), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "退出", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    @objc func toggleDesktop() {
        maskWindowManager?.toggleMask()
    }
    
    @objc func quitApp() {
        NSApp.terminate(nil)
    }
}
