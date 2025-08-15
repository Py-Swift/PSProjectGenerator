// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PythonSwiftProject",
	platforms: [.macOS(.v13)],
	products: [
		.executable(name: "PSProjectCLI", targets: ["PythonSwiftProjectCLI"]),
		//.library(name: "PSProjectCLI", targets: ["PythonSwiftProjectCLI"]),
		.library(name: "PSProjectGen", targets: ["PSProjectGen"]),
	],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
		//.package(url: "https://github.com/tuist/XcodeProj.git", from: .init(8, 13, 0)),
		.package(url: "https://github.com/yonaskolb/XcodeGen.git", from: "2.42.0"),
		//.package(url: "https://github.com/1024jp/GzipSwift", from: .init(6, 0, 0)),
		.package(url: "https://github.com/marmelroy/Zip", from: .init(2, 1, 0)),
		.package(url: "https://github.com/swiftlang/swift-syntax.git", .upToNextMajor(from: .init(600, 0, 0))),
		.package(url: "https://github.com/jpsim/Yams.git", .upToNextMajor(from: "5.0.6")),
        //.package(url: "https://github.com/PythonSwiftLink/PyCodable", .upToNextMajor(from: "0.0.1")),
        .package(url: "https://github.com/py-swift/PySwiftKit", .upToNextMajor(from: "311.0.0")),
        //.package(url: "https://github.com/PythonSwiftLink/PythonCore", .upToNextMajor(from: "311.0.0")),
        //.package(url: "https://github.com/py-swift/PyCodable", .upToNextMajor(from: "0.0.0")),
        .package(url: "https://github.com/Py-Swift/XCAssetsProcessor", .upToNextMajor(from: "0.0.0")),
        .package(url: "https://github.com/tuist/XcodeProj.git", .upToNextMajor(from: "8.24.3")),
        .package(url: "https://github.com/kylef/PathKit", .upToNextMajor(from: "1.0.1")),
        //.package(url: "https://github.com/dduan/TOMLDecoder", from: "0.3.1"),
        .package(url: "https://github.com/LebJe/TOMLKit", .upToNextMajor(from: "0.6.0")),
        .package(url: "https://github.com/PerfectlySoft/Perfect-INIParser.git", from: "3.0.0"),
        .package(url: "https://github.com/ITzTravelInTime/SwiftCPUDetect.git", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-algorithms", .upToNextMajor(from: "1.2.1")),
		//.package(path: "/Volumes/CodeSSD/PythonSwiftGithub/PyCodable")
		//.package(url: "https://github.com/PythonSwiftLink/SwiftPackageGen", from: .init(0, 0, 3)),
		//.package(path: "/Volumes/CodeSSD/XcodeGithub/SwiftPackageGen")
        //.package(path: "/Volumes/CodeSSD/beeware_env/test_projects/github/PSBackend")
        .package(url: "https://github.com/Py-Swift/PSBackend", branch: "master"),
        .package(path: "./SetVersion")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PSProjectUpdate",
            dependencies: [
                .byName(name: "XCAssetsProcessor"),
                .byName(name: "XcodeProj"),
                .byName(name: "PathKit"),
                "PSProjectGen"
            ]
        ),
		.target(
			name: "PSProjectGen",
			
			dependencies: [
				.product(name: "XcodeGenKit", package: "XcodeGen"),
				.product(name: "ProjectSpec", package: "XcodeGen"),
				//.product(name: "Gzip", package: "GzipSwift"),
				.product(name: "Zip", package: "Zip"),
				.product(name: "SwiftSyntax", package: "swift-syntax"),
				.product(name: "SwiftParser", package: "swift-syntax"),
				//.product(name: "SwiftSyntaxParser", package: "swift-syntax"),
				.product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
				.product(name: "Yams", package: "Yams"),
                
                .product(name: "SwiftonizeModules", package: "PySwiftKit"),
                .product(name: "PyExecute", package: "PySwiftKit"),
                //.product(name: "PythonCore", package: "PythonCore"),
                //.product(name: "PyCodable", package: "PyCodable"),
                .byName(name: "XCAssetsProcessor"),
                .byName(name: "XcodeProj"),
                .byName(name: "TOMLKit"),
                .product(name: "INIParser", package: "perfect-iniparser"),
                .byName(name: "SwiftCPUDetect"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .byName(name: "PSBackend"),
                "PSTools"
				//.product(name: "RecipeBuilder", package: "SwiftPackageGen")
			],
			resources: [
				.copy("downloads.yml"),
				.copy("project_plist_keys.yml"),
                .copy("kivy_requirements.txt")
			]
			
			),
        .target(
            name: "PSTools",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftonizeModules", package: "PySwiftKit"),
                .byName(name: "TOMLKit"),
                .product(name: "INIParser", package: "perfect-iniparser"),
                .byName(name: "SwiftCPUDetect"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .byName(name: "PSBackend")
            ]
        ),
//		.executableTarget(
//			name: "PythonSwiftProjectGUI",
//			dependencies: [
//				"PSProjectGen",
//				.product(name: "Gzip", package: "GzipSwift"),
//				.product(name: "Zip", package: "Zip")
//			]
//		),
        .executableTarget(
            name: "PythonSwiftProjectCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
//				.product(name: "XcodeGenKit", package: "XcodeGen"),
//				.product(name: "ProjectSpec", package: "XcodeGen"),
				"PSProjectGen",
                "PSProjectUpdate",
				//.product(name: "Gzip", package: "GzipSwift"),
				.product(name: "Zip", package: "Zip"),
                .byName(name: "PSBackend"),
                "PSTools"
				//.product(name: "GeneratePackage", package: "SwiftPackageGen"),
				//.product(name: "RecipeBuilder", package: "SwiftPackageGen")
            ]
        ),
    ]
)
