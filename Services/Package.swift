// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Services",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Services",
            targets: ["Services"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.8.5"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMinor(from: "10.22.1")
        )
    ],
    targets: [
        .target(
            name: "Services",
            dependencies: [
                "CocoaLumberjack",
                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk")
            ],
            swiftSettings: [
                .define("FIREBASE_DISABLED")
            ]),
        .testTarget(
            name: "ServicesTests",
            dependencies: ["Services"]
        )
    ]
)
