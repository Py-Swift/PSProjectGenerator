//
//  Context.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 03/08/2025.
//

@preconcurrency import PathKit
import Foundation
import PSTools
import PyProjectToml


public protocol ArchProtocol: Sendable {
    var name: String { get }
}

public struct Archs {
    public final class X86_64: ArchProtocol {
        public var name: String { "x86_64" }
        
        public init() {}
    }
    
    public final class Arm64: ArchProtocol {
        public var name: String { "arm64" }
        
        public init() {}
    }
    public final class Universal: ArchProtocol {
        public var name: String { "universal2" }
        
        public init() {}
    }
}

public enum XcodeTarget_Type: String {
    case iphoneos = "IphoneOS"
    case macos = "MacOS"
    
    public func targetPath(_ root: Path) -> Path {
        root + rawValue
    }
}

public protocol SDKProtocol: Sendable {
    var type: SDKS.SDKType { get }
    var name: String { get }
    var wheel_name: String { get }
    var min_os: String { get }
    
    var xcode_target: String { get }
}

extension SDKProtocol {
    public var name: String { type.rawValue }
}

public struct SDKS {
    public enum SDKType: String, Sendable, Codable {
        case iphoneos
        case iphonesimulator
        case macos
    }
    public final class IphoneOS: SDKProtocol {
        public var type: SDKType { .iphoneos }
        public var wheel_name: String { name }
        public var min_os: String { "13_0" }
        public var xcode_target: String { "IphoneOS"}
        
        public init() {}
    }
    
    public final class IphoneSimulator: SDKProtocol {
        public var type: SDKType { .iphonesimulator }
        public var wheel_name: String { name }
        public var min_os: String { "13_0" }
        public var xcode_target: String { "IphoneOS"}
        
        public init() {}
    }
    
    public final class MacOS: SDKProtocol {
        public var type: SDKType { .macos }
        public var wheel_name: String { "macosx" }
        public var min_os: String { "10_15" }
        public var xcode_target: String { "MacOS"}
        
        public init() {}
    }
}

public protocol ContextProtocol: Sendable {
    
    associatedtype Arch: ArchProtocol
    associatedtype SDK: SDKProtocol
    var arch: Arch { get }
    var sdk: SDK { get }
    var root: Path { get }
    
    var python3: Path { get }
    var pip3: Path { get }
    
    var wheel_platform: String { get }
    
    func getSiteFolder() -> Path
    
    func getTargetFolder() -> Path
    
    func getResourcesFolder() -> Path
    
    func getSourcesFolder() -> Path
    
    func createSiteFolder(forced: Bool) async throws
    
    func createTargetFolder(forced: Bool) async throws
    
    func createResourcesFolder(forced: Bool) async throws
    
    //@MainActor
    func pipInstall(requirements: Path, extra_index: [String]) async throws
    
    func pipDownload(requirements: Path, extra_index: [String], to destination: Path) async throws
    
    func pipUpdate(requirements: Path, extra_index: [String]) async throws
    
    func validatePips(requirements: Path, extra_index: [String]) async throws -> Int32
    
    
}

extension ContextProtocol {
    public var wheel_platform: String {
        "ios_\(sdk.min_os)_\(arch.name)_\(sdk.name)"
    }
    
    public var xcode_target: String { sdk.xcode_target }
    
    public func createSiteFolder(forced: Bool = false) async throws {
        let site = getSiteFolder()
        if site.exists { return }
        try site.mkdir()
    }
    
    public func createTargetFolder(forced: Bool = false) async throws {
        let target = getTargetFolder()
        if target.exists { return }
        try target.mkdir()
    }
    
    public func createResourcesFolder(forced: Bool = false) async throws {
        let target = getResourcesFolder()
        if target.exists { return }
        try target.mkdir()
    }
    
    public func createSourcesFolder(forced: Bool = false) async throws {
        let target = getSourcesFolder()
        if target.exists { return }
        try target.mkdir()
    }
}

extension ContextProtocol where SDK == SDKS.MacOS {
    
    public var wheel_platform: String {
        "\(sdk.wheel_name)-\(sdk.min_os)-\(arch.name)"
    }
    
}


extension Array where Element == any ContextProtocol {
    public func asChuckedTarget() -> [(XcodeTarget_Type, Array<any ContextProtocol>.SubSequence)] {
        chunked(on: \.xcode_target).compactMap({ target,plats in
            if let target = XcodeTarget_Type(rawValue: target) {
                (target, plats)
            } else {
                nil
            }
        })
    }
}

public final class PlatformContext<Arch, SDK>: ContextProtocol where Arch: ArchProtocol, SDK: SDKProtocol {
    
    
    
    public let arch: Arch
    
    public let sdk: SDK
    
    public let root: Path
    
    public let pip3: Path = .hostPython + "bin/pip3"//"/Users/Shared/psproject/hostpython3/bin/pip3"
    public let python3: Path = .hostPython + "bin/python3"//"/Users/Shared/psproject/hostpython3/bin/python3"
    
    public init(arch: Arch, sdk: SDK, root: Path) throws {
        
        guard root.exists else { throw ContextError.pathRootMissing(root) }
        
        self.arch = arch
        self.sdk = sdk
        self.root = root
    }
    
    public var site_folder_name: String {
        "site_packages.\(sdk.name)"
    }
    
    
}

extension PlatformContext {
    public enum ContextError: Error {
        case pathRootMissing(_ path: Path)
    }
}

public extension PlatformContext {
    
    func getResourcesFolder() -> Path {
        
        return getTargetFolder() + "Resources"
    }
    
    func getSiteFolder() -> Path {
        
        return root + site_folder_name
    }
    
    func getTargetFolder() -> Path {
        
        return root + sdk.xcode_target
    }
    
    func getSourcesFolder() -> Path {
        getTargetFolder() + "Sources"
    }
}


public extension PlatformContext {

}


extension PlatformContext {
    
    public func validatePips(requirements: Path) async throws -> Int32 {
        print(wheel_platform)
        let task = Process()
        
        task.arguments = [
            "install",
            "--disable-pip-version-check",
            "--platform=\(wheel_platform)",
            "--only-binary=:all:",
            
            "--extra-index-url",
            "https://pypi.anaconda.org/beeware/simple",
            "--extra-index-url",
            "https://pypi.anaconda.org/pyswift/simple",
            "--target", getSiteFolder().string,
            "-r", requirements.string,
            "--dry-run"
        ]
        task.executablePath = pip3
        task.standardInput = nil
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
    
    public func validatePips(requirements: Path, extra_index: [String]) async throws -> Int32 {
        print(wheel_platform)
        let task = Process()
        
        var arguments: [String] = [
            "install",
            "--disable-pip-version-check",
            "--platform=\(wheel_platform)",
            "--only-binary=:all:",
        ]
        
        arguments.append(contentsOf: extra_index.map { index in
            ["--extra-index-url", index]
        }.flatMap(\.self))
        
        arguments.append(contentsOf: [
            "--target", getSiteFolder().string,
            "-r", requirements.string,
            "--dry-run"
        ])
        
        task.arguments = arguments
        task.executablePath = pip3
        task.standardInput = nil
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
    
    public func pipInstall(requirements: Path) async throws {
        let task = Process()
        
        task.arguments = [
            "install",
            "--disable-pip-version-check",
            "--platform=\(wheel_platform)",
            "--only-binary=:all:",
            "--extra-index-url",
            "https://pypi.anaconda.org/beeware/simple",
            "--extra-index-url",
            "https://pypi.anaconda.org/pyswift/simple",
            "--target", getSiteFolder().string,
            "-r", requirements.string,
            
        ]
        task.executablePath = pip3
        task.standardInput = nil
        task.launch()
        task.waitUntilExit()
    }
    
    public func pipInstall(requirements: Path, extra_index: [String]) async throws {
        let task = Process()
        
        var arguments: [String] = [
            "install",
            "--disable-pip-version-check",
            "--platform=\(wheel_platform)",
            "--only-binary=:all:",
            //"--abi=cp313-cp313"
            "--python-version=313"
        ]
        
        arguments.append(contentsOf: extra_index.map { index in
            ["--extra-index-url", index]
        }.flatMap(\.self))
        
        arguments.append(contentsOf: [
            "--target", getSiteFolder().string,
            "-r", requirements.string
        ])
        task.arguments = arguments
        task.executablePath = pip3
        task.standardInput = nil
        task.launch()
        task.waitUntilExit()
        
    }
    
    
    public func pipDownload(requirements: Path, extra_index: [String], to destination: Path) async throws {
        let task = Process()
        
        var arguments: [String] = [
            "download",
            "--disable-pip-version-check",
            "--platform=\(wheel_platform)",
            "--only-binary=:all:",
            //"--abi=cp313-cp313"
            "--python-version=313"
        ]
        
        arguments.append(contentsOf: extra_index.map { index in
            ["--extra-index-url", index]
        }.flatMap(\.self))
        
        arguments.append(contentsOf: [
            "--dest", destination.string,
            "-r", requirements.string
        ])
        
        task.arguments = arguments
        task.executablePath = pip3
        task.standardInput = nil
        task.launch()
        task.waitUntilExit()
    }
    
    public func pipUpdate(requirements: Path, extra_index: [String]) async throws {
        let task = Process()
        
        var arguments: [String] = [
            "install",
            "--upgrade",
            "--disable-pip-version-check",
            "--platform=\(wheel_platform)",
            "--only-binary=:all:",
            //"--abi=cp313-cp313"
            "--python-version=313"
        ]
        
        arguments.append(contentsOf: extra_index.map { index in
            ["--extra-index-url", index]
        }.flatMap(\.self))
        
        arguments.append(contentsOf: [
            "--target", getSiteFolder().string,
            "-r", requirements.string
        ])
        task.arguments = arguments
        task.executablePath = pip3
        task.standardInput = nil
        task.launch()
        task.waitUntilExit()
    }
}

extension PlatformContext where SDK == SDKS.MacOS {
    public func pipInstall(requirements: Path) async throws {
        print(PSTools.pipInstall(requirements, site_path: getSiteFolder()))
    }
}


extension Tool.PSProject {
    public func contextPlatforms(workingDir: Path) throws -> [any ContextProtocol] {
        var plats: [any ContextProtocol] = []
        
        if let ios {
            plats.append(try PlatformContext(arch: Archs.Arm64(), sdk: SDKS.IphoneOS(), root: workingDir))
            switch arch_info {
                case .intel64:
                    plats.append(try PlatformContext(arch: Archs.X86_64(), sdk: SDKS.IphoneSimulator(), root: workingDir))
                case .arm64:
                    plats.append(try PlatformContext(arch: Archs.Arm64(), sdk: SDKS.IphoneSimulator(), root: workingDir))
                default: break
            }
        }
        
        if let macos {
            
        }
        
        return plats
    }
    
    
}
