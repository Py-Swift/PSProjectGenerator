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
import PyProjectToml

extension Path: @unchecked Swift.Sendable {}

extension PythonSwiftProjectCLI.Wheels {
    
    struct Cache: AsyncParsableCommand {
        
        
        static let configuration: CommandConfiguration = .init(subcommands: [
            Download.self,
            Update.self
        ])
        
        struct Download: AsyncParsableCommand {
            
            @Argument var uv: Path
            
            func run() async throws {
                
                if !Validation.hostPython() { return }
                try Validation.backends()
                
                try launchPython()
                let uv_abs = uv.absolute()
                let toml_path = (uv_abs + "pyproject.toml")
                
                //let toml = try TOMLDecoder().decode(PyProjectToml.self, from: try (toml_path).read())
                let toml = try toml_path.loadPyProjectToml()
                toml.root = uv
                
                guard
                    let pyswift_project = toml.tool?.psproject,
                    //let folderName = await pyswift_project.folder_name
                    let workingDir = await pyswift_project.ios?.get_project_root(root: uv)
                else { return }
                
                //(uv.parent()) + folderName
                
                
                let req_string = try! await Self.generateReqFromUV(toml: toml, uv: uv)
                let req_file = workingDir + "requirements.txt"
                try req_file.write(req_string)
                
                //let backends = try await pyswift_project?.loaded_backends() ?? []
                
                let cache_dir = await Path((pyswift_project.wheel_cache_dir ?? ".wheels").resolve_path(prefix: uv_abs, file_url: false))
                if !cache_dir.exists {
                    try cache_dir.mkpath()
                }
                
                let extra_index = await pyswift_project.extra_index.filter({$0.hasPrefix("https")})
                
                let platforms: [any ContextProtocol] = try await  pyswift_project.contextPlatforms(workingDir: workingDir)
                
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
            
            //@MainActor
            private static func generateReqFromUV(toml: PyProjectToml, uv: Path) async throws -> String {
                var req_String = await UVTool.export_requirements(uv_root: uv, group: "iphoneos")
                
                
//                let ios_pips = (toml.pyswift.project?.dependencies?.pips ?? []).joined(separator: "\n")
//                req_String = "\(req_String)\n\(ios_pips)"
                
                print(req_String)
                return req_String
            }
        }
        
        struct Update: AsyncParsableCommand {
            
            @Argument var uv: Path
            
            func run() async throws {
                if !Validation.hostPython() { return }
                try Validation.backends()
                
                try await launchPython()
                let uv_abs = uv.absolute()
                let toml_path = (uv_abs + "pyproject.toml")
                
                //let toml = try TOMLDecoder().decode(PyProjectToml.self, from: try (toml_path).read())
                let toml = try toml_path.loadPyProjectToml()
                toml.root = uv
                
                guard
                    let pyswift_project = toml.tool?.psproject
                    //let folderName = await pyswift_project.folder_name
                else { return }
                
                let cache_dir = await Path((pyswift_project.wheel_cache_dir ?? ".wheels").resolve_path(prefix: uv_abs, file_url: false))
                guard cache_dir.exists else {
                    return
                }
                let repo = try RepoFolder(root: cache_dir)
                try repo.generate_simple(output: cache_dir)
            }
        }
    }
    
    
}
