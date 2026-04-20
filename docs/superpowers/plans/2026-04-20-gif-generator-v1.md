# GIF Generator for macOS Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 构建一个基于 SwiftUI 的轻量级 macOS GIF 转换工具，采用赛博终端风格，支持视频拖拽即转，并完美适配 macOS 26 Liquid Glass 视觉特性。

**Architecture:** 采用 MVVM 模式。ViewModel 负责通过 AVFoundation 提取视频帧并使用 ImageIO 进行 GIF 编码。UI 使用 SwiftUI 构建，支持 Liquid Glass 材质。

**Tech Stack:** Swift, SwiftUI, AVFoundation, ImageIO, UniformTypeIdentifiers.

---

## File Structure

- `GIFGeneratorApp.swift`: 应用入口。
- `Models/GifSettings.swift`: 用户配置模型。
- `ViewModels/ConversionViewModel.swift`: 转换逻辑核心。
- `Views/ContentView.swift`: 主窗口视图。
- `Views/DropZoneView.swift`: 拖放交互区域。
- `Views/TerminalProgressView.swift`: 赛博风格进度展示。
- `Helpers/FileManager+Extensions.swift`: 处理文件命名冲突及定位。

---

### Task 1: 项目初始化与基础模型

**Files:**
- Create: `GIFGeneratorApp.swift`
- Create: `Models/GifSettings.swift`

- [ ] **Step 1: 创建 GifSettings 模型**

```swift
import Foundation

struct GifSettings {
    var width: CGFloat = 240
    var fps: Int = 12
    var loopCount: Int = 0 // 0 means infinite
}
```

- [ ] **Step 2: 创建应用入口**

```swift
import SwiftUI

@main
struct GIFGeneratorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
```

- [ ] **Step 3: Commit**

```bash
git add GIFGeneratorApp.swift Models/GifSettings.swift
git commit -m "chore: initial project structure and settings model"
```

---

### Task 2: 实现文件处理助手

**Files:**
- Create: `Helpers/FileManager+Extensions.swift`

- [ ] **Step 1: 实现自动递增命名逻辑**

```swift
import Foundation

extension FileManager {
    func getUniqueURL(for originalURL: URL) -> URL {
        let directory = originalURL.deletingLastPathComponent()
        let fileName = originalURL.deletingPathExtension().lastPathComponent
        let ext = "gif"
        
        var targetURL = directory.appendingPathComponent("\(fileName).\(ext)")
        var counter = 1
        
        while fileExists(atPath: targetURL.path) {
            targetURL = directory.appendingPathComponent("\(fileName)_\(counter).\(ext)")
            counter += 1
        }
        return targetURL
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Helpers/FileManager+Extensions.swift
git commit -m "feat: add unique file naming logic"
```

---

### Task 3: 实现转换核心 (ViewModel)

**Files:**
- Create: `ViewModels/ConversionViewModel.swift`

- [ ] **Step 1: 定义状态与接口**

```swift
import SwiftUI
import AVFoundation
import ImageIO

class ConversionViewModel: ObservableObject {
    @Published var progress: Double = 0
    @Published var statusText: String = "[ IDLE ]"
    @Published var isProcessing: Bool = false
    @Published var lastError: String?
    
    var settings = GifSettings()
    
    func convert(videoURL: URL) {
        // Implementation in next steps
    }
}
```

- [ ] **Step 2: 实现帧提取与编码逻辑**

```swift
// In ViewModels/ConversionViewModel.swift
func convert(videoURL: URL) {
    Task { @MainActor in
        isProcessing = true
        progress = 0
        statusText = "> ANALYZING VIDEO..."
        
        let asset = AVAsset(url: videoURL)
        guard let videoTrack = try? await asset.loadTracks(withMediaType: .video).first else {
            lastError = "NO VIDEO TRACK FOUND"
            isProcessing = false
            return
        }
        
        let duration = try? await asset.load(.duration)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        
        statusText = "> EXTRACTING FRAMES..."
        // Detailed implementation follows Task 5
    }
}
```

- [ ] **Step 3: Commit**

```bash
git add ViewModels/ConversionViewModel.swift
git commit -m "feat: skeleton for conversion engine"
```

---

### Task 4: 赛博终端 + Liquid Glass UI 实现

**Files:**
- Create: `Views/ContentView.swift`
- Create: `Views/DropZoneView.swift`

- [ ] **Step 1: 实现赛博风格进度条**

```swift
import SwiftUI

struct TerminalProgressView: View {
    let progress: Double
    
    var body: some View {
        HStack(spacing: 2) {
            let filledCount = Int(progress * 10)
            Text("[")
            ForEach(0..<10) { i in
                Text(i < filledCount ? "■" : "□")
            }
            Text("] \(Int(progress * 100))%")
        }
        .font(.system(.body, design: .monospaced))
        .foregroundColor(Color(red: 0.22, green: 1.0, blue: 0.08)) // #39FF14
        .shadow(color: Color(red: 0.22, green: 1.0, blue: 0.08).opacity(0.5), radius: 5)
    }
}
```

- [ ] **Step 2: 实现 DropZoneView (集成 Liquid Glass 材质)**

```swift
import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
    @ObservedObject var viewModel: ConversionViewModel
    
    var body: some View {
        ZStack {
            // Liquid Glass 材质层
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            Color(red: 0.22, green: 1.0, blue: 0.08).opacity(0.6),
                            style: StrokeStyle(lineWidth: 1.5, dash: [8, 4])
                        )
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 12) {
                if viewModel.isProcessing {
                    Text(viewModel.statusText)
                        .glow(color: Color(red: 0.22, green: 1.0, blue: 0.08))
                    TerminalProgressView(progress: viewModel.progress)
                } else {
                    Text("[ DRAG & DROP FILE HERE ]")
                }
            }
            .font(.system(.body, design: .monospaced))
            .foregroundColor(Color(red: 0.22, green: 1.0, blue: 0.08))
        }
        .padding(20)
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            // 处理逻辑
            return true
        }
    }
}

// 辅助发光效果
extension View {
    func glow(color: Color, radius: CGFloat = 8) -> some View {
        self.shadow(color: color.opacity(0.8), radius: radius)
            .shadow(color: color.opacity(0.5), radius: radius / 2)
    }
}
```

- [ ] **Step 3: Commit**

```bash
git add Views/ContentView.swift Views/DropZoneView.swift
git commit -m "feat: cyber-terminal UI with Liquid Glass"
```

---

### Task 5: 最终集成与测试

- [ ] **Step 1: 完善 ConversionViewModel 中的 GIF 编码完整逻辑**
- [ ] **Step 2: 集成 NSWorkspace Finder 定位功能**
- [ ] **Step 3: 运行并测试拖拽功能**
- [ ] **Step 4: Commit final version**

```bash
git add .
git commit -m "feat: complete MVP integration"
```
