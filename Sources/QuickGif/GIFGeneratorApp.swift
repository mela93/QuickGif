import SwiftUI

@main
struct GIFGeneratorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark) // 强制深色模式
                .onAppear {
                    NSApplication.shared.windows.forEach { window in
                        window.level = .floating
                        window.backgroundColor = .black // 设置窗口底色为纯黑
                        window.isOpaque = false
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
