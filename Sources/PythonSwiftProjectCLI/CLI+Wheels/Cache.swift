//
//  Cache.swift
//  PSProjectGenerator
//

import Foundation
import ArgumentParser
import PathKit
import PSProjectGen
import Zip
import TOMLKit
import PSTools
import PipRepo

extension PythonSwiftProjectCLI.Wheels {
    
    struct Cache: AsyncParsableCommand {
        
        @Argument var uv: Path
        
        func run() async throws {
            
            if !Validation.hostPython() { return }
            try Validation.backends()
            
            try launchPython()
            let uv_abs = uv.absolute()
            let toml_path = (uv_abs + "pyproject.toml")
            let toml = try TOMLDecoder().decode(PyProjectToml.self, from: try (toml_path).read())
            toml.root = uv
            let pyswift_project = toml.pyswift.project
            guard let folderName = pyswift_project?.folder_name else { return }
            let workingDir = (uv.parent()) + folderName
            let platforms: [any ContextProtocol] = try {
                var plats: [any ContextProtocol] = []
                for p in pyswift_project?.platforms ?? [] {
                    switch p {
                    case .iphoneos:
                        plats.append(try PlatformContext(arch: Archs.Arm64(), sdk: SDKS.IphoneOS(), root: workingDir))
                        switch arch_info {
                        case .intel64:
                            plats.append(try PlatformContext(arch: Archs.X86_64(), sdk: SDKS.IphoneSimulator(), root: workingDir))
                        case .arm64:
                            plats.append(try PlatformContext(arch: Archs.Arm64(), sdk: SDKS.IphoneSimulator(), root: workingDir))
                        default: break
                        }
                    case .macos:
                        break
                    }
                }
                
                return plats
            }()
            
            let req_string = try! await Self.generateReqFromUV(toml: toml, uv: uv)
            let req_file = workingDir + "requirements.txt"
            try req_file.write(req_string)
            
            //let backends = try await pyswift_project?.loaded_backends() ?? []
            
            
            if let pyswift_project {
                let cache_dir = Path((pyswift_project.wheel_cache_dir ?? ".wheels").resolve_path(prefix: uv_abs, file_url: false))
                if !cache_dir.exists {
                    try cache_dir.mkpath()
                }
                
                let extra_index = pyswift_project.extra_index.filter({$0.hasPrefix("https")})
                for platform in platforms {
                    try await platform.pipDownload(
                        requirements: req_file,
                        extra_index: extra_index,
                        to: cache_dir
                    )
                }
                let repo = try RepoFolder(root: cache_dir)
                try repo.generate_simple(output: cache_dir)
            }
            
            
            
        }
        
        private static func generateReqFromUV(toml: PyProjectToml, uv: Path) async throws -> String {
            var req_String = UVTool.export_requirements(uv_root: uv, group: "iphoneos")
            
            
                let ios_pips = (toml.pyswift.project?.dependencies?.pips ?? []).joined(separator: "\n")
                req_String = "\(req_String)\n\(ios_pips)"
            
            print(req_String)
            return req_String
        }
    }
}
