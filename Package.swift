// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "its-notification-library",
    platforms: [
        .iOS(.v12) // Ensure this package targets iOS
    ],
    products: [
        .library(
            name: "its-notification-library",
            targets: ["its-notification-library"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),

    ],
    targets: [
        .target(
            name: "its-notification-library",
            dependencies: [
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
            ],
            resources: [
                .process("Resources/GoogleService-Info.plist") // Correct path to your plist file
                ]
        ),
        .testTarget(
            name: "its-notification-libraryTests",
            dependencies: ["its-notification-library"]
        ),
    ]
)
