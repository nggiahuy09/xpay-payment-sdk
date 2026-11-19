// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xpay_payment_sdk",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "xpay-payment-sdk", targets: ["xpay_payment_sdk"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "xpay_payment_sdk",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
