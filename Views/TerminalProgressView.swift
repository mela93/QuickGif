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
