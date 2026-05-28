// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "TrackingEngine",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "TrackingEngine", targets: ["TrackingEngine"]),
        .library(name: "TrackingEngineCore", targets: ["TrackingEngineCore"]),
    ],
    dependencies: [
        .package(name: "Firebase",
                 url: "https://github.com/firebase/firebase-ios-sdk.git",
                 .upToNextMajor(from: "12.0.0"))
    ],
    targets: [
        .target(
            name: "TrackingEngineCore",
            dependencies: []
        ),
        .target(
            name: "TrackingEngine",
            dependencies: [
                "TrackingEngineCore",
                .product(name: "FirebaseAnalytics", package: "Firebase"),
                .product(name: "FirebaseCrashlytics", package: "Firebase")
            ]
        ),
        .testTarget(
            name: "TrackingEngineTests",
            dependencies: ["TrackingEngine", "TrackingEngineCore"]
        ),
    ]
)
