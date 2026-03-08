// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Keystroke",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "Keystroke",
            path: "Sources/Keystroke"
        ),
        .testTarget(
            name: "KeystrokeTests",
            dependencies: ["Keystroke"],
            path: "Tests/KeystrokeTests"
        ),
    ]
)
