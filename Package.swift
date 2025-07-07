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
        .package(url: "https://github.com/crowdconnected/crowdconnected-shared-ios", exact: "1.6.8"),
        .package(url: "https://github.com/crowdconnected/crowdconnected-core-ios", exact: "1.6.8"),
        .package(url: "https://github.com/crowdconnected/crowdconnected-ips-ios", exact: "1.6.8"),
        .package(url: "https://github.com/crowdconnected/crowdconnected-geo-ios", exact: "1.6.8"),
        .package(url: "https://github.com/expofp/expofp-sdk-ios", from: "5.1.0"),
    ],
    targets: [
        .target(
            name: "ExpoFpCrowdConnected",
            dependencies: [
                .product(name: "CrowdConnectedShared", package: "crowdconnected-shared-ios"),
                .product(name: "CrowdConnectedCore", package: "crowdconnected-core-ios"),
                .product(name: "CrowdConnectedIPS", package: "crowdconnected-ips-ios"),
                .product(name: "CrowdConnectedGeo", package: "crowdconnected-geo-ios"),
                .product(name: "ExpoFP", package: "expofp-sdk-ios"),
            ],
            path: "ExpoFpCrowdConnected"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
