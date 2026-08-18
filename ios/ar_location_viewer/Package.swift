// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ar_location_viewer",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "ar-location-viewer", targets: ["ar_location_viewer"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "ar_location_viewer",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
