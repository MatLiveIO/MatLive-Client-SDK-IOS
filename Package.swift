// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MatLive-Client-SDK-IOS",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MatLive-Client-SDK-IOS",
            targets: ["MatLive-Client-SDK-IOS"]),
    ],
    targets: [
      .binaryTarget(
        name: "MatLive-Client-SDK-IOS",
        path: "./Sources/MatLiveClient.xcframework")
    ],
    swiftLanguageModes: [
        .v5,
    ]
)
