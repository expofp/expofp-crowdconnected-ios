// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExpoFpCrowdConnected",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "ExpoFpCrowdConnected",
            targets: ["ExpoFpCrowdConnected"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/crowdconnected/crowdconnected-sdk-swift-spm", exact: "2.2.1"),
        .package(url: "https://github.com/expofp/expofp-sdk-ios", from: "5.4.0"),
    ],
    targets: [
        .target(
            name: "ExpoFpCrowdConnected",
            dependencies: [
                .product(name: "CrowdConnectedCore", package: "crowdconnected-sdk-swift-spm"),
                .product(name: "CrowdConnectedCoreBluetooth", package: "crowdconnected-sdk-swift-spm"),
                .product(name: "CrowdConnectedGeo", package: "crowdconnected-sdk-swift-spm"),
                .product(name: "CrowdConnectedIPS", package: "crowdconnected-sdk-swift-spm"),
                .product(name: "CrowdConnectedShared", package: "crowdconnected-sdk-swift-spm"),
                .product(name: "ExpoFP", package: "expofp-sdk-ios"),
            ],
            path: "ExpoFpCrowdConnected"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
