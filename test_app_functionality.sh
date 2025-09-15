#!/bin/bash

echo "=== HideDesktop 应用功能测试 ==="
echo "应用正在运行，请在菜单栏查找桌面图标"
echo "点击菜单栏中的 HideDesktop 图标来测试功能"
echo ""
echo "预期行为："
echo "1. 第一次点击：隐藏桌面图标"
echo "2. 第二次点击：恢复桌面图标"
echo ""
echo "如果菜单栏图标没有显示，请尝试："
echo "1. 检查系统偏好设置中的菜单栏设置"
echo "2. 重启应用"
echo ""
echo "应用进程信息："
ps aux | grep HideDesktop | grep -v grep
echo ""
echo "AppleScript 文件位置："
ls -la "/Users/liuxiaoliang/Library/Developer/Xcode/DerivedData/HideDesktop-ajnodfhhihgcpghftigqfscodqci/Build/Products/Debug/HideDesktop.app/Contents/Resources/hide_desktop_script.scpt"
