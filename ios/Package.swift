// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "biometric_auth_manager",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "biometric-auth-manager",
            targets: ["biometric_auth_manager"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "biometric_auth_manager",
            dependencies: [
                "BiometricCore"
            ],
            path: "Classes"
        ),
        .binaryTarget(
            name: "BiometricCore",
            path: "Frameworks/BiometricCore.xcframework"
        )
    ]
)
