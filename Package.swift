// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "AppFramework",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AppFramework",
            type: .dynamic,
            targets: ["AppFramework"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AppFramework",
            dependencies: [],
            swiftSettings: [
                .define("SWIFT_PACKAGE")
            ])
    ]
)