// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FcmPlugin",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "FcmPlugin",
            targets: ["FcmPlugin"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/tauri-apps/tauri", from: "2.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0")
    ],
    targets: [
        .target(
            name: "FcmPlugin",
            dependencies: [
                .product(name: "Tauri", package: "tauri"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk")
            ]
        )
    ]
)
