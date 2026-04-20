import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
    @ObservedObject var viewModel: ConversionViewModel
    @State private var isTargeted = false
    
    var body: some View {
        ZStack {
            // 背景层：纯黑 + 极暗材质
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .opacity(0.3)
                )
                .overlay(
                    Group {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                isTargeted ? Color.white : Color(red: 0.22, green: 1.0, blue: 0.08),
                                style: StrokeStyle(lineWidth: 2, dash: [10, 5])
                            )
                    }
                    .glow(color: Color(red: 0.22, green: 1.0, blue: 0.08), radius: isTargeted ? 12 : 6)
                )
            
            VStack(spacing: 16) {
                if let error = viewModel.lastError {
                    Text("[!] ERROR")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.red)
                    Text(error)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else if viewModel.isProcessing {
                    Text(viewModel.statusText)
                        .glow(color: Color(red: 0.22, green: 1.0, blue: 0.08))
                    TerminalProgressView(progress: viewModel.progress)
                } else {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 30))
                    
                    Text("[ DRAG & DROP ]")
                        .font(.system(.body, design: .monospaced))
                        .tracking(2)
                }
            }
            .foregroundColor(Color(red: 0.22, green: 1.0, blue: 0.08))
        }
        .padding(20)
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            guard let provider = providers.first else { return false }
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (data, error) in
                DispatchQueue.main.async {
                    if let data = data as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                        viewModel.convert(inputURL: url)
                    } else if let url = data as? URL {
                        viewModel.convert(inputURL: url)
                    }
                }
            }
            return true
        }
    }
}

// 辅助发光效果扩展
extension View {
    func glow(color: Color, radius: CGFloat = 8) -> some View {
        self.shadow(color: color.opacity(0.8), radius: radius)
            .shadow(color: color.opacity(0.4), radius: radius / 2)
    }
}
