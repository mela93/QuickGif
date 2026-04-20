// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "QuickGif",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "QuickGif", targets: ["QuickGif"])
    ],
    targets: [
        .executableTarget(
            name: "QuickGif",
            path: "Sources/QuickGif"
        )
    ]
)
