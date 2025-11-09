//
//  AppPackageTemplate.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 12/06/2025.
//


import SwiftSyntax
import SwiftSyntaxBuilder
import PathKit


public class AppPackageTemplate {
    
    var name: String
    var resources: [String] = []
    var root: Path = .current
    
    
    
    var res_lines: String? {
        if resources.isEmpty { return nil }
        return resources.joined(separator: ",\n")
    }
    
    public init(name: String) {
        self.name = name
    }
    
    var resourcesCode: CodeBlockItemListSyntax {
        if let res_lines {
            """
            ,
            resources: [
            \(raw: res_lines)
            ]
            """
        } else {
            ""
        }
    }
    
    var codeBlockList: CodeBlockItemListSyntax {
        """
        // swift-tools-version: 5.9
        // The swift-tools-version declares the minimum version of Swift required to build this package.

        import PackageDescription
        
        let package_deps: [Package.Dependency] = [
            .package(url: "https://github.com/kv-swift/PySwiftKit", from: .init(311, 0, 0)),
            .package(url: "https://github.com/py-swift/PyFileGenerator", from: .init(0, 0, 1)),
            // add other packages 
        ]
        
        let package = Package(
            name: \(literal: name),
            platforms: [
                .iOS(.v16),
                .macOS(.v13)
            ],
            products: [
                // Products define the executables and libraries a package produces, making them visible to other packages.
                .library(
                    name: \(literal: name),
                    targets: [\(literal: name)]),
            ],
            dependencies: package_deps,
            targets: [
                .target(
                    name: \(literal: name),
                    dependencies: [
                        .product(name: "PySwiftKitBase", package: "PySwiftKit")
                    ]\(raw: resourcesCode)
                ),
            ]
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
        //let site_packages = target_path + "site-packages"
        let target_file = target_path + "\(name).swift"
        
        
        try target_path.mkpath()
        try target_file.write("", encoding: .utf8)
        try package_file.write(code(), encoding: .utf8)
    }
}
