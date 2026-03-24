// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "gf-alert",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "gf-alert",
            path: "Sources/GFAlert"
        )
    ]
)
