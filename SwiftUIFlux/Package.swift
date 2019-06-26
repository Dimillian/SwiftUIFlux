// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIFlux",
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
    ]
)
