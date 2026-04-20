import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ConversionViewModel()
    
    var body: some View {
        DropZoneView(viewModel: viewModel)
            .frame(width: 300, height: 200)
    }
}
