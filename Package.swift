// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MatLiveClientSDK",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MatLiveClientSDK",
            targets: ["MatLiveClientSDK"]),
    ],
    dependencies: [
        .package(name: "LiveKit", url: "https://github.com/livekit/client-sdk-swift.git", .upToNextMajor(from: "2.0.19")),
    ],
    targets: [
      .binaryTarget(
        name: "MatLiveClientSDK",
        path: "./Sources/MatLiveClient.xcframework")
    ],
    swiftLanguageModes: [
        .v5,
    ]
)
