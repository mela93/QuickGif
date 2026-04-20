# 🟢 QuickGif

![License: MIT](https://img.shields.io/badge/License-MIT-00FF41?style=flat-square&logo=opensourceinitiative&logoColor=black)
![Platform: macOS](https://img.shields.io/badge/Platform-macOS_14+-00F0FF?style=flat-square&logo=apple&logoColor=black)
![Swift: 5.9](https://img.shields.io/badge/Swift-5.10+-F05138?style=flat-square&logo=swift&logoColor=white)

一款专为 macOS 设计的极简赛博风 GIF 转换工具。

> **"Drag. Drop. Done."**

## 🔗 开源说明
- **托管平台**: [GitHub](https://github.com/mela93/QuickGif)
- **开源协议**: MIT License

## ✨ 特性 (Features)
- **赛博终端视觉 (Cyber-Terminal Style)**: 荧光绿配色、等宽字体、霓虹发光特效。
- **液态玻璃材质 (Liquid Glass)**: 完美适配 macOS 26 (Tahoe)，采用 `ultraThinMaterial` 半透明通透感设计。
- **即拖即用 (Drag & Drop)**: 核心交互方式，支持从 Finder 直接拖入文件。
- **多格式支持**: 
  - **视频**: `.mp4`, `.mov` (自动解析帧并转换)。
  - **图片**: `.jpg`, `.png` (单帧快速转 GIF)。
- **智能处理**:
  - **原地生成**: 转换结果直接保存在源文件目录。
  - **冲突处理**: 自动检测同名文件并添加 `_1`, `_2` 后缀。
  - **一键定位**: 转换完成后自动在 Finder 中高亮结果。

## 🛠 技术栈 (Tech Stack)
- **Language**: Swift 5.10+
- **Framework**: SwiftUI (macOS 14+)
- **Engines**: AVFoundation (Video), ImageIO (GIF Encoding)

## 🚀 快速开始 (Usage)

### 运行开发版本
```bash
swift run
```

### 构建安装包
运行我们提供的构建脚本，在当前目录生成 `.dmg` 安装程序：
```bash
./build_dmg.sh
```

## 🎨 UI 规范
- **背景**: 纯黑 (#000000) 配合 30% 透明度玻璃材质。
- **主色**: 赛博荧光绿 (#39FF14)。
- **字体**: Monospaced (SF Mono / Menlo)。

---
*Created with ❤️ by Gemini CLI for the Cyberpunk Future.*


---
[Convert icons created by NajmunNahar - Flaticon](https://www.flaticon.com/free-icons/convert "convert icons")