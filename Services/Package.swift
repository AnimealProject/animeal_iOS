// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Services",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Services",
            targets: ["Services"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.7.0"),
        .package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "8.10.0")
        )
    ],
    targets: [
        .target(
            name: "Services",
            dependencies: [
                "CocoaLumberjack",
                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack"),
                .product(name: "FirebaseCrashlytics", package: "Firebase"),
                .product(name: "FirebaseAnalytics", package: "Firebase")
            ]),
        .testTarget(
            name: "ServicesTests",
            dependencies: ["Services"]
        )
    ]
)
