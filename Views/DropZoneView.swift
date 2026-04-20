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
            guard let provider = providers.first else { return false }
            
            _ = provider.loadObject(ofClass: URL.self) { url, error in
                if let url = url {
                    DispatchQueue.main.async {
                        viewModel.convert(videoURL: url)
                    }
                }
            }
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
