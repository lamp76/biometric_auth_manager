// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BiometricCore",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "BiometricCore",
            type: .dynamic,
            targets: ["BiometricCore"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BiometricCore",
            dependencies: [],
            path: "Sources"
        )
    ]
)
