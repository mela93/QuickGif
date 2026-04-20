import SwiftUI
import AVFoundation
import ImageIO
import UniformTypeIdentifiers
import AppKit

class ConversionViewModel: ObservableObject {
    @Published var progress: Double = 0
    @Published var statusText: String = "[ IDLE ]"
    @Published var isProcessing: Bool = false
    @Published var lastError: String?
    
    var settings = GifSettings()
    
    func convert(inputURL: URL) {
        Task {
            // UI initialization on Main Actor
            await MainActor.run {
                isProcessing = true
                progress = 0
                statusText = "> ANALYZING FILE..."
                lastError = nil
            }
            
            // Use Task.detached to ensure heavy work is off the Main Actor
            await Task.detached(priority: .userInitiated) { [settings, weak self] in
                guard let self = self else { return }
                
                do {
                    let isImage = UTType(filenameExtension: inputURL.pathExtension)?.conforms(to: .image) ?? false
                    
                    if isImage {
                        try await self.processImage(inputURL: inputURL, settings: settings)
                    } else {
                        try await self.processVideo(inputURL: inputURL, settings: settings)
                    }
                    
                    // Reset after success
                    try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                    await MainActor.run {
                        self.isProcessing = false
                        self.statusText = "[ IDLE ]"
                    }
                } catch {
                    await MainActor.run {
                        self.lastError = error.localizedDescription.uppercased()
                        // Don't reset isProcessing immediately so user can see error
                        Task {
                            try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)
                            await MainActor.run {
                                if self.lastError != nil {
                                    self.isProcessing = false
                                    self.statusText = "[ IDLE ]"
                                    self.lastError = nil
                                }
                            }
                        }
                    }
                }
            }.value
        }
    }
    
    private func processImage(inputURL: URL, settings: GifSettings) async throws {
        await MainActor.run { self.statusText = "> PROCESSING IMAGE..." }
        
        guard let image = NSImage(contentsOf: inputURL),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw NSError(domain: "Conversion", code: 4, userInfo: [NSLocalizedDescriptionKey: "FAILED TO LOAD IMAGE"])
        }
        
        let outputURL = FileManager.default.getUniqueURL(for: inputURL)
        guard let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, UTType.gif.identifier as CFString, 1, nil) else {
            throw NSError(domain: "Conversion", code: 2, userInfo: [NSLocalizedDescriptionKey: "COULD NOT CREATE GIF DESTINATION"])
        }
        
        let fileProperties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: settings.loopCount]]
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        
        let frameProperties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: 1.0]]
        
        CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
        
        if CGImageDestinationFinalize(destination) {
            await MainActor.run {
                self.progress = 1.0
                self.statusText = "> IMAGE SAVED AS GIF."
                NSWorkspace.shared.activateFileViewerSelecting([outputURL])
            }
        } else {
            throw NSError(domain: "Conversion", code: 3, userInfo: [NSLocalizedDescriptionKey: "FAILED TO FINALIZE GIF"])
        }
    }
    
    private func processVideo(inputURL: URL, settings: GifSettings) async throws {
        let asset = AVAsset(url: inputURL)
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
        
        await MainActor.run { self.statusText = "> PREPARING GIF..." }
        
        let outputURL = FileManager.default.getUniqueURL(for: inputURL)
        guard let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, UTType.gif.identifier as CFString, frameCount, nil) else {
            throw NSError(domain: "Conversion", code: 2, userInfo: [NSLocalizedDescriptionKey: "COULD NOT CREATE GIF DESTINATION"])
        }
        
        let fileProperties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: settings.loopCount]]
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        
        let frameProperties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: 1.0 / Double(settings.fps)]]
        
        await MainActor.run { self.statusText = "> EXTRACTING FRAMES..." }
        
        for i in 0..<frameCount {
            let time = CMTime(value: Int64(i), timescale: Int32(settings.fps))
            
            var frameError: Error?
            autoreleasepool {
                do {
                    let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                    CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
                } catch {
                    frameError = error
                }
            }
            
            if let error = frameError { throw error }
            
            let currentProgress = Double(i + 1) / Double(frameCount)
            await MainActor.run { self.progress = currentProgress }
        }
        
        await MainActor.run { self.statusText = "> FINALIZING GIF..." }
        
        if CGImageDestinationFinalize(destination) {
            await MainActor.run {
                self.statusText = "> CONVERSION COMPLETE."
                NSWorkspace.shared.activateFileViewerSelecting([outputURL])
            }
        } else {
            throw NSError(domain: "Conversion", code: 3, userInfo: [NSLocalizedDescriptionKey: "FAILED TO FINALIZE GIF"])
        }
    }
}
