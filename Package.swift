// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Clocked",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "Clocked",
            path: "Sources/Clocked"
        )
    ]
)