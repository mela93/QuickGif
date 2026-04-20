# GIF Generator Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor the GIF conversion process to improve performance, memory management, and error handling by moving heavy computations off the Main Actor.

**Architecture:** Utilize Swift concurrency with `Task` and explicit `@MainActor` switches for UI updates. Implement `autoreleasepool` for memory efficiency and refine error states to persist until cleared.

**Tech Stack:** Swift, AVFoundation, ImageIO, SwiftUI.

---

### Task 1: Refactor Conversion Logic

**Files:**
- Modify: `ViewModels/ConversionViewModel.swift`

- [ ] **Step 1: Implement the refactored `convert` method**

Update `ViewModels/ConversionViewModel.swift` to move heavy work off the Main Actor, add `autoreleasepool`, and improve error handling.

```swift
    func convert(videoURL: URL) {
        Task {
            // UI initialization on Main Actor
            await MainActor.run {
                isProcessing = true
                progress = 0
                statusText = "> ANALYZING VIDEO..."
                lastError = nil
            }
            
            do {
                let asset = AVAsset(url: videoURL)
                guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else {
                    throw NSError(domain: "Conversion", code: 1, userInfo: [NSLocalizedDescriptionKey: "NO VIDEO TRACK FOUND"])
                }
                
                let duration = try await asset.load(.duration)
                let durationSeconds = CMTimeGetSeconds(duration)
                let frameCount = Int(durationSeconds * Double(settings.fps))
                
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                generator.requestedTimeToleranceBefore = .zero
                generator.requestedTimeToleranceAfter = .zero
                
                let nativeSize = try await videoTrack.load(.naturalSize)
                let aspectRatio = nativeSize.height / nativeSize.width
                generator.maximumSize = CGSize(width: settings.width, height: settings.width * aspectRatio)
                
                await MainActor.run {
                    statusText = "> PREPARING GIF..."
                }
                
                let outputURL = FileManager.default.getUniqueURL(for: videoURL)
                guard let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, UTType.gif.identifier as CFString, frameCount, nil) else {
                    throw NSError(domain: "Conversion", code: 2, userInfo: [NSLocalizedDescriptionKey: "COULD NOT CREATE GIF DESTINATION"])
                }
                
                let fileProperties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: settings.loopCount]]
                CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
                
                let frameProperties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: 1.0 / Double(settings.fps)]]
                
                await MainActor.run {
                    statusText = "> EXTRACTING FRAMES..."
                }
                
                for i in 0..<frameCount {
                    let time = CMTime(value: Int64(i), timescale: Int32(settings.fps))
                    
                    // Memory management: wrap heavy image operations in autoreleasepool
                    try autoreleasepool {
                        let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                        CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
                    }
                    
                    let currentProgress = Double(i + 1) / Double(frameCount)
                    await MainActor.run {
                        progress = currentProgress
                    }
                }
                
                await MainActor.run {
                    statusText = "> FINALIZING GIF..."
                }
                
                // Finalize on background thread
                if CGImageDestinationFinalize(destination) {
                    await MainActor.run {
                        statusText = "> CONVERSION COMPLETE."
                        NSWorkspace.shared.activateFileViewerSelecting([outputURL])
                    }
                    
                    // Reset after success
                    try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                    await MainActor.run {
                        isProcessing = false
                        statusText = "[ IDLE ]"
                    }
                } else {
                    throw NSError(domain: "Conversion", code: 3, userInfo: [NSLocalizedDescriptionKey: "FAILED TO FINALIZE GIF"])
                }
                
            } catch {
                await MainActor.run {
                    lastError = error.localizedDescription.uppercased()
                    isProcessing = false
                    // Don't reset statusText immediately so user can see what failed
                }
            }
        }
    }
```

- [ ] **Step 2: Verify the logic manually**

Review the changes to ensure:
- Heavy work (loop, copyCGImage, finalize) is outside `MainActor.run`.
- `autoreleasepool` is correctly used around `copyCGImage` and `CGImageDestinationAddImage`.
- Errors caught in the `do-catch` block update `lastError` and `isProcessing` on the Main Actor.
- Success path still includes a delay before resetting to IDLE.

- [ ] **Step 3: Commit changes**

```bash
git add ViewModels/ConversionViewModel.swift
git commit -m "perf: move heavy conversion work off main thread and add autoreleasepool"
```
