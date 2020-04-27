// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIFlux",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SwiftUIFlux",
            targets: ["SwiftUIFlux"]),
    ],
    targets: [
        .target(
            name: "SwiftUIFlux",
            dependencies: []),
        .testTarget(
            name: "SwiftUIFluxTests",
            dependencies: ["SwiftUIFlux"]),
    ],
    swiftLanguageVersions: [
        .version("5")
    ]
)
