import PackagePlugin
import Foundation

@main
struct SetVersion: CommandPlugin {
    // Entry point for command plugins applied to Swift Packages.
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        print("SetVersion", arguments)
        let argc = arguments.count
        guard argc >= 3 else { fatalError("SetVersion wanted 3 arguments got \(argc)")}
        var arguments = Array(arguments.dropFirst(argc - 2))
        guard let version = arguments.popLast() else { return }
        for target in try context.package.targets(named: arguments) {
            if let version_swift = target.sourceModule?.sourceFiles.first(where: {$0.path.lastComponent == "Version.swift"}) {
                try "public let LIBRARY_VERSION = \"\(version)\"".write(toFile: version_swift.path.string, atomically: true, encoding: .utf8)
            }
        }
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SetVersion: XcodeCommandPlugin {
    // Entry point for command plugins applied to Xcode projects.
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        print("Hello, World!")
    }
}

#endif
