// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Run",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc"),
        .package(url: "https://github.com/vapor-community/sendgrid-provider.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor-community/Imperial.git", from: "0.7.1")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentMySQL",
                                            "Vapor",
                                            "Leaf",
                                            "Authentication",
                                            "SendGrid",
                                            "Imperial"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
