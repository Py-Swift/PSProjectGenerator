//
//  PackageTemplate.swift
//  PythonSwiftProject
//


import SwiftSyntax
import SwiftSyntaxBuilder
import PathKit


public class PackageTemplate {
    
    var name: String
    var resources: [String] = []
    var root: Path = .current
    
    
    
    var res_lines: String? {
        if resources.isEmpty { return nil }
        return resources.joined(separator: ",\n")
    }
    
    public init(name: String, resources: [String], root: Path) {
        self.name = name
        self.resources = resources
        self.root = root
    }
    
    var resourcesCode: CodeBlockItemListSyntax {
        if let res_lines {
            "\(raw: res_lines)"
        } else {
            ""
        }
    }
    
    var codeBlockList: CodeBlockItemListSyntax {
        """
        // swift-tools-version: 5.9
        // The swift-tools-version declares the minimum version of Swift required to build this package.

        import PackageDescription
        
        
        
        let package_dependencies: [Package.Dependency] = [
            .package(url: "https://github.com/kv-swift/PySwiftKit", from: .init(311, 0, 0)),
            .package(url: "https://github.com/py-swift/PyFileGenerator", from: .init(0, 0, 1)),
            // add other packages 
        ]
        
        
        
        let package_targets: [Target] = [
            .target(
                name: \(literal: name),
                dependencies: [
                    .product(name: "SwiftonizeModules", package: "PySwiftKit")
                    // add other package products or internal targets
                ],
                resources: [
                    \(raw: resourcesCode)
                ]
            )
        ]
        
        
        
        let package = Package(
            name: \(literal: name),
            platforms: [
                .iOS(.v13),
                .macOS(.v11)
            ],
            products: [
                // Products define the executables and libraries a package produces, making them visible to other packages.
                .library(
                    name: \(literal: name),
                    targets: [\(literal: name)]),
            ],
            dependencies: package_dependencies,
            targets: package_targets
        )
        """
    }
    
    public func code() -> String {
        codeBlockList.formatted().description
    }
    
    public func generate() throws {
        let root_path = root + name
        let package_file = root_path + "Package.swift"
        let sources = root_path + "Sources"
        let target_path = sources + name
        let target_file = target_path + "\(name).swift"
        
        
        try target_path.mkpath()
        try target_file.write("", encoding: .utf8)
        try package_file.write(code(), encoding: .utf8)
    }
}
