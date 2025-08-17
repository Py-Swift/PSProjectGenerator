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

public enum PlatformType: String, Codable {
    case iphoneos
    case macos
}

public struct PyProjectToml: Decodable {
    
    public let project: PyProject?
    public let pyswift: PySwift
    public let dependency_groups: [String: [String]]?
    public let tool: Tool?
    
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
            public let platforms: [PlatformType]
            
            public let exclude_dependencies: [String]?
            
            
            
            private var _loaded_backends: [PSBackend] = []
            public func loaded_backends() async throws -> [PSBackend] {
                if _loaded_backends.isEmpty {
                    _loaded_backends = try await get_backends()
                }
                return _loaded_backends
            }
            
            private func get_backends() async throws -> [PSBackend] {
                let backends_root = Path.ps_shared + "backends"
                
                return try (backends ?? []).compactMap { try .load(name: $0, path: backends_root) }
                
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
                case exclude_dependencies
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
                self.platforms = try container.decode([PlatformType].self, forKey: PyProjectToml.PySwift.Project.CodingKeys.platforms)
                self.exclude_dependencies = try container.decodeIfPresent([String].self, forKey: .exclude_dependencies)
            }
        }
    }
    
    public struct PyProject: Decodable {
        public let name: String?
    }
    
    public struct Tool: Decodable {
        public let uv: UV?
        
        public struct UV: Decodable {
            
            public let sources: Sources?
            
            public struct Sources: Decodable {
                
            }
        }
    }
}

extension PyProjectToml.PySwift.Project {
    public struct Dependencies: Decodable {
        public let pips: [String]?
    }
}


