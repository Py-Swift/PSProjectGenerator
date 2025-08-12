// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SetVersion",
    products: [
        // Products can be used to vend plugins, making them visible to other packages.
        .plugin(
            name: "SetVersion",
            targets: ["SetVersion"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .plugin(
            name: "SetVersion",
            capability: .command(intent: .custom(
                verb: "SetVersion",
                description: "prints hello world"
            ))
        ),
    ]
)
