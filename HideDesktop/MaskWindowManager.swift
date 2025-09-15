import Foundation
import AppKit
import CoreGraphics
import os.log

class MaskWindowManager {
    private let logger = Logger(subsystem: "com.liuxl.HideDesktop", category: "MaskWindowManager")
    private var _maskWindow: NSWindow?
    
    // 提供公共访问接口
    var maskWindow: NSWindow? {
        return _maskWindow
    }

    func toggleMask() {
        if _maskWindow == nil {
            createMaskWindow()
        } else {
            _maskWindow?.orderOut(nil)
            _maskWindow = nil
        }
    }

    private func createMaskWindow() {
        guard let mainScreen = NSScreen.main else {
            logger.error("无法获取主屏幕")
            return
        }

        let screenFrame = mainScreen.frame
        
        // 创建无边框窗口
        let newWindow = NSWindow(
            contentRect: screenFrame,
            styleMask: [],  // 使用空的 styleMask，相当于 AppleScript 中的 0
            backing: .buffered,
            defer: false
        )
        
        // 获取壁纸
        let workspace = NSWorkspace.shared
        if let wallpaperURL = workspace.desktopImageURL(for: mainScreen) {
            // 加载壁纸图像
            if let wallpaperImage = NSImage(contentsOf: wallpaperURL) {
                let imageSize = wallpaperImage.size
                let screenWidth = screenFrame.width
                let screenHeight = screenFrame.height
                let imageWidth = imageSize.width
                let imageHeight = imageSize.height
                
                // 获取壁纸选项
                let desktopOptions = workspace.desktopImageOptions(for: mainScreen) ?? [:]
                let scalingKey = (desktopOptions[.imageScaling] as? NSNumber)?.intValue
                let allowClipping = (desktopOptions[.allowClipping] as? NSNumber)?.boolValue ?? false
                let fillColor = desktopOptions[.fillColor] as? NSColor
                
                let scalingMode = scalingKey ?? -1
                
                // 计算缩放比例
                let widthRatio = screenWidth / imageWidth
                let heightRatio = screenHeight / imageHeight
                let fitScale = min(widthRatio, heightRatio)
                let fillScale = max(widthRatio, heightRatio)
                
                // 根据模式处理
                if scalingMode == 3 && allowClipping {
                    // 充满屏幕 (Fill Screen)
                    let scale = fillScale
                    let scaledWidth = imageWidth * scale
                    let scaledHeight = imageHeight * scale
                    let xOffset = (screenWidth - scaledWidth) / 2
                    let yOffset = (screenHeight - scaledHeight) / 2
                    
                    let imageView = NSImageView(frame: NSRect(x: xOffset, y: yOffset, width: scaledWidth, height: scaledHeight))
                    imageView.image = wallpaperImage
                    imageView.imageScaling = .scaleAxesIndependently
                    
                    let clipView = NSView(frame: screenFrame)
                    clipView.wantsLayer = true
                    clipView.layer?.masksToBounds = true
                    clipView.addSubview(imageView)
                    
                    newWindow.contentView = clipView
                    
                } else if scalingMode == 3 && !allowClipping {
                    // 适合于屏幕 (Fit to Screen)
                    let scale = fitScale
                    let scaledWidth = imageWidth * scale
                    let scaledHeight = imageHeight * scale
                    let xOffset = (screenWidth - scaledWidth) / 2
                    let yOffset = (screenHeight - scaledHeight) / 2
                    
                    if let fillColor = fillColor {
                        newWindow.backgroundColor = fillColor
                    }
                    
                    let containerView = NSView(frame: screenFrame)
                    
                    let imageView = NSImageView(frame: NSRect(x: xOffset, y: yOffset, width: scaledWidth, height: scaledHeight))
                    imageView.image = wallpaperImage
                    imageView.imageScaling = .scaleAxesIndependently
                    
                    containerView.addSubview(imageView)
                    newWindow.contentView = containerView
                    
                } else if scalingMode == 1 {
                    // 拉伸 (Stretch to Fill)
                    let imageView = NSImageView(frame: screenFrame)
                    imageView.image = wallpaperImage
                    imageView.imageScaling = .scaleAxesIndependently
                    newWindow.contentView = imageView
                    
                } else if scalingMode == 2 {
                    // 居中 (Center) - 处理 Retina 显示屏
                    if let fillColor = fillColor {
                        newWindow.backgroundColor = fillColor
                    }
                    
                    let containerView = NSView(frame: screenFrame)
                    containerView.wantsLayer = true
                    
                    // 获取屏幕的缩放因子
                    let scaleFactor = NSScreen.main?.backingScaleFactor ?? 1.0
                    
                    //print("屏幕点尺寸: \(screenWidth) x \(screenHeight)")
                    //print("屏幕缩放因子: \(scaleFactor)")
                    //print("屏幕像素尺寸: \(screenWidth * scaleFactor) x \(screenHeight * scaleFactor)")
                    
                    if let imageSource = CGImageSourceCreateWithURL(wallpaperURL as CFURL, nil),
                       let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) {
                        
                        let imagePixelWidth = CGFloat(cgImage.width)
                        let imagePixelHeight = CGFloat(cgImage.height)
                        
                        print("图像像素尺寸: \(imagePixelWidth) x \(imagePixelHeight)")
                        
                        // 居中模式：1:1 像素显示
                        // 转换为点尺寸
                        let imagePointWidth = imagePixelWidth / scaleFactor
                        let imagePointHeight = imagePixelHeight / scaleFactor
                        
                        print("图像点尺寸: \(imagePointWidth) x \(imagePointHeight)")
                        
                        // 计算要显示的区域（以点为单位）
                        let displayWidth = min(screenWidth, imagePointWidth)
                        let displayHeight = min(screenHeight, imagePointHeight)
                        
                        // 计算裁剪区域（以像素为单位）
                        let cropPixelWidth = displayWidth * scaleFactor
                        let cropPixelHeight = displayHeight * scaleFactor
                        
                        // 从中心裁剪
                        let cropX = (imagePixelWidth - cropPixelWidth) / 2
                        let cropY = (imagePixelHeight - cropPixelHeight) / 2
                        
                        //print("裁剪参数（像素）: x=\(cropX), y=\(cropY), w=\(cropPixelWidth), h=\(cropPixelHeight)")
                        //print("显示尺寸（点）: \(displayWidth) x \(displayHeight)")
                        
                        let cropRect = CGRect(x: cropX, y: cropY, width: cropPixelWidth, height: cropPixelHeight)
                        
                        if let croppedCGImage = cgImage.cropping(to: cropRect) {
                            // 创建 NSImage，指定正确的点尺寸
                            let croppedImage = NSImage(cgImage: croppedCGImage, size: NSSize(width: displayWidth, height: displayHeight))
                            
                            // 计算居中位置
                            let displayX = (screenWidth - displayWidth) / 2
                            let displayY = (screenHeight - displayHeight) / 2
                            
                            //print("显示位置（点）: x=\(displayX), y=\(displayY)")
                            
                            let imageView = NSImageView(frame: NSRect(x: displayX, y: displayY, width: displayWidth, height: displayHeight))
                            imageView.image = croppedImage
                            imageView.imageScaling = .scaleNone
                            imageView.imageFrameStyle = .none
                            
                            containerView.addSubview(imageView)
                            newWindow.contentView = containerView
                            
                            //print("居中模式设置完成")
                            //print("ImageView frame: \(imageView.frame)")
                        }
              
              

                    } else {
                        // 如果无法获取 CGImage，使用备用方案
                        let imageView = NSImageView(frame: screenFrame)
                        imageView.image = wallpaperImage
                        imageView.imageScaling = .scaleNone
                        imageView.imageAlignment = .alignCenter
                        newWindow.contentView = imageView
                    }
                    
                } else {
                    // 默认处理
                    let imageView = NSImageView(frame: screenFrame)
                    imageView.image = wallpaperImage
                    imageView.imageScaling = .scaleProportionallyUpOrDown
                    imageView.imageAlignment = .alignCenter
                    newWindow.contentView = imageView
                }
                
            } else {
                // 无法加载壁纸图像
                logger.error("无法加载壁纸图像: \(wallpaperURL)")
                newWindow.backgroundColor = NSColor(calibratedWhite: 0.2, alpha: 1.0)
            }
        } else {
            // 无法获取壁纸URL时显示深灰色背景
            newWindow.backgroundColor = NSColor(calibratedWhite: 0.2, alpha: 1.0)
        }
        
        // 配置窗口属性
        newWindow.isOpaque = true
        newWindow.ignoresMouseEvents = true
        newWindow.collectionBehavior = .canJoinAllSpaces
        
        // 设置窗口层级（在桌面图标之上）- 这是关键修复
        // 使用 CGWindowLevelForKey 获取桌面图标窗口层级并加1
        let desktopIconLevel = CGWindowLevelForKey(.desktopIconWindow)
        newWindow.level = NSWindow.Level(rawValue: Int(desktopIconLevel + 1))
        
        newWindow.isReleasedWhenClosed = false
        newWindow.orderFrontRegardless()
        
        _maskWindow = newWindow
        logger.info("遮罩窗口创建并显示成功")
    }
}
