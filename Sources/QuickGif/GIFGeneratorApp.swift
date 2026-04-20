import SwiftUI

@main
struct GIFGeneratorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .onAppear {
                    NSApplication.shared.windows.forEach { window in
                        window.level = .floating
                        window.backgroundColor = .black
                        window.isOpaque = false
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            // 自定义菜单栏
            CommandGroup(replacing: .appInfo) {
                Button("About QuickGif") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
                                string: "A lightweight cyber-terminal style GIF generator.\n\nGitHub: https://github.com/mela93/QuickGif\nLicense: MIT",
                                attributes: [
                                    .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .regular),
                                    // .foregroundColor: NSColor(red: 0.22, green: 1.0, blue: 0.08, alpha: 1.0)
                                ]
                            ),
                            NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): "© 2026 QuickGif Contributors"
                        ]
                    )
                }
            }
        }
    }
}
