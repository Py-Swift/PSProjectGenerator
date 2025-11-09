//
//  Tool+PSProject.swift
//  PSProjectGenerator
//
import PSBackend
import PathKit
import PySwiftKit

extension Path {
    static var ps_shared: Path { "/Users/Shared/psproject"}
    static var ps_support: Path { ps_shared + "support" }
    
}

extension Tool {
    
    //@MainActor
    public final class PSProject: Decodable {
        public let app_name: String?
        public let swift_main: String?
        public let swift_sources: [String]?
        public let pip_install_app: Bool?
        public let backends: [String]?
        public let dependencies: Dependencies?
        
        public let exclude_dependencies: [String]?
        
        public let wheel_cache_dir: String?
        public let extra_index: [String]
        
        // platforms
        public var android: Platforms.Android?
        public var ios: Platforms.iOS?
        public var macos: Platforms.macOS?
        
        private enum CodingKeys: CodingKey {
            case app_name
            case swift_main
            case swift_sources
            case pip_install_app
            case backends
            case dependencies
            case platforms
            case exclude_dependencies
            case extra_index
            case wheel_cache_dir
            
            
            case android
            case ios
            case macos
        }
        
        nonisolated public init(from decoder: any Decoder) throws {
            
            
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            
            self.app_name = try container.decodeIfPresent(String.self, forKey: .app_name)
            self.swift_main = try container.decodeIfPresent(String.self, forKey: .swift_main)
            self.swift_sources = try container.decodeIfPresent([String].self, forKey: .swift_sources)
            self.pip_install_app = try container.decodeIfPresent(Bool.self, forKey: .pip_install_app)
            self.backends = try container.decodeIfPresent([String].self, forKey: .backends)
            self.dependencies = try container.decodeIfPresent(Dependencies.self, forKey: .dependencies)
            
            self.exclude_dependencies = try container.decodeIfPresent([String].self, forKey: .exclude_dependencies)
            self.extra_index = try container.decodeIfPresent([String].self, forKey: .extra_index) ?? [
                "https://pypi.anaconda.org/beeware/simple",
                "https://pypi.anaconda.org/pyswift/simple",
                "https://pypi.anaconda.org/kivyschool/simple"
            ]
            self.wheel_cache_dir = try container.decodeIfPresent(String.self, forKey: .wheel_cache_dir)
            
            self.android = try container.decodeIfPresent(Platforms.Android.self, forKey: .android)
            self.ios = try container.decodeIfPresent(Platforms.iOS.self, forKey: .ios)
            self.macos = try container.decodeIfPresent(Platforms.macOS.self, forKey: .macos)
        }
        
        
        private var _loaded_backends: [PSBackend] = []
        
        //@MainActor
        public func loaded_backends() async throws -> [PSBackend] {
            if _loaded_backends.isEmpty {
                let gil = PyGIL_Released() ? PyGILState_Ensure() : nil
                _loaded_backends = try await get_backends()
                if let gil { PyGILState_Release(gil) }
            }
            return _loaded_backends
        }
        //@MainActor
        private func get_backends() async throws -> [PSBackend] {
            let backends_root = Path.ps_shared + "backends"

            return try (backends ?? []).compactMap { try .load(name: $0, path: backends_root) }
            
        }
        
    }
    
    
}

//public typealias Tool_PSProject = PyProjectToml.Tool.PSProject

extension Tool.PSProject {
    public struct Dependencies: Decodable, Sendable {
        public let pips: [String]?
        
        
        enum CodingKeys: CodingKey {
            case pips
        }
        
        public nonisolated init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            self.pips = try container.decodeIfPresent([String].self, forKey: .pips)
        }
    }
}


