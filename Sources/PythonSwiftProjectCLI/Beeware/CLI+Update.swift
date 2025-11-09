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


extension PythonSwiftProjectCLI {
    
    struct Update: AsyncParsableCommand {
        @Argument var uv: Path?
        
        func run() async throws {
            if !Validation.hostPython() { return }
            try Validation.backends()
            
            try launchPython()
            
            let uv = uv ?? .current
            
            let toml_path = (uv.absolute() + "pyproject.toml")
            let toml = try toml_path.loadPyProjectToml()
            
            guard let psproject = toml.tool?.psproject else {
                fatalError("tool.psproject in pyproject.toml not found")
            }
            
            let workingDir = uv + "project_dist/xcode"
            let platforms = try {
                var plats: [any ContextProtocol] = []
                if let ios = psproject.ios {
                    plats.append(try PlatformContext(arch: Archs.Arm64(), sdk: SDKS.IphoneOS(), root: workingDir))
                    switch arch_info {
                        case .intel64:
                            plats.append(try PlatformContext(arch: Archs.X86_64(), sdk: SDKS.IphoneSimulator(), root: workingDir))
                        case .arm64:
                            plats.append(try PlatformContext(arch: Archs.Arm64(), sdk: SDKS.IphoneSimulator(), root: workingDir))
                        default: break
                    }
                }
                
                if let macos = psproject.macos {
                    
                }
                
                
                return plats
            }().asChuckedTarget()
            
            let backends = try await psproject.loaded_backends()
            
            let req_string = try! await generateReqFromUV(toml: toml, uv: uv, backends: backends)
            let req_file = workingDir + "requirements.txt"
            try req_file.write(req_string)
            
            
            
            for (t, plats) in platforms {
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
        
    }
    
    struct Update2: AsyncParsableCommand {
        @Argument var uv: Path
        
        func run() async throws {
            
            if !Validation.hostPython() { return }
            try Validation.backends()
            
            try await launchPython()
            
            let toml_path = (uv.absolute() + "pyproject.toml")
            let toml = try TOMLDecoder().decode(PyProjectToml.self, from: try (toml_path).read())
            guard let pyswift_project = toml.tool?.psproject else {
                fatalError("tool.psproject in pyproject.toml not found")
            }
            //guard let folderName = pyswift_project?.folder_name else { return }
            
            let workingDir = uv + "platform_dists/iphone_macos/xcode"
            let platforms: [any ContextProtocol] = try await {
                var plats: [any ContextProtocol] = []
                if let ios = await pyswift_project.ios {
                    plats.append(try PlatformContext(arch: Archs.Arm64(), sdk: SDKS.IphoneOS(), root: workingDir))
                    switch arch_info {
                        case .intel64:
                            plats.append(try PlatformContext(arch: Archs.X86_64(), sdk: SDKS.IphoneSimulator(), root: workingDir))
                        case .arm64:
                            plats.append(try PlatformContext(arch: Archs.Arm64(), sdk: SDKS.IphoneSimulator(), root: workingDir))
                        default: break
                    }
                }
                
                if let macos = await pyswift_project.macos {
                    
                }
                
                
                return plats
            }()
            
            let req_string = try! await Self.generateReqFromUV(toml: toml, uv: uv)
            let req_file = workingDir + "requirements.txt"
            try req_file.write(req_string)
            
            let backends = try await pyswift_project.loaded_backends()
            
            for platform in platforms {
                
                    try await platform.pipUpdate(
                        requirements: req_file,
                        extra_index: pyswift_project.extra_index.resolve(prefix: uv.absolute())
                    )
                
                let site_path = platform.getSiteFolder()
                for backend in backends {
                    try await backend.copy_to_site_packages(site_path: .init(value: site_path), platform: platform.wheel_platform)
                }
            }
            
        }
        
        private static func generateReqFromUV(toml: PyProjectToml, uv: Path) async throws -> String {
            var req_String = await UVTool.export_requirements(uv_root: uv, group: "iphoneos")
            
            if let excludes = await toml.tool?.psproject?.exclude_dependencies, !excludes.isEmpty {
                let req_lines = req_String.split(separator: "\n").filter { line in
                    for exclude in excludes {
                        if line.starts(with: exclude) { return false }
                    }
                    return true
                }
                req_String = req_lines.joined(separator: "\n")
            }
                
//            let ios_pips = (toml.tool?.psproject?.ios?.
//                            
//                            ?? []).joined(separator: "\n")
//                req_String = "\(req_String)\n\(ios_pips)"
            
            print(req_String)
            return req_String
        }
    }
    
}


