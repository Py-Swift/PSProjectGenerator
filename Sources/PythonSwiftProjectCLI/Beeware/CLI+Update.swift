//
//  CLI+Update.swift
//  PythonSwiftProject
//
import Foundation
import PathKit
import ArgumentParser
import PSProjectGen
import TOMLKit
import MachO
import SwiftCPUDetect
import PSTools
import PyProjectToml
import PSBackend
import PipRepo


fileprivate func infoTitle(title: String) -> String {
    var lines = [String]()
    let title_size = title.count
    
    let top_bot = String([Character](repeating: "#", count: title_size + 12))
    lines.append("")
    lines.append(top_bot)
    
    lines.append("##    \(title)    ##")
    lines.append(top_bot)
    lines.append("")
    return lines.joined(separator: "\n")
}


extension Tool.PSProject {
    func getXcodePlatforms(workingDir: Path) async throws -> [any ContextProtocol] {
        
            var plats: [any ContextProtocol] = []
            //guard let psproject = tool?.psproject else { return plats }
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
            
            if let macos  {
                
            }
            
            
            return plats
        
    }
}

extension PythonSwiftProjectCLI {
    
    struct Update: AsyncParsableCommand {
        
        static var configuration: CommandConfiguration { .init(
            subcommands: [
                App.self,
                Simple.self,
                SitePackages.self
            ],
            defaultSubcommand: SitePackages.self
        )}
        @MainActor
        static func updateSitePackages(uv: Path) async throws {
            
            
            //let uv = uv ?? .current
            
            let toml_path = (uv.absolute() + "pyproject.toml")
            let toml = try toml_path.loadPyProjectToml()
            
            guard let psproject = toml.tool?.psproject else {
                fatalError("tool.psproject in pyproject.toml not found")
            }
            
            let workingDir = uv + "project_dist/xcode"
            let platforms = try await psproject.getXcodePlatforms(workingDir: workingDir)
            
            let cplatforms = platforms.asChuckedTarget()
            
            let backends = try await psproject.loaded_backends()
            
            let req_string = try! await generateReqFromUV(toml: toml, uv: uv, backends: backends)
            let req_file = workingDir + "requirements.txt"
            try req_file.write(req_string)
            
            
            
            for (t, plats) in cplatforms {
                var extra_index: [String] = []
                if let psproject = toml.tool?.psproject {
                    extra_index.append(contentsOf: psproject.extra_index)
                    switch t {
                        case .iphoneos:
                            if let ios = psproject.ios {
                                extra_index.append(contentsOf: ios.extra_index)
                            }
                        case .macos:
                            if let macos = psproject.macos {
                                extra_index.append(contentsOf: macos.extra_index)
                            }
                    }
                }
                for platform in plats {
                    
                    try await platform.pipInstall(requirements: req_file, extra_index: extra_index)
                    
                    let site_path = FilePath(value: platform.getSiteFolder())
                    
                    for backend in backends {
                        try backend.copy_to_site_packages(site_path: site_path, platform: platform.wheel_platform)
                    }
                    
                    
                }
            }
        }
        
        
        static func cythonizeApp(uv: Path) async throws {
            
            
            let uv_abs = uv.absolute()
            let toml_path = (uv_abs + "pyproject.toml")
            let toml = try toml_path.loadPyProjectToml()
            
            guard let psproject = toml.tool?.psproject else {
                fatalError("tool.psproject in pyproject.toml not found")
            }
            
            guard psproject.cythonized else {
                print("app module is not configured as cythonizable")
                return
            }
            
            let workingDir = uv + "project_dist/xcode"
            guard workingDir.exists else {
                print("no xcode project found, ignoring cythonize")
                return
            }
            let platforms = try await psproject.getXcodePlatforms(workingDir: workingDir).asChuckedTarget()
            
            
            for (t, plats) in platforms {
                for platform in plats {
                    switch t {
                        case .iphoneos:
                            try ciBuildWheelApp(
                                src: uv,
                                output_dir: uv_abs + "wheels",
                                arch: "\(platform.arch.name)_\(platform.sdk.wheel_name)",
                                platform: "ios"
                            )
                        case .macos:
                            break
                    }
                }
            }
        }
        
        static func updateSimple(uv: Path) async throws {
            let uv_abs = uv.absolute()
            let toml_path = (uv_abs + "pyproject.toml")
            let toml = try toml_path.loadPyProjectToml()
            
            guard let psproject = toml.tool?.psproject else {
                fatalError("tool.psproject in pyproject.toml not found")
            }
            
            let cache_dir = uv_abs + "wheels"
            if !cache_dir.exists {
                try? cache_dir.mkdir()
            }
            
            let repo = try RepoFolder(root: cache_dir)
            try repo.generate_simple(output: cache_dir)
        }
    }
    
    
    
    
}


extension PythonSwiftProjectCLI.Update {
    
    struct App: AsyncParsableCommand {
        @Argument var uv: Path?
        
        func run() async throws {
            
            print(infoTitle(title: "Cythonize App Module"))
            
            if !Validation.hostPython() { return }
            try Validation.backends()
            
            try launchPython()
            
            try await PythonSwiftProjectCLI.Update.cythonizeApp(uv: uv ?? .current)
        }
    }
    
    struct SitePackages: AsyncParsableCommand {
        @Argument var uv: Path?
        
        func run() async throws {
            
            print(infoTitle(title: "Updating Site-Packages"))
            
            if !Validation.hostPython() { return }
            try Validation.backends()
            
            try launchPython()
            
            try await PythonSwiftProjectCLI.Update.updateSitePackages(uv: uv ?? .current)
        }
    }
    
    struct Simple: AsyncParsableCommand {
        @Argument var uv: Path?
        
        func run() async throws {
            
            print(infoTitle(title: "Updating Wheels Simple"))
            
            if !Validation.hostPython() { return }
            try Validation.backends()
            
            try launchPython()
            
            try await PythonSwiftProjectCLI.Update.updateSimple(uv: uv ?? .current)
            
        }
    }
}
