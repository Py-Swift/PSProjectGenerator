//
//  PyProjectToml.swift
//  PythonSwiftProject
//
//  Created by CodeBuilder on 01/08/2025.
//
import Foundation
import PathKit
import PSBackend
import PySwiftKit
import PySwiftWrapper
import PSTools

public struct PyProjectToml: Decodable {
    
    public let project: PyProject?
    public let pyswift: PySwift
    public let dependency_groups: [String: [String]]?
    let tool: Tool?
    
    enum CodingKeys: String, CodingKey {
        case project
        case pyswift
        case dependency_groups = "dependency-groups"
        case tool
    }
}



extension PyProjectToml {
    public struct PySwift: Decodable {
        public let project: Project?
        
        
        public final class Project: Decodable {
            public let name: String?
            public let folder_name: String?
            public let swift_main: String?
            public let swift_sources: [String]?
            public let pip_install_app: Bool?
            public let backends: [String]?
            public let dependencies: Dependencies?
            public let platforms: [BWProject.PlatformType]
            
            private var _loaded_backends: [PSBackend] = []
            func loaded_backends() async throws -> [PSBackend] {
                if _loaded_backends.isEmpty {
                    _loaded_backends = try await get_backends()
                }
                return _loaded_backends
            }
            
            private func get_backends() async throws -> [PSBackend] {
                let backends_root = Path.ps_shared + "backends"
                let pyswift_backends = backends_root + "PySwiftBackends/src/pyswiftbackends"
                
                return try (backends ?? []).compactMap { backend in
                    if backend.contains(".") {
                        try PyBackendLoader.load_backend(
                            external: backend
                        )
                    } else {
                        try PyBackendLoader.load_backend(
                            name: backend
                        )
                    }
                }
            }
            
            private enum CodingKeys: CodingKey {
                case name
                case folder_name
                case swift_main
                case swift_sources
                case pip_install_app
                case backends
                case dependencies
                case platforms
            }
            
            public init(from decoder: any Decoder) throws {
                let container: KeyedDecodingContainer<PyProjectToml.PySwift.Project.CodingKeys> = try decoder.container(keyedBy: PyProjectToml.PySwift.Project.CodingKeys.self)
                
                self.name = try container.decodeIfPresent(String.self, forKey: PyProjectToml.PySwift.Project.CodingKeys.name)
                self.folder_name = try container.decodeIfPresent(String.self, forKey: PyProjectToml.PySwift.Project.CodingKeys.folder_name)
                self.swift_main = try container.decodeIfPresent(String.self, forKey: PyProjectToml.PySwift.Project.CodingKeys.swift_main)
                self.swift_sources = try container.decodeIfPresent([String].self, forKey: PyProjectToml.PySwift.Project.CodingKeys.swift_sources)
                self.pip_install_app = try container.decodeIfPresent(Bool.self, forKey: PyProjectToml.PySwift.Project.CodingKeys.pip_install_app)
                self.backends = try container.decodeIfPresent([String].self, forKey: PyProjectToml.PySwift.Project.CodingKeys.backends)
                self.dependencies = try container.decodeIfPresent(PyProjectToml.PySwift.Project.Dependencies.self, forKey: PyProjectToml.PySwift.Project.CodingKeys.dependencies)
                self.platforms = try container.decode([BWProject.PlatformType].self, forKey: PyProjectToml.PySwift.Project.CodingKeys.platforms)
                
            }
        }
    }
    
    public struct PyProject: Decodable {
        public let name: String?
    }
    
    struct Tool: Decodable {
        let uv: UV?
        
        struct UV: Decodable {
            
            let sources: Sources?
            
            struct Sources: Decodable {
                
            }
        }
    }
}

extension PyProjectToml.PySwift.Project {
    public struct Dependencies: Decodable {
        public let pips: [String]?
    }
}


