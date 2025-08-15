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

extension PythonSwiftProjectCLI {
    
    struct Update: AsyncParsableCommand {
        @Argument var uv: Path
        
        func run() async throws {
            
            if !Validation.hostPython() { return }
            try Validation.backends()
            
            try launchPython()
            
            let toml_path = (uv.absolute() + "pyproject.toml")
            let toml = try TOMLDecoder().decode(PyProjectToml.self, from: try (toml_path).read())
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
            
            for platform in platforms {
                try await platform.pipInstall(requirements: req_file)
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


