// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "TrackingEngine",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "TrackingEngine",
            targets: ["TrackingEngine"]
        ),
        .library(
            name: "TrackingEngineCore",
            targets: ["TrackingEngineCore"]
        ),
    ],
    dependencies: [
        .package(
            name: "Firebase",
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .upToNextMajor(from: "12.0.0")
        )
    ],
    targets: [
        .target(
            name: "TrackingEngineCore",
            dependencies: [],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "TrackingEngine",
            dependencies: [
                "TrackingEngineCore",
                .product(
                    name: "FirebaseAnalytics",
                    package: "Firebase"
                ),
                .product(
                    name: "FirebaseCrashlytics",
                    package: "Firebase"
                )
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "TrackingEngineTests",
            dependencies: ["TrackingEngine", "TrackingEngineCore"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)
