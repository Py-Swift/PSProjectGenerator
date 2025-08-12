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

public struct PyProjectToml: Decodable {
    
    let project: PyProject?
    let pyswift: PySwift
    let dependency_groups: [String: [String]]?
    let tool: Tool?
    
    enum CodingKeys: String, CodingKey {
        case project
        case pyswift
        case dependency_groups = "dependency-groups"
        case tool
    }
}

enum PyBackendLoader {
    // static let spec_from_file_location = #PyCallable_P<String, Path>(PyImport(from: "importlib.util", import_name: "spec_from_file_location")!)
    // static let module_from_spec = #PyCallable_P<PyPointer>(PyImport(from: "importlib.util", import_name: "module_from_spec")!)
    
    
    static func load_backend(name: String, path: Path) throws -> PSBackend {
//        let spec = spec_from_file_location(name, path)
//        let mod = module_from_spec(spec)
//        
//        let loader = PyObject_GetAttr(spec, "loader")!
//        let exec_module = "exec_module".pyPointer
//        PyObject_CallMethodOneArg(loader, exec_module, mod)
//        PyErr_Print()
//        let backend = PyObject_GetAttr(mod, "backend")!
//        spec.decref()
//        loader.decref()
//        exec_module.decref()
        guard
            let _backend = PyImport_ImportModule("pyswiftbackends.\(name)"),
            let backend = PyObject_GetAttr(_backend, "backend")
        else {
            PyErr_Print()
            fatalError()
        }
        
        return try .casted(from: backend)
    }
    
    public static func install_pyframework_backend() async throws {
        let backend = try load_backend(name: "pyframework", path: "")
        try await backend.do_install(support: .init(value: .ps_support))
    }
}

extension PyProjectToml {
    struct PySwift: Decodable {
        let project: Project?
        
        
        final class Project: Decodable {
            let name: String?
            let folder_name: String?
            let swift_main: String?
            let swift_sources: [String]?
            let pip_install_app: Bool?
            let backends: [String]?
            let dependencies: Dependencies?
            let platforms: [BWProject.PlatformType]
            
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
                    try PyBackendLoader.load_backend(
                        name: backend,
                        path: pyswift_backends + "\(backend)/__init__.py"
                    )
                    // spec = importlib.util.spec_from_file_location(
                    // name, join(custom_recipe_path, "__init__.py")
                    // )
                    // mod = importlib.util.module_from_spec(spec)
                    // spec.loader.exec_module(mod)
                    
                    //return nil
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
            
            init(from decoder: any Decoder) throws {
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
    
    struct PyProject: Decodable {
        let name: String?
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
        let pips: [String]?
    }
}


