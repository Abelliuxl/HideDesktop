# HideDesktop

一个简洁的 macOS 桌面图标隐藏工具，帮助您获得更清爽的桌面体验。

![App Icon](HideDesktop/Assets.xcassets/AppIcon.appiconset/1024.png)

## 功能特性

- 🖥️ **一键隐藏/显示桌面图标** - 快速切换桌面图标的显示状态
- 🎯 **状态栏菜单集成** - 方便的状态栏图标和菜单
- 🌍 **多语言支持** - 支持中文和英文界面
- 🚀 **开机启动** - 支持设置开机自动启动
- 💾 **状态记忆** - 自动保存您的偏好设置
- 🎨 **简洁界面** - 简单直观的用户体验

## 系统要求

- macOS 15.5 或更高版本
- Apple Silicon (M1/M2/M3) 或 Intel 处理器

## 安装方法

### 从源码构建

1. 克隆此仓库：
   ```bash
   git clone https://github.com/Abelliuxl/HideDesktop.git
   ```

2. 使用 Xcode 打开项目：
   ```bash
   cd HideDesktop
   open HideDesktop.xcodeproj
   ```

3. 在 Xcode 中选择目标设备，然后点击运行按钮构建项目。

4. 构建完成后，您可以在 `build/Build/Products/Release/` 目录下找到 `HideDesktop.app`。

5. 将应用拖拽到 `应用程序` 文件夹中。

## 使用方法

1. 启动 HideDesktop 应用
2. 点击菜单栏中的 HideDesktop 图标
3. 选择相应功能：
   - **隐藏桌面图标** - 立即隐藏所有桌面图标
   - **显示桌面图标** - 恢复显示所有桌面图标
   - **开机启动** - 设置应用在开机时自动启动
   - **语言切换** - 在中文和英文界面之间切换

## 技术栈

- **SwiftUI** - 现代化的用户界面框架
- **Swift** - 强大的编程语言
- **AppKit** - macOS 原生应用框架
- **SMAppService** - macOS 开机启动管理

## 许可证

本项目采用 **CC BY-NC-SA 4.0** 许可证。

- ✅ **允许**：使用、修改、分发、共享
- ❌ **禁止**：商业用途、盈利
- 📋 **要求**：署名、相同方式共享

详细信息请查看 [LICENSE](LICENSE) 文件。

## 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建您的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开一个 Pull Request

## 更新日志

### v1.1.0
- ✨ 新增开机启动功能
- 🌐 改进多语言支持
- 🎨 优化用户界面
- 🐛 修复已知问题

### v1.0.0
- 🎉 初始版本发布
- 🖥️ 基本的桌面图标隐藏/显示功能
- 🎯 状态栏菜单集成

## 联系方式

- 项目地址：[https://github.com/Abelliuxl/HideDesktop](https://github.com/Abelliuxl/HideDesktop)
- 问题反馈：[GitHub Issues](https://github.com/Abelliuxl/HideDesktop/issues)

## 免责声明

本软件按"原样"提供，不提供任何明示或暗示的保证，包括但不限于适销性、特定用途适用性和非侵权性的保证。在任何情况下，作者或版权持有人均不对任何索赔、损害或其他责任负责，无论是在合同、侵权或其他方面，由软件或软件的使用或其他交易引起、产生或与之相关。

---

**注意**: 本软件仅供个人学习和非商业用途使用。如需商业合作，请联系作者。
