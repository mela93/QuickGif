import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
    @ObservedObject var viewModel: ConversionViewModel
    @State private var isTargeted = false
    
    var body: some View {
        ZStack {
            // 背景层：纯黑 + 极暗材质
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black) // 强制纯黑
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial) // 叠加一层玻璃感
                        .opacity(0.3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            isTargeted ? Color.white : Color(red: 0.22, green: 1.0, blue: 0.08),
                            style: StrokeStyle(lineWidth: 2, dash: [10, 5])
                        )
                        .glow(color: Color(red: 0.22, green: 1.0, blue: 0.08), radius: isTargeted ? 12 : 6)
                )
                .shadow(color: .black, radius: 20)
            
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
                        .padding(.bottom, 5)
                    
                    Text("[ DRAG & DROP ]")
                        .font(.system(.body, design: .monospaced))
                        .tracking(2)
                    
                    Text("SUPPORTED: MP4, MOV, JPG, PNG")
                        .font(.system(size: 10, design: .monospaced))
                        .opacity(0.6)
                }
            }
            .foregroundColor(Color(red: 0.22, green: 1.0, blue: 0.08))
        }
        .padding(20)
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            guard let provider = providers.first else { return false }
            
            // 使用 loadItem 这种更底层的方式来确保获取 URL
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (data, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Drop error: \(error)")
                        return
                    }
                    
                    if let data = data as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                        print("File dropped: \(url.path)")
                        viewModel.convert(inputURL: url)
                    } else if let url = data as? URL {
                        print("File dropped: \(url.path)")
                        viewModel.convert(inputURL: url)
                    }
                }
            }
            return true
        }
    }
}

extension View {
    func glow(color: Color, radius: CGFloat = 8) -> some View {
        self.shadow(color: color.opacity(0.8), radius: radius)
            .shadow(color: color.opacity(0.4), radius: radius / 2)
    }
}
