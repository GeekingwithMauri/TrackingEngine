// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TrackingEngine",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "TrackingEngineCore", targets: ["TrackingEngineCore"]),
        .library(name: "TrackingEngine",     targets: ["TrackingEngine"]),
    ],
    dependencies: [
        .package(name: "Firebase",
                 url: "https://github.com/firebase/firebase-ios-sdk.git",
                 .upToNextMajor(from: "12.0.0"))
    ],
    targets: [
        .target(name: "TrackingEngineCore", dependencies: []),
        .target(
            name: "TrackingEngine",
            dependencies: [
                "TrackingEngineCore",
                .product(name: "FirebaseAnalytics",   package: "Firebase"),
                .product(name: "FirebaseCrashlytics", package: "Firebase"),
            ]
        ),
        .testTarget(name: "TrackingEngineTests", dependencies: ["TrackingEngine"]),
    ]
)
