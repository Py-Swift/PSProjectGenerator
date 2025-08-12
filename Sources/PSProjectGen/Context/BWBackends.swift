//
//  BWBackends.swift
//  PythonSwiftProject
//
import Foundation
import PathKit
import ArgumentParser
import XcodeGenKit
import ProjectSpec

public struct BWBackend {
    
    public enum Name: String, CaseIterable {
        case kivylauncher
        case sdl2
        case swiftui
        case admob4kivy
        
    }
    
    public protocol BackendProtocol {
        static func new() -> Self
        
        func url() -> URL?
        
        func frameworks() async throws -> [Path]
        
        func downloads() async throws -> [URL]
        
        func config(root: Path) async throws
        
        func packages() -> [String:SwiftPackage]
        
        func target_dependencies(target_type: XcodeTarget_Type) async throws -> [Dependency]
        
        func install(support: Path) async throws
        
        
    }
    
    public protocol PyPiProtocol: BackendProtocol {
        
    }
}

extension BWBackend.PyPiProtocol {
    public func downloads() async throws -> [URL] {
        return []
    }
}


public extension BWBackend {
    class SDL2: PyPiProtocol {
        
        required init() {
            
        }
        
        
        public static func new() -> Self {
            .init()
        }
        
        public func url() -> URL? {
            nil
        }
        
        public func frameworks() async throws -> [PathKit.Path] {
        
            let sdl2_fw = try await Path.sdl2_frameworks()
            return [
                (sdl2_fw + "SDL2.xcframework"),
                (sdl2_fw + "SDL2_image.xcframework"),
                (sdl2_fw + "SDL2_mixer.xcframework"),
                (sdl2_fw + "SDL2_ttf.xcframework")
            ]
        }
        
        public func packages() -> [String : SwiftPackage] {
            [:]
        }
        
        public func config(root: Path) async throws {
            
        }
        
        public func install(support: Path) async throws {
            let sdl2_frameworks = Path.ps_support + "sdl2_frameworks"
            var download_required = false
            
            let sdl_fws = try await frameworks()
            for whl in sdl_fws {
                if !whl.exists {
                    download_required = true
                    break
                }
            }
            
            if download_required {
                try? sdl2_frameworks.mkpath()
                print(pipInstall(pip: "kivy_sdl2", site_path: sdl2_frameworks))
            }
            
            for framework in sdl_fws {
                try framework.copy(support + framework.lastComponent)
            }
            
        }
        
        public func target_dependencies(target_type: XcodeTarget_Type) async throws -> [Dependency] {
            switch target_type {
            case .iphoneos:
                try await frameworks().map { fw in
                    //.init(type: .framework, reference: fw.lastComponent)
                    .init(type: .framework, reference: "Support\(fw.lastComponent)", embed: true, codeSign: true)
                }
            case .macos:
                []
            }
            
        }
        
    }
    
    class Kivy: SDL2 {
        
        
        public override func packages() -> [String : SwiftPackage] {
            let local = true
            return if local {
                ["KivyLauncher": .local(path: "/Volumes/CodeSSD/beeware_env/swift_packages/KivyLauncher", group: nil, excludeFromProject: false)]
            } else {
                ["KivyLauncher": .remote(url: "https://github.com/KivySwiftPackages/KivyLauncher", versionRequirement: .upToNextMinorVersion("311.0.0"))]
            }
        }
        
        public override func target_dependencies(target_type: XcodeTarget_Type) async throws -> [Dependency] {
            try await super.target_dependencies(target_type: target_type) + [
                .init(type: .package(products: ["KivyLauncher"]), reference: "KivyLauncher")
            ]
        }
    }
    
    class Admob4Kivy: PyPiProtocol {
        
        required init() {
            
        }
        
        
        public static func new() -> Self {
            .init()
        }
        
        public func url() -> URL? {
            nil
        }
        
        public func frameworks() async throws -> [PathKit.Path] {
            return [
                
            ]
        }
        
        public func packages() -> [String : SwiftPackage] {
            [
                "a4k_pyswift": .remote(
                    url: "https://github.com/KivySwiftPackages/a4k_pyswift",
                    versionRequirement: .upToNextMinorVersion("311.0.0")
                )
            ]
        }
        
        public func config(root: Path) async throws {
            
        }
        
        public func install(support: Path) async throws {
      
        }
        
        public func target_dependencies(target_type: XcodeTarget_Type) async throws -> [Dependency] {
            []
        }
        
    }
}


public extension BWBackend {
    class SwiftUI: PyPiProtocol {
        
        required init() {
            
        }
        
        
        public static func new() -> Self {
            .init()
        }
        
        public func url() -> URL? {
            nil
        }
        
        public func frameworks() async throws -> [PathKit.Path] {
            return [
                
            ]
        }
        
        public func packages() -> [String : SwiftPackage] {
            [:]
        }
        
        public func config(root: Path) async throws {
            
        }
        
        public func install(support: Path) async throws {
    
        }
        
        public func target_dependencies(target_type: XcodeTarget_Type) async throws -> [Dependency] {
            []
        }
    }
}
