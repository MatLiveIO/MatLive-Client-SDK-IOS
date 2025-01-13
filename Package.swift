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
        url: "https://github.com/anasamer1997/MyCocoapod/releases/download/v1.0.0/MatLiveClient.xcframework.zip", checksum: "813355eec7a659660b5c416bbc6f6d3b84f49ea93078ac40d3317e0ab8042080")
    ],
    swiftLanguageModes: [
        .v5,
    ]
)
