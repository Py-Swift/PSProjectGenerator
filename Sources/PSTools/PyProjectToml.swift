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

public final class PyProjectToml: Decodable {
    
    public let project: PyProject?
    public let pyswift: PySwift
    public let dependency_groups: [String: [String]]?
    public let tool: Tool?
    public var root: Path?
    
    enum CodingKeys: String, CodingKey {
        case project
        case pyswift
        case dependency_groups = "dependency-groups"
        case tool
    }
    
    public init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<PyProjectToml.CodingKeys> = try decoder.container(keyedBy: PyProjectToml.CodingKeys.self)
        
        self.project = try container.decodeIfPresent(PyProjectToml.PyProject.self, forKey: PyProjectToml.CodingKeys.project)
        self.pyswift = try container.decode(PyProjectToml.PySwift.self, forKey: PyProjectToml.CodingKeys.pyswift)
        self.dependency_groups = try container.decodeIfPresent([String : [String]].self, forKey: PyProjectToml.CodingKeys.dependency_groups)
        self.tool = try container.decodeIfPresent(PyProjectToml.Tool.self, forKey: PyProjectToml.CodingKeys.tool)
        
    }
}

public extension String {
    func resolve_path(prefix: Path, file_url: Bool = true) -> Self {
        switch self {
        case let http where http.hasPrefix("https"):
            return http
        case let relative where relative.hasPrefix("."):
            if file_url {
                return "file://\((prefix + relative))"
            } else {
                return "\((prefix + relative))"
            }
        default:
            if file_url {
                return "file://\(self)"
            } else {
                return self
            }
        }
    }
}

public extension Array where Element == String {
    func resolve(prefix: Path) -> Self {
        self.map { index in
            index.resolve_path(prefix: prefix)
        }
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
            
            public let wheel_cache_dir: String?
            public let extra_index: [String]
            
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
                case extra_index
                case wheel_cache_dir
            }
            
            public init(from decoder: any Decoder) throws {
                let container: KeyedDecodingContainer<PyProjectToml.PySwift.Project.CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
                
                self.name = try container.decodeIfPresent(String.self, forKey: .name)
                self.folder_name = try container.decodeIfPresent(String.self, forKey: .folder_name)
                self.swift_main = try container.decodeIfPresent(String.self, forKey: .swift_main)
                self.swift_sources = try container.decodeIfPresent([String].self, forKey: .swift_sources)
                self.pip_install_app = try container.decodeIfPresent(Bool.self, forKey: .pip_install_app)
                self.backends = try container.decodeIfPresent([String].self, forKey: .backends)
                self.dependencies = try container.decodeIfPresent(PyProjectToml.PySwift.Project.Dependencies.self, forKey: .dependencies)
                self.platforms = try container.decode([PlatformType].self, forKey: .platforms)
                self.exclude_dependencies = try container.decodeIfPresent([String].self, forKey: .exclude_dependencies)
                self.extra_index = try container.decodeIfPresent([String].self, forKey: .extra_index) ?? [
                    "https://pypi.anaconda.org/beeware/simple",
                    "https://pypi.anaconda.org/pyswift/simple",
                    "https://pypi.anaconda.org/kivyschool/simple"
                ]
                self.wheel_cache_dir = try container.decodeIfPresent(String.self, forKey: .wheel_cache_dir)
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


